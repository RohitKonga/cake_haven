import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CircleAvatar(radius: 36, child: Icon(Icons.person)),
          SizedBox(height: 12),
          Text('Guest User', textAlign: TextAlign.center),
          SizedBox(height: 24),
          ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Addresses')),
          ListTile(leading: Icon(Icons.lock_outline), title: Text('Change Password')),
          ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}


