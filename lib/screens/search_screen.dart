import 'package:flutter/material.dart';
import '../core/models/cake.dart';
import '../core/services/api_client.dart';
import '../core/services/cake_service.dart';
import '../core/widgets/cake_haven_logo.dart';
import 'cake_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Cake> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-focus search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _error = null;
    });

    try {
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final cakeService = CakeService(ApiClient(baseUrl: baseUrl, getToken: () async => null));
      
      // Get all cakes and filter locally (API doesn't have search endpoint)
      final allCakes = await cakeService.listCakes();
      final queryLower = query.toLowerCase();
      
      final filtered = allCakes.where((cake) {
        final name = (cake.name ?? '').toLowerCase();
        final flavor = (cake.flavor ?? '').toLowerCase();
        final description = (cake.description ?? '').toLowerCase();
        final categories = cake.categories.map((c) => c.toLowerCase()).join(' ');
        
        return name.contains(queryLower) ||
            flavor.contains(queryLower) ||
            description.contains(queryLower) ||
            categories.contains(queryLower);
      }).toList();

      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search - wait 500ms after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value && mounted) {
        _performSearch(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const CakeHavenLogo(size: 20),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search cakes by name, flavor, category...',
                prefixIcon: const Icon(Icons.search, color: Colors.pink),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                            _error = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
            ),
          ),
          
          // Results Section
          Expanded(
            child: _buildResults(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for delicious cakes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching by name, flavor, or category',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No cakes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Found ${_results.length} ${_results.length == 1 ? 'cake' : 'cakes'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final cake = _results[index];
              final discount = cake.discount > 0;
              final finalPrice = discount ? cake.price * (1 - cake.discount / 100) : cake.price;
              
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CakeDetailScreen.routeName,
                      arguments: cake,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: cake.imageUrl != null && cake.imageUrl!.isNotEmpty
                              ? Image.network(
                                  cake.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.cake_outlined, size: 40),
                                  ),
                                  loadingBuilder: (_, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
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
                                cake.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (cake.flavor != null && cake.flavor!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  cake.flavor!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (discount)
                                        Text(
                                          '₹${cake.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                        ),
                                      Text(
                                        '₹${finalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (discount)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${cake.discount.toStringAsFixed(0)}%',
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
      ],
    );
  }
}
