import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/catalog_provider.dart';
import '../core/providers/cart_provider.dart';
import '../core/models/cart_item.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CakeHaven'),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.cakes;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Featured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _FeaturedCard(
              index: i,
              title: i < items.length ? items[i].name : 'Chocolate Delight',
              price: i < items.length ? items[i].price : 24.99,
              imageUrl: i < items.length ? items[i].imageUrl : null,
              onAdd: () {
                if (i < items.length) {
                  final cake = items[i];
                  context.read<CartProvider>().addItem(
                        CartItem(cakeId: cake.id, name: cake.name, price: cake.price, quantity: 1),
                      );
                }
              },
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.isEmpty ? 6 : items.length.clamp(0, 10),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _Chip('Birthday'), _Chip('Wedding'), _Chip('Cupcakes'), _Chip('Chocolate'), _Chip('Custom'),
          ],
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.index, required this.title, required this.price, this.imageUrl, this.onAdd});
  final int index;
  final String title;
  final double price;
  final String? imageUrl;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.cake, size: 48)),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                  : const Center(child: Icon(Icons.cake, size: 48)),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class OrdersPlaceholder extends StatelessWidget {
  const OrdersPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Orders will appear here'));
  }
}


