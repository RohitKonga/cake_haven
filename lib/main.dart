import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/cake_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/catalog_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/services/order_service.dart';
import 'core/services/custom_request_service.dart';
import 'core/providers/custom_request_provider.dart';

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
import 'screens/admin/admin_cakes_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_custom_requests_screen.dart';
import 'screens/admin/admin_cakes_list_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/addresses_screen.dart';

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

    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final authService = AuthService(ApiClient(baseUrl: baseUrl, getToken: null));
    final authedClient = ApiClient(baseUrl: baseUrl, getToken: authService.getToken);
    final catalogProvider = CatalogProvider(CakeService(ApiClient(baseUrl: baseUrl, getToken: () async => null)));
    final cartProvider = CartProvider(OrderService(authedClient));
    final customRequestProvider = CustomRequestProvider(CustomRequestService(authedClient));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider(authService);
            provider.setAuthedClient(authedClient);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => catalogProvider..fetchCakes()),
        ChangeNotifierProvider(create: (_) => cartProvider),
        ChangeNotifierProvider(create: (_) => customRequestProvider),
      ],
      child: MaterialApp(
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
        AdminCakesScreen.routeName: (_) => const AdminCakesScreen(),
        AdminOrdersScreen.routeName: (_) => const AdminOrdersScreen(),
        AdminCustomRequestsScreen.routeName: (_) => const AdminCustomRequestsScreen(),
        AdminCakesListScreen.routeName: (_) => const AdminCakesListScreen(),
        AdminUsersScreen.routeName: (_) => const AdminUsersScreen(),
        AdminProfileScreen.routeName: (_) => const AdminProfileScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        AddressesScreen.routeName: (_) => const AddressesScreen(),
      },
      ),
    );
  }
}
