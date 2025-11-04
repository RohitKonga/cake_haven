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
  final _type = TextEditingController();
  final _categories = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;

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
      _type.text = (c['type'] as String?) ?? '';
      _categories.text = ((c['categories'] as List?)?.join(', ') ?? '');
    }
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
    setState(() => _saving = true);
    final tokenGetter = () async => context.read<AuthProvider>().token;
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
    final admin = AdminService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
    final payload = {
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      'discount': double.tryParse(_discount.text) ?? 0,
      'flavor': _flavor.text.trim(),
      'type': _type.text.trim(),
      'categories': _categories.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };
    try {
      Map<String, dynamic> cake;
      if (widget.cake == null) {
        cake = await admin.createCake(payload);
      } else {
        final id = (widget.cake!['id'] as String?) ?? (widget.cake!['_id'] as String);
        cake = await admin.updateCake(id, payload);
      }
      if (_imageBytes != null && _imageName != null) {
        final id = (cake['id'] as String?) ?? (cake['_id'] as String);
        await admin.uploadCakeImage(id, _imageBytes!, _imageName!);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.cake != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Cake' : 'Add Cake')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _discount, decoration: const InputDecoration(labelText: 'Discount (%)'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _flavor, decoration: const InputDecoration(labelText: 'Flavor')),
          const SizedBox(height: 12),
          TextField(controller: _type, decoration: const InputDecoration(labelText: 'Type')),
          const SizedBox(height: 12),
          TextField(controller: _categories, decoration: const InputDecoration(labelText: 'Categories (comma separated)')),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image_outlined), label: const Text('Pick image')),
              const SizedBox(width: 12),
              if (_imageName != null) Expanded(child: Text(_imageName!, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : (editing ? 'Save Changes' : 'Create')),
            ),
          ),
        ],
      ),
    );
  }
}


