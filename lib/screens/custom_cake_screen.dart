import 'package:flutter/material.dart';

class CustomCakeScreen extends StatelessWidget {
  const CustomCakeScreen({super.key});
  static const String routeName = '/custom-cake';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Cake Order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Shape')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Flavor')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Weight')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Theme')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Message')),
          SizedBox(height: 20),
          FilledButton(onPressed: null, child: Text('Submit Request')),
        ],
      ),
    );
  }
}


