import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/providers/custom_request_provider.dart';

class CustomCakeScreen extends StatefulWidget {
  const CustomCakeScreen({super.key});
  static const String routeName = '/custom-cake';

  @override
  State<CustomCakeScreen> createState() => _CustomCakeScreenState();
}

class _CustomCakeScreenState extends State<CustomCakeScreen> {
  final _shapeCtrl = TextEditingController();
  final _flavorCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _themeCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void dispose() {
    _shapeCtrl.dispose();
    _flavorCtrl.dispose();
    _weightCtrl.dispose();
    _themeCtrl.dispose();
    _messageCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Cake Order')),
      body: Consumer<CustomRequestProvider>(builder: (_, provider, __) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(controller: _shapeCtrl, decoration: const InputDecoration(labelText: 'Shape')),
            const SizedBox(height: 12),
            TextField(controller: _flavorCtrl, decoration: const InputDecoration(labelText: 'Flavor')),
            const SizedBox(height: 12),
            TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight')),
            const SizedBox(height: 12),
            TextField(controller: _themeCtrl, decoration: const InputDecoration(labelText: 'Theme')),
            const SizedBox(height: 12),
            TextField(controller: _messageCtrl, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image_outlined), label: const Text('Add image')),
                const SizedBox(width: 12),
                if (_imageName != null) Expanded(child: Text(_imageName!, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: provider.isSubmitting
                    ? null
                    : () async {
                        final ok = await provider.submit(
                          shape: _shapeCtrl.text.trim(),
                          flavor: _flavorCtrl.text.trim(),
                          weight: _weightCtrl.text.trim(),
                          theme: _themeCtrl.text.trim().isEmpty ? null : _themeCtrl.text.trim(),
                          message: _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
                          imageBytes: _imageBytes,
                          filename: _imageName,
                        );
                        if (!mounted) return;
                        if (ok) Navigator.pop(context);
                      },
                child: provider.isSubmitting ? const Text('Submitting...') : const Text('Submit Request'),
              ),
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(provider.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        );
      }),
    );
  }
}


