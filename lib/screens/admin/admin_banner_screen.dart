import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminBannerScreen extends StatefulWidget {
  const AdminBannerScreen({super.key});
  static const routeName = '/admin/banners';

  @override
  State<AdminBannerScreen> createState() => _AdminBannerScreenState();
}

class _AdminBannerScreenState extends State<AdminBannerScreen> {
  List<dynamic> _banners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    
    try {
      final res = await admin.client.get('/api/banners/admin');
      final data = jsonDecode(res.body) as List<dynamic>;
      setState(() {
        _banners = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadBanner(int order) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    
    setState(() => _loading = true);
    
    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      
      final uri = Uri.parse('$baseUrl/api/banners/admin');
      final headers = await admin.client.buildHeaders(json: false);
      final req = http.MultipartRequest('POST', uri);
      req.headers.addAll(headers);
      req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: file.name));
      req.fields['order'] = order.toString();
      
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner uploaded successfully!')),
        );
        _loadBanners();
      } else {
        final error = jsonDecode(res.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteBanner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      await admin.client.delete('/api/banners/admin/$id');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted successfully')),
      );
      _loadBanners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Banners')),
      body: _loading && _banners.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home Page Banners',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload up to 3 banner images that will appear on the home page',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  
                  // Banner slots
                  Row(
                    children: [
                      Expanded(child: _BannerSlot(order: 1, banner: _getBannerByOrder(1), onUpload: _uploadBanner, onDelete: _deleteBanner)),
                      const SizedBox(width: 12),
                      Expanded(child: _BannerSlot(order: 2, banner: _getBannerByOrder(2), onUpload: _uploadBanner, onDelete: _deleteBanner)),
                      const SizedBox(width: 12),
                      Expanded(child: _BannerSlot(order: 3, banner: _getBannerByOrder(3), onUpload: _uploadBanner, onDelete: _deleteBanner)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, dynamic>? _getBannerByOrder(int order) {
    try {
      final found = _banners.where((b) => (b['order'] as num?)?.toInt() == order).toList();
      return found.isNotEmpty ? found.first as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }
}

class _BannerSlot extends StatelessWidget {
  const _BannerSlot({
    required this.order,
    this.banner,
    required this.onUpload,
    required this.onDelete,
  });

  final int order;
  final Map<String, dynamic>? banner;
  final Function(int) onUpload;
  final Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: banner != null && banner!['imageUrl'] != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      banner!['imageUrl'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                      ),
                      onPressed: () => onDelete(banner!['id'] ?? banner!['_id']),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Banner $order',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: () => onUpload(order),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Banner $order',
                        style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to upload',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

