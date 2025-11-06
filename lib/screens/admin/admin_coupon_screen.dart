import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../core/services/api_client.dart';
import '../../core/providers/auth_provider.dart';

class AdminCouponScreen extends StatefulWidget {
  const AdminCouponScreen({super.key});
  static const routeName = '/admin/coupons';

  @override
  State<AdminCouponScreen> createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen> {
  List<dynamic> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final admin = ApiClient(baseUrl: baseUrl, getToken: tokenGetter);
    
    try {
      final res = await admin.get('/api/coupons/admin');
      final data = jsonDecode(res.body) as List<dynamic>;
      setState(() {
        _coupons = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddCouponDialog() async {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Coupon Code',
                hintText: 'e.g., SAVE20',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountCtrl,
              decoration: const InputDecoration(
                labelText: 'Discount (%)',
                hintText: 'e.g., 20',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final discount = double.tryParse(discountCtrl.text.trim()) ?? 0;
              
              if (code.isEmpty || discount <= 0 || discount > 100) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Invalid coupon code or discount')),
                );
                return;
              }

              try {
                final tokenGetter = () async => context.read<AuthProvider>().token;
                final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
                final admin = ApiClient(baseUrl: baseUrl, getToken: tokenGetter);
                
                await admin.post('/api/coupons/admin', {
                  'code': code,
                  'discount': discount,
                });
                
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _loadCoupons();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coupon added successfully')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCouponStatus(String id, bool currentStatus) async {
    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
      final admin = ApiClient(baseUrl: baseUrl, getToken: tokenGetter);
      
      await admin.patch('/api/coupons/admin/$id', {
        'isActive': !currentStatus,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon ${!currentStatus ? 'activated' : 'deactivated'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCoupons();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCoupon(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: const Text('Are you sure you want to delete this coupon?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
      final admin = ApiClient(baseUrl: baseUrl, getToken: tokenGetter);
      await admin.delete('/api/coupons/admin/$id');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon deleted successfully')),
      );
      _loadCoupons();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Coupons')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_coupons.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No coupons yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _coupons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final coupon = _coupons[i] as Map<String, dynamic>;
                        final code = coupon['code'] as String? ?? '';
                        final discount = (coupon['discount'] as num?)?.toDouble() ?? 0;
                        final isActive = coupon['isActive'] as bool? ?? true;
                        
                        return Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.local_offer, color: Colors.orange),
                            ),
                            title: Text(
                              code,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text('${discount.toStringAsFixed(0)}% discount'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle Switch
                                Switch(
                                  value: isActive,
                                  onChanged: (value) {
                                    final id = coupon['id'] ?? coupon['_id'];
                                    if (id != null) {
                                      _toggleCouponStatus(id.toString(), isActive);
                                    }
                                  },
                                  activeColor: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    final id = coupon['id'] ?? coupon['_id'];
                                    if (id != null) _deleteCoupon(id.toString());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _showAddCouponDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Coupon'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

