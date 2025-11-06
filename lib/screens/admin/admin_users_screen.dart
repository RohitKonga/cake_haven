import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  static const routeName = '/admin/users';

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  Future<void> _load() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    try {
      final data = await svc.listUsers();
      setState(() {
        _users = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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
      appBar: AppBar(title: const Text('All Users')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No users found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final u = _users[i] as Map<String, dynamic>;
                      final name = u['name'] as String? ?? '';
                      final email = u['email'] as String? ?? '';
                      final role = u['role'] as String? ?? 'user';
                      final createdAt = u['createdAt'] as String?;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: role == 'admin' ? Colors.purple : Colors.blue,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(email),
                          trailing: Chip(
                            label: Text(role.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: role == 'admin' ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

