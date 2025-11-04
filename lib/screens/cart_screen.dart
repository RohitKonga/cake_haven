import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => const ListTile(
                leading: Icon(Icons.cake_outlined),
                title: Text('Chocolate Delight'),
                subtitle: Text('x1  •  $24.99'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, CheckoutScreen.routeName),
                  child: const Text('Proceed to Checkout'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


