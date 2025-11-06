import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.shopping_cart_outlined, color: Colors.pink, size: 28),
          SizedBox(width: 12),
          Expanded(child: Text('Login Required')),
        ],
      ),
      content: const Text(
        'Please login or sign up to add items to your cart and place orders.',
        style: TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, LoginScreen.routeName);
          },
          icon: const Icon(Icons.login, size: 18),
          label: const Text('Login'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, SignupScreen.routeName);
          },
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Sign Up'),
          style: FilledButton.styleFrom(backgroundColor: Colors.pink),
        ),
      ],
    ),
  );
}

bool isUserLoggedIn(BuildContext context) {
  try {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.token != null && auth.currentUser != null;
  } catch (e) {
    return false;
  }
}

