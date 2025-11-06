import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_client.dart';
import '../../core/services/admin_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminEditCakeScreen extends StatefulWidget {
  const AdminEditCakeScreen({super.key, this.cake});
  static const routeName = '/admin/cakes/edit';
  final Map<String, dynamic>? cake;

  @override
  State<AdminEditCakeScreen> createState() => _AdminEditCakeScreenState();
}

class _AdminEditCakeScreenState extends State<AdminEditCakeScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _flavor = TextEditingController();
  final _categories = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;

  double get _calculatedPrice {
    final price = double.tryParse(_price.text) ?? 0;
    final discount = double.tryParse(_discount.text) ?? 0;
    if (price > 0 && discount > 0) {
      return price * (1 - discount / 100);
    }
    return price;
  }

  @override
  void initState() {
    super.initState();
    final c = widget.cake;
    if (c != null) {
      _name.text = (c['name'] as String?) ?? '';
      _desc.text = (c['description'] as String?) ?? '';
      _price.text = ((c['price'] as num?)?.toString() ?? '');
      _discount.text = ((c['discount'] as num?)?.toString() ?? '');
      _flavor.text = (c['flavor'] as String?) ?? '';
      _categories.text = ((c['categories'] as List?)?.join(', ') ?? '');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _discount.dispose();
    _flavor.dispose();
    _categories.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
      });
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    final price = double.tryParse(_price.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() => _saving = true);
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final payload = {
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': price,
      'discount': double.tryParse(_discount.text) ?? 0,
      'flavor': _flavor.text.trim(),
      'categories': _categories.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };
    try {
      Map<String, dynamic> cake;
      if (widget.cake == null) {
        cake = await admin.createCake(payload);
        if (_imageBytes != null && _imageName != null) {
          try {
            final id = (cake['id'] as String?) ?? (cake['_id'] as String);
            final imageUrl = await admin.uploadCakeImage(id, _imageBytes!, _imageName!);
            if (imageUrl != null) {
              cake['imageUrl'] = imageUrl;
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cake created but image upload failed: ${e.toString()}')),
              );
            }
          }
        }
      } else {
        final id = (widget.cake!['id'] as String?) ?? (widget.cake!['_id'] as String);
        cake = await admin.updateCake(id, payload);
        if (_imageBytes != null && _imageName != null) {
          try {
            final imageUrl = await admin.uploadCakeImage(id, _imageBytes!, _imageName!);
            if (imageUrl != null) {
              cake['imageUrl'] = imageUrl;
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cake updated but image upload failed: ${e.toString()}')),
              );
            }
          }
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.cake == null ? 'Cake created successfully' : 'Cake updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.cake != null;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Cake' : 'Add New Cake')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image Preview Section
          if (_imageBytes != null || widget.cake?['imageUrl'] != null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                image: _imageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_imageBytes!),
                        fit: BoxFit.cover,
                      )
                    : widget.cake?['imageUrl'] != null
                        ? DecorationImage(
                            image: NetworkImage(widget.cake!['imageUrl'] as String),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: _imageBytes == null && widget.cake?['imageUrl'] == null
                  ? const Center(child: Icon(Icons.image_outlined, size: 48))
                  : null,
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(_imageName != null ? 'Change Image' : 'Pick Image'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Basic Info Section
          Text('Basic Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Cake Name *',
              hintText: 'e.g., Chocolate Delight',
              prefixIcon: Icon(Icons.cake_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the cake in detail...',
              prefixIcon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Pricing Section
          Text('Pricing', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            decoration: const InputDecoration(
              labelText: 'Price (₹) *',
              hintText: 'e.g., 999',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _discount,
            decoration: const InputDecoration(
              labelText: 'Discount (%)',
              hintText: 'e.g., 20',
              prefixIcon: Icon(Icons.discount_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discounted Price:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '₹${_calculatedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Details Section
          Text('Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _flavor,
            decoration: const InputDecoration(
              labelText: 'Flavor',
              hintText: 'e.g., Chocolate, Vanilla',
              prefixIcon: Icon(Icons.local_dining_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categories,
            decoration: const InputDecoration(
              labelText: 'Categories (comma separated)',
              hintText: 'e.g., Birthday, Wedding',
              prefixIcon: Icon(Icons.label_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(editing ? Icons.save : Icons.add),
              label: Text(_saving ? 'Saving...' : (editing ? 'Save Changes' : 'Create Cake')),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


