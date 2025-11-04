import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/cake_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/custom_cake_screen.dart';
import 'screens/search_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(const CakeHavenApp());
}

class CakeHavenApp extends StatelessWidget {
  const CakeHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    return MaterialApp(
      title: 'CakeHaven',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        CakeDetailScreen.routeName: (_) => const CakeDetailScreen(),
        CartScreen.routeName: (_) => const CartScreen(),
        CheckoutScreen.routeName: (_) => const CheckoutScreen(),
        OrdersScreen.routeName: (_) => const OrdersScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        CustomCakeScreen.routeName: (_) => const CustomCakeScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
      },
    );
  }
}
