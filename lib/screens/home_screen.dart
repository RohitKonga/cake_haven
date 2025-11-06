import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/catalog_provider.dart';
import '../core/providers/cart_provider.dart';
import '../core/models/cart_item.dart';
import '../core/models/cake.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'cake_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CakeHaven 🍰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, SearchScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _HomeTab(),
          OrdersPlaceholder(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cake_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Auto-scroll banner
    _bannerController.addListener(() {
      setState(() {
        _currentBannerPage = _bannerController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  List<Cake> get _filteredCakes {
    final catalog = context.read<CatalogProvider>();
    if (_selectedCategory == null) return catalog.cakes;
    return catalog.cakes.where((cake) {
      // Filter by categories array or flavor
      final categoryLower = _selectedCategory!.toLowerCase();
      final hasCategory = cake.categories.any((cat) => cat.toLowerCase() == categoryLower);
      final matchesFlavor = cake.flavor?.toLowerCase() == categoryLower;
      return hasCategory || matchesFlavor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cakes = catalog.cakes;
    final filteredCakes = _filteredCakes;
    
    // Get featured cakes with images for banner (first 3-5)
    final featuredCakes = cakes.where((c) => c.imageUrl != null && c.imageUrl!.isNotEmpty).take(5).toList();
    
    return RefreshIndicator(
      onRefresh: () => catalog.fetchCakes(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel Section
            if (featuredCakes.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: featuredCakes.length,
                  itemBuilder: (context, index) {
                    final cake = featuredCakes[index];
                    final discount = cake.discount > 0;
                    final finalPrice = discount ? cake.price * (1 - cake.discount / 100) : cake.price;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image
                            cake.imageUrl != null
                                ? Image.network(
                                    cake.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.cake, size: 64, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.cake, size: 64, color: Colors.grey),
                                  ),
                            // Gradient Overlay
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (discount)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${cake.discount.toStringAsFixed(0)}% OFF',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cake.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (discount)
                                        Text(
                                          '₹${cake.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      if (discount) const SizedBox(width: 8),
                                      Text(
                                        '₹${finalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Banner Indicators
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    featuredCakes.length,
                    (index) => Container(
                      width: _currentBannerPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentBannerPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Category Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: 'All',
                          icon: Icons.all_inclusive,
                          isSelected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: 'Birthday',
                          icon: Icons.cake,
                          isSelected: _selectedCategory == 'Birthday',
                          onTap: () => setState(() => _selectedCategory = 'Birthday'),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: 'Anniversary',
                          icon: Icons.favorite,
                          isSelected: _selectedCategory == 'Anniversary',
                          onTap: () => setState(() => _selectedCategory = 'Anniversary'),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: 'Wedding',
                          icon: Icons.celebration,
                          isSelected: _selectedCategory == 'Wedding',
                          onTap: () => setState(() => _selectedCategory = 'Wedding'),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: 'Chocolate',
                          icon: Icons.local_dining,
                          isSelected: _selectedCategory == 'Chocolate',
                          onTap: () => setState(() => _selectedCategory = 'Chocolate'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Recommended Cakes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedCategory != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedCategory = null),
                      child: const Text('Clear Filter'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Cake Grid
            if (catalog.isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredCakes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.cake_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategory != null
                            ? 'No cakes found in this category'
                            : 'No cakes available',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredCakes.length,
                itemBuilder: (context, index) {
                  final cake = filteredCakes[index];
                  return _CakeCard(cake: cake);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CakeCard extends StatelessWidget {
  const _CakeCard({required this.cake});
  final Cake cake;

  @override
  Widget build(BuildContext context) {
    final discount = cake.discount > 0;
    final finalPrice = discount ? cake.price * (1 - cake.discount / 100) : cake.price;

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        CakeDetailScreen.routeName,
        arguments: cake,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cake.imageUrl != null && cake.imageUrl!.isNotEmpty
                        ? Image.network(
                            cake.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.cake, size: 40, color: Colors.grey),
                            ),
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.cake, size: 40, color: Colors.grey),
                          ),
                    if (discount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cake.discount.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cake.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (discount)
                              Text(
                                '₹${cake.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '₹${finalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.pink),
                          iconSize: 28,
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                                  CartItem(
                                    cakeId: cake.id,
                                    name: cake.name,
                                    price: finalPrice,
                                    quantity: 1,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${cake.name} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersPlaceholder extends StatelessWidget {
  const OrdersPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Orders will appear here'));
  }
}
