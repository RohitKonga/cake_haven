import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/api_client.dart';
import '../core/services/admin_service.dart';
import 'admin/admin_cakes_list_screen.dart';
import 'admin/admin_edit_cake_screen.dart';
import 'admin/admin_users_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/admin_custom_requests_screen.dart';
import 'admin/admin_banner_screen.dart';
import 'admin/admin_coupon_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  static const String routeName = '/admin';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalCakes = 0;
  int _totalOrders = 0;
  int _totalUsers = 0;
  double _totalRevenue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    
    try {
      final cakes = await admin.listCakes();
      final orders = await admin.listOrders();
      final users = await admin.listUsers();
      
      setState(() {
        _totalCakes = cakes.length;
        _totalOrders = orders.length;
        _totalUsers = users.length;
        _totalRevenue = orders.fold<double>(0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0));
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AdminProfileScreen.routeName),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Admin! 👋',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your cake business',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    Text('Overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(icon: Icons.cake_outlined, label: 'Total Cakes', value: '$_totalCakes', color: Colors.pink),
                        _StatCard(icon: Icons.receipt_long_outlined, label: 'Total Orders', value: '$_totalOrders', color: Colors.blue),
                        _StatCard(icon: Icons.people_outlined, label: 'Total Users', value: '$_totalUsers', color: Colors.green),
                        _StatCard(icon: Icons.currency_rupee, label: 'Revenue', value: '₹${_totalRevenue.toStringAsFixed(0)}', color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.add_circle_outlined,
                      title: 'Add New Cake',
                      subtitle: 'Create a new cake listing',
                      color: theme.colorScheme.primary,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminEditCakeScreen()),
                        );
                        if (result == true) _loadStats();
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.cake_outlined,
                      title: 'View All Cakes',
                      subtitle: 'Manage existing cakes',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, AdminCakesListScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.people_outlined,
                      title: 'Manage Users',
                      subtitle: 'View and manage users',
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(context, AdminUsersScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'View Orders',
                      subtitle: 'Manage customer orders',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, AdminOrdersScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.design_services_outlined,
                      title: 'Custom Requests',
                      subtitle: 'Review custom cake requests',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, AdminCustomRequestsScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.image_outlined,
                      title: 'Manage Banners',
                      subtitle: 'Upload home page banners',
                      color: Colors.teal,
                      onTap: () => Navigator.pushNamed(context, AdminBannerScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.local_offer_outlined,
                      title: 'Manage Coupons',
                      subtitle: 'Create and manage discount coupons',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, AdminCouponScreen.routeName),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
