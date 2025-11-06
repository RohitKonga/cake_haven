import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';
import 'admin_edit_cake_screen.dart';

class AdminCakesListScreen extends StatefulWidget {
  const AdminCakesListScreen({super.key});
  static const routeName = '/admin/cakes/list';

  @override
  State<AdminCakesListScreen> createState() => _AdminCakesListScreenState();
}

class _AdminCakesListScreenState extends State<AdminCakesListScreen> {
  List<dynamic> _cakes = [];
  bool _loading = true;

  Future<void> _load() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    try {
      final data = await svc.listCakes();
      setState(() {
        _cakes = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteCake(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Cake'),
        content: Text('Are you sure you want to delete "$name"?'),
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
    if (confirm == true) {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
      final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      await svc.deleteCake(id);
      await _load();
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Cakes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cakes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cake_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No cakes yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cakes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = _cakes[i] as Map<String, dynamic>;
                      final id = (c['id'] as String?) ?? (c['_id'] as String);
                      final name = c['name'] as String? ?? '';
                      final price = (c['price'] as num?)?.toDouble() ?? 0;
                      final discount = (c['discount'] as num?)?.toDouble() ?? 0;
                      final imageUrl = c['imageUrl'] as String?;
                      return Card(
                        child: ListTile(
                          leading: imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.cake_outlined),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            discount > 0
                                ? '₹${price.toStringAsFixed(2)} (${discount.toStringAsFixed(0)}% off)'
                                : '₹${price.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final refreshed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(builder: (_) => AdminEditCakeScreen(cake: c)),
                                  );
                                  if (refreshed == true) _load();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteCake(id, name),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final refreshed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => AdminEditCakeScreen(cake: c)),
                            );
                            if (refreshed == true) _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AdminEditCakeScreen()),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Cake'),
      ),
    );
  }
}

