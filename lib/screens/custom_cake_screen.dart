import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/providers/custom_request_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/api_client.dart';
import '../core/services/custom_request_service.dart';
import '../core/services/order_service.dart';
import 'auth_helpers.dart';
import 'addresses_screen.dart';
import 'order_confirmation_screen.dart';

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
  
  List<Map<String, dynamic>> _myRequests = [];
  bool _loadingRequests = false;
  int _activeTab = 0; // 0 = New Request, 1 = My Requests

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  @override
  void dispose() {
    _shapeCtrl.dispose();
    _flavorCtrl.dispose();
    _weightCtrl.dispose();
    _themeCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyRequests() async {
    if (!isUserLoggedIn(context)) return;
    
    setState(() => _loadingRequests = true);
    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final service = CustomRequestService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      final requests = await service.getMyRequests();
      setState(() {
        _myRequests = requests;
        _loadingRequests = false;
      });
    } catch (e) {
      setState(() => _loadingRequests = false);
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

  Future<void> _placeOrderForRequest(Map<String, dynamic> request) async {
    final addresses = await context.read<AuthProvider>().getAddresses();
    Map<String, dynamic>? selectedAddress;
    
    if (addresses.isEmpty) {
      // Show address form
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
      );
      if (result == null) return;
      await context.read<AuthProvider>().addAddress(result);
      selectedAddress = result;
    } else {
      // Show address picker
      selectedAddress = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select Delivery Address'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: addresses.length,
              itemBuilder: (_, i) {
                final addr = addresses[i];
                return ListTile(
                  title: Text(addr['label'] ?? 'Address ${i + 1}'),
                  subtitle: Text(
                    [
                      addr['line1'],
                      addr['city'],
                      addr['state'],
                    ].where((e) => e != null).join(', '),
                  ),
                  onTap: () => Navigator.pop(ctx, addr),
                );
              },
            ),
          ),
        ),
      );
      
      if (selectedAddress == null) return;
    }

    final addressText = [
      selectedAddress['line1'],
      selectedAddress['line2'],
      selectedAddress['city'],
      selectedAddress['state'],
      selectedAddress['postalCode'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    try {
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final orderService = OrderService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      
      final requestId = request['id'] ?? request['_id'];
      final order = await orderService.createOrderFromCustomRequest(
        customRequestId: requestId.toString(),
        address: addressText,
        paymentMethod: 'COD',
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          OrderConfirmationScreen.routeName,
          arguments: order,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isUserLoggedIn(context)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Custom Cake Order')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please login to place custom cake orders', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => showLoginRequiredDialog(context),
                child: const Text('Login / Sign Up'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Cake Order')),
      body: Column(
        children: [
          // Tabs
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'New Request'),
              Tab(icon: Icon(Icons.history), text: 'My Requests'),
            ],
            onTap: (index) => setState(() => _activeTab = index),
          ),
          // Content
          Expanded(
            child: _activeTab == 0
                ? Consumer<CustomRequestProvider>(builder: (_, provider, __) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.cake_outlined, color: Colors.pink),
                                    const SizedBox(width: 8),
                                    const Text('Customize Your Cake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fill in the details below and our team will get back to you with a quote.',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _shapeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Shape *',
                            hintText: 'e.g., Round, Square, Heart',
                            prefixIcon: Icon(Icons.shape_line_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _flavorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Flavor *',
                            hintText: 'e.g., Chocolate, Vanilla, Strawberry',
                            prefixIcon: Icon(Icons.restaurant_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _weightCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Weight/Size *',
                            hintText: 'e.g., 1kg, 2kg, Half kg',
                            prefixIcon: Icon(Icons.scale_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _themeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Theme (Optional)',
                            hintText: 'e.g., Birthday, Anniversary, Wedding',
                            prefixIcon: Icon(Icons.celebration_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _messageCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Special Message/Instructions (Optional)',
                            hintText: 'Any special requirements or messages...',
                            prefixIcon: Icon(Icons.message_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Add Reference Image'),
                            ),
                            const SizedBox(width: 12),
                            if (_imageName != null)
                              Expanded(
                                child: Text(
                                  _imageName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        if (_imageBytes != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_imageBytes!, height: 150, fit: BoxFit.cover),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: provider.isSubmitting
                                ? null
                                : () async {
                                    if (_shapeCtrl.text.trim().isEmpty ||
                                        _flavorCtrl.text.trim().isEmpty ||
                                        _weightCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please fill all required fields')),
                                      );
                                      return;
                                    }

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
                                    if (ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request submitted successfully! Admin will review and approve it.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _shapeCtrl.clear();
                                      _flavorCtrl.clear();
                                      _weightCtrl.clear();
                                      _themeCtrl.clear();
                                      _messageCtrl.clear();
                                      _imageBytes = null;
                                      _imageName = null;
                                      _loadMyRequests();
                                    }
                                  },
                            icon: provider.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send),
                            label: Text(provider.isSubmitting ? 'Submitting...' : 'Submit Request'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ),
                        if (provider.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  })
                : (_loadingRequests
                    ? const Center(child: CircularProgressIndicator())
                    : (_myRequests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No custom requests yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMyRequests,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _myRequests.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final req = _myRequests[i];
                                final status = req['status'] as String? ?? 'Requested';
                                final customPrice = (req['customPrice'] as num?)?.toDouble();
                                final imageUrl = req['imageUrl'] as String?;
                                
                                Color statusColor;
                                switch (status) {
                                  case 'Approved':
                                    statusColor = Colors.green;
                                    break;
                                  case 'Rejected':
                                    statusColor = Colors.red;
                                    break;
                                  case 'Ordered':
                                    statusColor = Colors.blue;
                                    break;
                                  default:
                                    statusColor = Colors.orange;
                                }

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (imageUrl != null) ...[
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[200],
                                                    child: const Icon(Icons.image),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                            ],
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${req['shape']} • ${req['flavor']} • ${req['weight']}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: statusColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      status,
                                                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  if (req['theme'] != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text('Theme: ${req['theme']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                                  ],
                                                  if (req['createdAt'] != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      DateFormat('MMM dd, yyyy').format(DateTime.parse(req['createdAt'])),
                                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (customPrice != null) ...[
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text(
                                                '₹${customPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (status == 'Approved' && customPrice != null) ...[
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: FilledButton.icon(
                                              onPressed: () => _placeOrderForRequest(req),
                                              icon: const Icon(Icons.shopping_bag),
                                              label: const Text('Place Order'),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.pink,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ))),
          ),
        ],
      ),
    );
  }
}
