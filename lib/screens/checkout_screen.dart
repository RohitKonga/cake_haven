import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/cart_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/models/cart_item.dart';
import '../core/services/order_service.dart';
import '../core/services/api_client.dart';
import 'dart:convert';
import 'order_confirmation_screen.dart';
import 'addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  static const String routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  bool _loading = true;
  bool _showingAddressForm = false;
  bool _isPlacingOrder = false;
  
  // Address form fields
  final _labelCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final auth = context.read<AuthProvider>();
    try {
      final addresses = await auth.getAddresses();
      setState(() {
        _addresses = addresses;
        _loading = false;
        if (addresses.isNotEmpty && _selectedAddress == null) {
          _selectedAddress = addresses.first;
        }
        if (addresses.isEmpty) {
          _showingAddressForm = true;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _showingAddressForm = true;
      });
    }
  }

  Future<void> _saveAddress() async {
    if (_labelCtrl.text.trim().isEmpty || _line1Ctrl.text.trim().isEmpty || _cityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    try {
      final auth = context.read<AuthProvider>();
      await auth.addAddress({
        'label': _labelCtrl.text.trim(),
        'line1': _line1Ctrl.text.trim(),
        'line2': _line2Ctrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postalCode': _postalCodeCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
      });
      await _loadAddresses();
      setState(() {
        _showingAddressForm = false;
        _labelCtrl.clear();
        _line1Ctrl.clear();
        _line2Ctrl.clear();
        _cityCtrl.clear();
        _stateCtrl.clear();
        _postalCodeCtrl.clear();
        _countryCtrl.text = 'India';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _editAddress(Map<String, dynamic> address) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
    );
    if (result != null) {
      try {
        final auth = context.read<AuthProvider>();
        final id = address['_id'] as String? ?? address['id'] as String?;
        if (id != null) {
          await auth.updateAddress(id, result);
          await _loadAddresses();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null && !_showingAddressForm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add an address')),
      );
      return;
    }

    if (_showingAddressForm) {
      if (_labelCtrl.text.trim().isEmpty || _line1Ctrl.text.trim().isEmpty || _cityCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill required address fields')),
        );
        return;
      }
      await _saveAddress();
      if (_addresses.isEmpty) return;
      _selectedAddress = _addresses.first;
    }

    final addressText = [
      _selectedAddress!['line1'],
      _selectedAddress!['line2'],
      _selectedAddress!['city'],
      _selectedAddress!['state'],
      _selectedAddress!['postalCode'],
      _selectedAddress!['country'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    setState(() => _isPlacingOrder = true);

    try {
      final cart = context.read<CartProvider>();
      final tokenGetter = () async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final orderService = OrderService(ApiClient(baseUrl: baseUrl, getToken: tokenGetter));
      
      final total = ModalRoute.of(context)!.settings.arguments as double? ?? cart.total;
      
      final order = await orderService.createOrder(
        address: addressText,
        items: cart.items,
        paymentMethod: 'COD',
      );

      // Clear cart
      cart.clearCart();

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
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = ModalRoute.of(context)!.settings.arguments as double? ?? cart.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (!_showingAddressForm && _addresses.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => setState(() => _showingAddressForm = true),
                          icon: const Icon(Icons.add),
                          label: const Text('Add New'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_showingAddressForm) ...[
                    // Address Form
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _labelCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Label (e.g., Home, Work)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _line1Ctrl,
                              decoration: const InputDecoration(
                                labelText: 'Address Line 1 *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _line2Ctrl,
                              decoration: const InputDecoration(
                                labelText: 'Address Line 2',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _cityCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'City *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _stateCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _postalCodeCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Postal Code',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _countryCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Country',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _showingAddressForm = false),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _saveAddress,
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_addresses.isEmpty) ...[
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No addresses saved. Please add an address.')),
                      ),
                    ),
                  ] else ...[
                    // Address Selection
                    ..._addresses.map((addr) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: RadioListTile<Map<String, dynamic>>(
                        value: addr,
                        groupValue: _selectedAddress,
                        onChanged: (val) => setState(() => _selectedAddress = val),
                        title: Text(addr['label'] as String? ?? 'Address'),
                        subtitle: Text(
                          [
                            addr['line1'],
                            addr['line2'],
                            addr['city'],
                            addr['state'],
                            addr['postalCode'],
                          ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                        ),
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editAddress(addr),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Payment Method
                  const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.money),
                      title: Text('Cash on Delivery'),
                      subtitle: Text('Pay when you receive your order'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Order Summary
                  const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.name} x${item.quantity}'),
                                ),
                                Text('₹${item.lineTotal.toStringAsFixed(2)}'),
                              ],
                            ),
                          )).toList(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      icon: _isPlacingOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.shopping_bag),
                      label: Text(_isPlacingOrder ? 'Placing Order...' : 'Place Order', style: const TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.pink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
