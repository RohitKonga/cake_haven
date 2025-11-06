import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(builder: (_, auth, __) {
        final isLoggedIn = auth.currentUser != null;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            Text(
              isLoggedIn ? (auth.currentUser?.name ?? 'User') : 'Guest',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (isLoggedIn) Text(
              auth.currentUser?.email ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (!isLoggedIn) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, LoginScreen.routeName),
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, SignupScreen.routeName),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (isLoggedIn) ...[
              const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Addresses')),
              const ListTile(leading: Icon(Icons.lock_outline), title: Text('Change Password')),
              if (auth.currentUser?.role == 'admin')
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Admin Dashboard'),
                  onTap: () => Navigator.pushNamed(context, AdminDashboardScreen.routeName),
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  auth.currentUser = null;
                  auth.token = null;
                },
              ),
            ],
          ],
        );
      }),
    );
  }
}


