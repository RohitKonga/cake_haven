import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/widgets/cake_haven_logo.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait a bit for auth provider to load user
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.currentUser?.role == 'admin') {
        Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CakeHavenLogo(size: 48, showSubtitle: true),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(builder: (_, auth, __) {
              if (auth.currentUser?.role == 'admin') {
                return const Text('Admin Dashboard Loading...', style: TextStyle(fontSize: 14));
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}


