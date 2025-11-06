import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  static const routeName = '/admin/orders';

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  Future<void> _load() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final data = await svc.listOrders();
    setState(() {
      _orders = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    await svc.updateOrderStatus(id, status);
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final o = _orders[i] as Map<String, dynamic>;
                final id = (o['id'] as String?) ?? (o['_id'] as String?);
                final status = o['status'] as String? ?? '';
                final total = (o['total'] as num?)?.toDouble() ?? 0;
                return ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('#${id?.substring(0, 6) ?? ''} • \$${total.toStringAsFixed(2)}'),
                  subtitle: Text(status),
                  trailing: PopupMenuButton<String>(
                    onSelected: (s) => _updateStatus(id!, s),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'Pending', child: Text('Pending')),
                      PopupMenuItem(value: 'Preparing', child: Text('Preparing')),
                      PopupMenuItem(value: 'Out for Delivery', child: Text('Out for Delivery')),
                      PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _orders.length,
            ),
    );
  }
}


