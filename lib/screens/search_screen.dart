import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  static const String routeName = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Cakes')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, flavor, type...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => const ListTile(
                leading: Icon(Icons.cake_outlined),
                title: Text('Vanilla Dream'),
                subtitle: Text('Vanilla • $19.99'),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}


