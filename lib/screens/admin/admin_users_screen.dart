import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  List<dynamic> _filteredUsers = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['name'] as String? ?? '').toLowerCase();
        final email = (user['email'] as String? ?? '').toLowerCase();
        final role = user['role'] as String? ?? 'user';
        
        final matchesSearch = name.contains(query) || email.contains(query);
        final matchesRole = _filterRole == 'all' || role == _filterRole;
        
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    try {
      final data = await svc.listUsers();
      setState(() {
        _users = data;
        _filteredUsers = List.from(data);
        _filterUsers();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RoleFilterChip(
                        label: 'All Users',
                        value: 'all',
                        count: _users.length,
                        selected: _filterRole == 'all',
                        onSelected: (v) => setState(() {
                          _filterRole = v;
                          _filterUsers();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _RoleFilterChip(
                        label: 'Admins',
                        value: 'admin',
                        count: _users.where((u) => (u['role'] as String? ?? 'user') == 'admin').length,
                        selected: _filterRole == 'admin',
                        onSelected: (v) => setState(() {
                          _filterRole = v;
                          _filterUsers();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _RoleFilterChip(
                        label: 'Users',
                        value: 'user',
                        count: _users.where((u) => (u['role'] as String? ?? 'user') == 'user').length,
                        selected: _filterRole == 'user',
                        onSelected: (v) => setState(() {
                          _filterRole = v;
                          _filterUsers();
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty ? Icons.search_off : Icons.people_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty ? 'No users found' : 'No users found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final u = _filteredUsers[i] as Map<String, dynamic>;
                            final name = u['name'] as String? ?? 'Unknown';
                            final email = u['email'] as String? ?? '';
                            final role = u['role'] as String? ?? 'user';
                            final createdAt = u['createdAt'] as String?;
                            
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: role == 'admin'
                                              ? [Colors.purple, Colors.purple.shade700]
                                              : [Colors.blue, Colors.blue.shade700],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // User Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: role == 'admin'
                                                      ? Colors.purple.withOpacity(0.2)
                                                      : Colors.blue.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  role.toUpperCase(),
                                                  style: TextStyle(
                                                    color: role == 'admin' ? Colors.purple.shade700 : Colors.blue.shade700,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  email,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (createdAt != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Joined ${DateFormat('MMM dd, yyyy').format(DateTime.parse(createdAt))}',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
    required this.label,
    required this.value,
    required this.count,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final String value;
  final int count;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: selected ? Colors.pink : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: Colors.pink.withOpacity(0.2),
      checkmarkColor: Colors.pink,
    );
  }
}
