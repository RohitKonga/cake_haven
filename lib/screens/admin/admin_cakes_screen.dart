import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';
import 'admin_edit_cake_screen.dart';

class AdminCakesScreen extends StatefulWidget {
  const AdminCakesScreen({super.key});
  static const routeName = '/admin/cakes';

  @override
  State<AdminCakesScreen> createState() => _AdminCakesScreenState();
}

class _AdminCakesScreenState extends State<AdminCakesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  Future<void> _load() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final data = await svc.listCakes();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Cakes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final c = _items[i] as Map<String, dynamic>;
                final name = c['name'] as String? ?? '';
                final price = (c['price'] as num?)?.toDouble() ?? 0;
                return ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: Text(name),
                  subtitle: Text('₹${price.toStringAsFixed(2)}'),
                  onTap: () async {
                    final refreshed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AdminEditCakeScreen(cake: c)));
                    if (refreshed == true) _load();
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _items.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AdminEditCakeScreen()));
          if (created == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


