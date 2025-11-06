import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/cake.dart';
import '../core/providers/catalog_provider.dart';
import '../core/providers/cart_provider.dart';
import '../core/models/cart_item.dart';
import 'auth_helpers.dart';

class CakeDetailScreen extends StatelessWidget {
  const CakeDetailScreen({super.key});
  static const String routeName = '/cake';

  @override
  Widget build(BuildContext context) {
    final cake = ModalRoute.of(context)!.settings.arguments as Cake;
    final discount = cake.discount > 0;
    final finalPrice = discount ? cake.price * (1 - cake.discount / 100) : cake.price;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: cake.imageUrl != null && cake.imageUrl!.isNotEmpty
                  ? Image.network(
                      cake.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.cake, size: 80, color: Colors.grey),
                      ),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.cake, size: 80, color: Colors.grey),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cake.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (discount)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cake.discount.toStringAsFixed(0)}% OFF',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (discount) const SizedBox(width: 8),
                                Row(
                                  children: [
                                    if (discount)
                                      Text(
                                        '₹${cake.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    if (discount) const SizedBox(width: 8),
                                    Text(
                                      '₹${finalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (!isUserLoggedIn(context)) {
                          showLoginRequiredDialog(context);
                          return;
                        }
                        context.read<CartProvider>().addItem(
                              CartItem(
                                cakeId: cake.id,
                                name: cake.name,
                                price: finalPrice,
                                imageUrl: cake.imageUrl,
                                quantity: 1,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${cake.name} added to cart'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Description Section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cake.description ?? 'Delicious cake made with love and care. Perfect for any occasion.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Rating Section (Placeholder - can be enhanced later)
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 4),
                      Icon(Icons.star_half, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '4.5',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(120 reviews)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // More Recommendations Section
                  const Text(
                    'You May Also Like',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecommendationsSection(excludeId: cake.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.excludeId});
  final String excludeId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final recommendations = catalog.cakes
        .where((c) => c.id != excludeId && c.imageUrl != null && c.imageUrl!.isNotEmpty)
        .take(4)
        .toList();

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cake = recommendations[index];
          final discount = cake.discount > 0;
          final finalPrice = discount ? cake.price * (1 - cake.discount / 100) : cake.price;

          return SizedBox(
            width: 180,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    CakeDetailScreen.routeName,
                    arguments: cake,
                  );
                },
                borderRadius: BorderRadius.circular(16),
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
                            cake.imageUrl != null
                                ? Image.network(
                                    cake.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.cake, size: 30, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.cake, size: 30, color: Colors.grey),
                                  ),
                            if (discount)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${cake.discount.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
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
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${finalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.pink, size: 22),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    if (!isUserLoggedIn(context)) {
                                      showLoginRequiredDialog(context);
                                      return;
                                    }
                                    context.read<CartProvider>().addItem(
                                          CartItem(
                                            cakeId: cake.id,
                                            name: cake.name,
                                            price: finalPrice,
                                            imageUrl: cake.imageUrl,
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
            ),
          );
        },
      ),
    );
  }
}
