import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  static const String routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => const ListTile(
          leading: Icon(Icons.receipt_long_outlined),
          title: Text('Order #1001'),
          subtitle: Text('Pending'),
          trailing: Text('\$49.98'),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 6,
      ),
    );
  }
}


