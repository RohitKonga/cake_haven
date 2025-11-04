import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person)),
          const SizedBox(height: 12),
          const Text('Profile', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Addresses')),
          const ListTile(leading: Icon(Icons.lock_outline), title: Text('Change Password')),
          const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
          Consumer<AuthProvider>(builder: (_, auth, __) {
            if (auth.currentUser?.role == 'admin') {
              return ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Admin Dashboard'),
                onTap: () => Navigator.pushNamed(context, AdminDashboardScreen.routeName),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}


