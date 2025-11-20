import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (_, auth, __) {
      // Redirect admins to admin dashboard
      if (auth.currentUser?.role == 'admin') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: _buildProfileContent(context, auth),
      );
    });
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider auth) {
    final isLoggedIn = auth.currentUser != null;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(
                      isLoggedIn ? Icons.person : Icons.person_outline,
                      size: 55,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isLoggedIn ? (auth.currentUser?.name ?? 'User') : 'Guest User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (isLoggedIn && auth.currentUser?.email != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    auth.currentUser!.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
                if (!isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Login to access your account',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!isLoggedIn) ...[
                  // Guest Mode - Welcome Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join CakeHaven Today!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account to save your favorite cakes, track orders, and get exclusive offers!',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, LoginScreen.routeName),
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, SignupScreen.routeName),
                      icon: const Icon(Icons.person_add, size: 24),
                      label: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: const BorderSide(color: Colors.pink, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Benefits Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Benefits of Creating an Account:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _BenefitItem(
                          icon: Icons.shopping_bag_outlined,
                          text: 'Save your favorite cakes',
                        ),
                        const SizedBox(height: 12),
                        _BenefitItem(
                          icon: Icons.receipt_long_outlined,
                          text: 'Track your orders',
                        ),
                        const SizedBox(height: 12),
                        _BenefitItem(
                          icon: Icons.location_on_outlined,
                          text: 'Save delivery addresses',
                        ),
                        const SizedBox(height: 12),
                        _BenefitItem(
                          icon: Icons.local_offer_outlined,
                          text: 'Get exclusive offers & discounts',
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (isLoggedIn) ...[
                  const SizedBox(height: 24),
                  _ProfileCard(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => Navigator.pushNamed(context, EditProfileScreen.routeName),
                  ),
                  const SizedBox(height: 12),
                  _ProfileCard(
                    icon: Icons.location_on_outlined,
                    title: 'My Addresses',
                    subtitle: 'Manage delivery addresses',
                    onTap: () => Navigator.pushNamed(context, AddressesScreen.routeName),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await auth.logout();
                          if (context.mounted) {
                            // Clear entire navigation stack and go to home
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              HomeScreen.routeName,
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? theme.colorScheme.primaryContainer).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ),
      ],
    );
  }
}
