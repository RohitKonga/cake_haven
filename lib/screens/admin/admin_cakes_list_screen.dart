import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';
import 'admin_edit_cake_screen.dart';

class AdminCakesListScreen extends StatefulWidget {
  const AdminCakesListScreen({super.key});
  static const routeName = '/admin/cakes/list';

  @override
  State<AdminCakesListScreen> createState() => _AdminCakesListScreenState();
}

class _AdminCakesListScreenState extends State<AdminCakesListScreen> {
  List<dynamic> _cakes = [];
  List<dynamic> _filteredCakes = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCakes);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCakes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCakes = _cakes.where((cake) {
        final name = (cake['name'] as String? ?? '').toLowerCase();
        final flavor = (cake['flavor'] as String? ?? '').toLowerCase();
        return name.contains(query) || flavor.contains(query);
      }).toList();
      _sortCakes();
    });
  }

  void _sortCakes() {
    _filteredCakes.sort((a, b) {
      switch (_sortBy) {
        case 'price_high':
          return ((b['price'] as num?) ?? 0).compareTo((a['price'] as num?) ?? 0);
        case 'price_low':
          return ((a['price'] as num?) ?? 0).compareTo((b['price'] as num?) ?? 0);
        case 'discount':
          return ((b['discount'] as num?) ?? 0).compareTo((a['discount'] as num?) ?? 0);
        default:
          return (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? '');
      }
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    tokenGetter() async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    try {
      final data = await svc.listCakes();
      setState(() {
        _cakes = data;
        _filteredCakes = List.from(data);
        _sortCakes();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cakes: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCakeOptions(BuildContext context, Map<String, dynamic> cake, String id, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Cake name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            // View Cake option
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: Colors.blue),
              title: const Text('View Cake'),
              subtitle: const Text('Edit cake details'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => AdminEditCakeScreen(cake: cake)),
                ).then((refreshed) {
                  if (refreshed == true) _load();
                });
              },
            ),
            // Delete Cake option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Cake'),
              subtitle: const Text('Permanently remove this cake'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteCake(id, name);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCake(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Cake'),
          ],
        ),
        content: Text('Are you sure you want to delete "$name"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      tokenGetter() async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final svc = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      try {
        await svc.deleteCake(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Cake deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting cake: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Cakes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cakes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortChip(
                        label: 'Name',
                        value: 'name',
                        selected: _sortBy == 'name',
                        onSelected: (v) => setState(() {
                          _sortBy = v;
                          _sortCakes();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'Price: High',
                        value: 'price_high',
                        selected: _sortBy == 'price_high',
                        onSelected: (v) => setState(() {
                          _sortBy = v;
                          _sortCakes();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'Price: Low',
                        value: 'price_low',
                        selected: _sortBy == 'price_low',
                        onSelected: (v) => setState(() {
                          _sortBy = v;
                          _sortCakes();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'Discount',
                        value: 'discount',
                        selected: _sortBy == 'discount',
                        onSelected: (v) => setState(() {
                          _sortBy = v;
                          _sortCakes();
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Cakes List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCakes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty ? Icons.search_off : Icons.cake_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty ? 'No cakes found' : 'No cakes yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 18),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first cake',
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredCakes.length,
                          itemBuilder: (_, i) {
                            final c = _filteredCakes[i] as Map<String, dynamic>;
                            final id = (c['id'] as String?) ?? (c['_id'] as String);
                            final name = c['name'] as String? ?? '';
                            final price = (c['price'] as num?)?.toDouble() ?? 0;
                            final discount = (c['discount'] as num?)?.toDouble() ?? 0;
                            final imageUrl = c['imageUrl'] as String?;
                            final finalPrice = discount > 0 ? price * (1 - discount / 100) : price;
                            
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                onTap: () async {
                                  final refreshed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(builder: (_) => AdminEditCakeScreen(cake: c)),
                                  );
                                  if (refreshed == true) _load();
                                },
                                onLongPress: () => _showCakeOptions(context, c, id, name),
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Image
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image_not_supported, size: 40),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.cake_outlined, size: 40),
                                              ),
                                      ),
                                    ),
                                    // Info
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (discount > 0)
                                                      Text(
                                                        '₹${price.toStringAsFixed(0)}',
                                                        style: TextStyle(
                                                          decoration: TextDecoration.lineThrough,
                                                          color: Colors.grey[600],
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    Text(
                                                      '₹${finalPrice.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.pink,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (discount > 0)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${discount.toStringAsFixed(0)}%',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AdminEditCakeScreen()),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Cake'),
        backgroundColor: Colors.pink,
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final String value;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: Colors.pink.withOpacity(0.2),
      checkmarkColor: Colors.pink,
    );
  }
}
