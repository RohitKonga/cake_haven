import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminCustomRequestsScreen extends StatefulWidget {
  const AdminCustomRequestsScreen({super.key});
  static const routeName = '/admin/custom';

  @override
  State<AdminCustomRequestsScreen> createState() => _AdminCustomRequestsScreenState();
}

class _AdminCustomRequestsScreenState extends State<AdminCustomRequestsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _filterStatus;

  Future<void> _load() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final data = await svc.listCustomRequests();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _review(String id, String status, {double? price}) async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    await svc.reviewCustom(id, status, price: price);
    await _load();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Requested':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Ordered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Requested':
        return Icons.pending_outlined;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Rejected':
        return Icons.cancel_outlined;
      case 'Ordered':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.design_services_outlined;
    }
  }

  List<dynamic> get _filteredItems {
    if (_filterStatus == null) return _items;
    return _items.where((c) => (c['status'] as String?) == _filterStatus).toList();
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
        title: const Text('Custom Cake Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.design_services_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No custom requests yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
                            ...['Requested', 'Approved', 'Rejected', 'Ordered'].map((status) => Padding(
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
                    // Requests List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final c = _filteredItems[i] as Map<String, dynamic>;
                            final id = (c['id'] as String?) ?? (c['_id'] as String?);
                            final status = c['status'] as String? ?? 'Requested';
                            final shape = c['shape'] as String? ?? '';
                            final flavor = c['flavor'] as String? ?? '';
                            final weight = c['weight'] as String? ?? '';
                            final theme = c['theme'] as String?;
                            final message = c['message'] as String?;
                            final imageUrl = c['imageUrl'] as String?;
                            final customPrice = (c['customPrice'] as num?)?.toDouble();
                            final createdAt = c['createdAt'] != null
                                ? DateTime.parse(c['createdAt'] as String)
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
                                  '$shape • $flavor • $weight',
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
                                trailing: customPrice != null
                                    ? Text(
                                        '₹${customPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
                                      )
                                    : null,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Image
                                        if (imageUrl != null) ...[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              imageUrl,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                height: 200,
                                                color: Colors.grey[200],
                                                child: const Center(child: Icon(Icons.image, size: 40)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        // Details
                                        _DetailRow(label: 'Shape', value: shape),
                                        _DetailRow(label: 'Flavor', value: flavor),
                                        _DetailRow(label: 'Weight', value: weight),
                                        if (theme != null && theme.isNotEmpty) _DetailRow(label: 'Theme', value: theme),
                                        if (message != null && message.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(message, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                        ],
                                        if (customPrice != null) ...[
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(
                                                '₹${customPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        // Actions
                                        if (status == 'Requested')
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () async {
                                                  final price = await showDialog<double?>(
                                                    context: context,
                                                    builder: (ctx) {
                                                      final ctrl = TextEditingController();
                                                      return AlertDialog(
                                                        title: const Text('Set Price'),
                                                        content: TextField(
                                                          controller: ctrl,
                                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                          decoration: const InputDecoration(
                                                            labelText: 'Price (₹)',
                                                            hintText: 'e.g. 1499.99',
                                                            border: OutlineInputBorder(),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(ctx),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          FilledButton(
                                                            onPressed: () {
                                                              final price = double.tryParse(ctrl.text.trim());
                                                              if (price != null && price > 0) {
                                                                Navigator.pop(ctx, price);
                                                              }
                                                            },
                                                            child: const Text('Set Price'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  if (price != null && id != null) {
                                                    await _review(id, 'Approved', price: price);
                                                  }
                                                },
                                                icon: const Icon(Icons.check),
                                                label: const Text('Approve'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.green,
                                                  side: const BorderSide(color: Colors.green),
                                                ),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text('Reject Request'),
                                                      content: const Text('Are you sure you want to reject this custom cake request?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(ctx, false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () => Navigator.pop(ctx, true),
                                                          child: const Text('Reject'),
                                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true && id != null) {
                                                    await _review(id, 'Rejected');
                                                  }
                                                },
                                                icon: const Icon(Icons.close),
                                                label: const Text('Reject'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  side: const BorderSide(color: Colors.red),
                                                ),
                                              ),
                                            ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
