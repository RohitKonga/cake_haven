import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Custom Requests')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final c = _items[i] as Map<String, dynamic>;
                final id = (c['id'] as String?) ?? (c['_id'] as String?);
                final status = c['status'] as String? ?? '';
                final title = '${c['shape'] ?? ''} • ${c['flavor'] ?? ''} • ${c['weight'] ?? ''}';
                return ListTile(
                  leading: const Icon(Icons.design_services_outlined),
                  title: Text(title),
                  subtitle: Text(status),
                  trailing: PopupMenuButton<String>(
                    onSelected: (s) async {
                      if (s == 'Approved') {
                        final price = await showDialog<double?>(
                          context: context,
                          builder: (ctx) {
                            final ctrl = TextEditingController();
                            return AlertDialog(
                              title: const Text('Set custom price'),
                              content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 49.99')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)), child: const Text('Save')),
                              ],
                            );
                          },
                        );
                        if (price != null) await _review(id!, 'Approved', price: price);
                      } else {
                        await _review(id!, s);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'Requested', child: Text('Requested')),
                      PopupMenuItem(value: 'Approved', child: Text('Approve')),
                      PopupMenuItem(value: 'Rejected', child: Text('Reject')),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _items.length,
            ),
    );
  }
}


