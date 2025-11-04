import 'package:flutter/material.dart';
import 'admin/admin_cakes_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/admin_custom_requests_screen.dart';

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
        children: [
          _AdminCard(label: 'Cakes', icon: Icons.cake_outlined, onTap: () => Navigator.pushNamed(context, AdminCakesScreen.routeName)),
          _AdminCard(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: () => Navigator.pushNamed(context, AdminOrdersScreen.routeName)),
          _AdminCard(label: 'Custom Requests', icon: Icons.design_services_outlined, onTap: () => Navigator.pushNamed(context, AdminCustomRequestsScreen.routeName)),
          const _AdminCard(label: 'Users', icon: Icons.people_outline),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }
}


