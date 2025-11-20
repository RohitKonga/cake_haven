import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  String? _filterStatus;

  Future<void> _load() async {
    tokenGetter() async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final data = await svc.listOrders();
    setState(() {
      _orders = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    tokenGetter() async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    await svc.updateOrderStatus(id, status);
    await _load();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Out for Delivery':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_outlined;
      case 'Preparing':
        return Icons.restaurant_outlined;
      case 'Out for Delivery':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  List<dynamic> get _filteredOrders {
    if (_filterStatus == null) return _orders;
    return _orders.where((o) => (o['status'] as String?) == _filterStatus).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No orders yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter Chips
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              isSelected: _filterStatus == null,
                              onTap: () => setState(() => _filterStatus = null),
                            ),
                            const SizedBox(width: 8),
                            ...['Pending', 'Preparing', 'Out for Delivery', 'Delivered'].map((status) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: status,
                                isSelected: _filterStatus == status,
                                onTap: () => setState(() => _filterStatus = status),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Orders List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final o = _filteredOrders[i] as Map<String, dynamic>;
                            final id = (o['id'] as String?) ?? (o['_id'] as String?);
                            final status = o['status'] as String? ?? 'Pending';
                            final total = (o['total'] as num?)?.toDouble() ?? 0.0;
                            final items = (o['items'] as List<dynamic>?) ?? [];
                            final address = o['address'] as String? ?? '';
                            final paymentMethod = o['paymentMethod'] as String? ?? 'COD';
                            final createdAt = o['createdAt'] != null
                                ? DateTime.parse(o['createdAt'] as String)
                                : DateTime.now();

                            return Card(
                              elevation: 2,
                              child: ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
                                ),
                                title: Text(
                                  'Order #${id?.substring(id.length - 8) ?? 'N/A'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                      ),
                                    ),
                                    Text(
                                      paymentMethod,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Items
                                        const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 8),
                                        ...items.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item['name'] ?? 'Unknown'} x${item['quantity'] ?? 1}',
                                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                '₹${((item['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1)).toStringAsFixed(2)}',
                                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        )),
                                        const Divider(height: 24),
                                        // Address
                                        const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text(address, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                        const SizedBox(height: 16),
                                        // Status Update
                                        if (status != 'Delivered')
                                          SizedBox(
                                            width: double.infinity,
                                            child: DropdownButtonFormField<String>(
                                              initialValue: status,
                                              decoration: const InputDecoration(
                                                labelText: 'Update Status',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              items: const [
                                                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                                DropdownMenuItem(value: 'Preparing', child: Text('Preparing')),
                                                DropdownMenuItem(value: 'Out for Delivery', child: Text('Out for Delivery')),
                                                DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                                              ],
                                              onChanged: (newStatus) {
                                                if (newStatus != null && id != null) {
                                                  _updateStatus(id, newStatus);
                                                }
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
