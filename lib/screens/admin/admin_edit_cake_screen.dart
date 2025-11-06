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
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
    final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final payload = {
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': double.parse(_price.text),
      'discount': double.tryParse(_discount.text) ?? 0,
      'flavor': _flavor.text.trim(),
      'categories': _categories.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };
    try {
      Map<String, dynamic> cake;
      bool imageUploadSuccess = true;
      String? imageError;
      
      if (widget.cake == null) {
        cake = await admin.createCake(payload);
        if (_imageBytes != null && _imageName != null) {
          try {
            final id = (cake['id'] as String?) ?? (cake['_id'] as String);
            final imageUrl = await admin.uploadCakeImage(id, _imageBytes!, _imageName!);
            if (imageUrl != null && imageUrl.isNotEmpty) {
              cake['imageUrl'] = imageUrl;
            } else {
              imageUploadSuccess = false;
              imageError = 'Image upload returned null';
            }
          } catch (e) {
            imageUploadSuccess = false;
            imageError = e.toString();
          }
        }
      } else {
        final id = (widget.cake!['id'] as String?) ?? (widget.cake!['_id'] as String);
        cake = await admin.updateCake(id, payload);
        if (_imageBytes != null && _imageName != null) {
          try {
            final imageUrl = await admin.uploadCakeImage(id, _imageBytes!, _imageName!);
            if (imageUrl != null && imageUrl.isNotEmpty) {
              cake['imageUrl'] = imageUrl;
            } else {
              imageUploadSuccess = false;
              imageError = 'Image upload returned null';
            }
          } catch (e) {
            imageUploadSuccess = false;
            imageError = e.toString();
          }
        }
      }
      
      if (!mounted) return;
      
      if (imageUploadSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.cake == null ? 'Cake created successfully!' : 'Cake updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Cake saved but image upload failed')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        title: Text(editing ? 'Edit Cake' : 'Add New Cake'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surfaceContainerHighest,
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
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('No image selected', style: TextStyle(color: Colors.grey[600])),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(_imageName != null ? 'Change Image' : 'Select Image'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Basic Information Section
              _SectionHeader(icon: Icons.info_outline, title: 'Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Cake Name *',
                  hintText: 'e.g., Chocolate Delight',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cake name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the cake in detail...',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 32),
              
              // Pricing Section
              _SectionHeader(icon: Icons.currency_rupee, title: 'Pricing'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _price,
                decoration: InputDecoration(
                  labelText: 'Price (₹) *',
                  hintText: 'e.g., 999',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discount,
                decoration: InputDecoration(
                  labelText: 'Discount (%)',
                  hintText: 'e.g., 20',
                  prefixIcon: const Icon(Icons.discount_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  helperText: 'Leave empty for no discount',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              if (_price.text.isNotEmpty && double.tryParse(_price.text) != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discounted Price', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_calculatedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (double.tryParse(_discount.text) != null && double.parse(_discount.text) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${double.parse(_discount.text).toStringAsFixed(0)}% OFF',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              
              // Details Section
              _SectionHeader(icon: Icons.local_dining_outlined, title: 'Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flavor,
                decoration: InputDecoration(
                  labelText: 'Flavor',
                  hintText: 'e.g., Chocolate, Vanilla, Strawberry',
                  prefixIcon: const Icon(Icons.local_dining_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categories,
                decoration: InputDecoration(
                  labelText: 'Categories',
                  hintText: 'e.g., Birthday, Wedding, Anniversary (comma separated)',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  helperText: 'Separate multiple categories with commas',
                ),
              ),
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(editing ? Icons.save_outlined : Icons.add_circle_outline),
                  label: Text(
                    _saving ? 'Saving...' : (editing ? 'Save Changes' : 'Create Cake'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
