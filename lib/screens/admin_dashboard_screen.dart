import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  static const String routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const [
          _AdminCard(label: 'Cakes', icon: Icons.cake_outlined),
          _AdminCard(label: 'Orders', icon: Icons.receipt_long_outlined),
          _AdminCard(label: 'Custom Requests', icon: Icons.design_services_outlined),
          _AdminCard(label: 'Users', icon: Icons.people_outline),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 36), const SizedBox(height: 8), Text(label)],
        ),
      ),
    );
  }
}


