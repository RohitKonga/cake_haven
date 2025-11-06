import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(builder: (_, cart, __) {
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(item.name),
                    subtitle: Text('x${item.quantity}  •  \$${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => cart.removeItem(item.cakeId),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Text('Total: \$${cart.total.toStringAsFixed(2)}')),
                    FilledButton(
                      onPressed: cart.items.isEmpty ? null : () => Navigator.pushNamed(context, CheckoutScreen.routeName),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}


