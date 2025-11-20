import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../core/providers/cart_provider.dart';
import '../core/services/api_client.dart';
import '../core/providers/auth_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static const String routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      tokenGetter() async => context.read<AuthProvider>().token;
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cake-haven.onrender.com');
      final client = ApiClient(baseUrl: baseUrl, getToken: tokenGetter);
      final res = await client.get('/api/coupons/validate/$code');
      
      // Check if response is successful
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final errorData = jsonDecode(res.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Invalid coupon code');
      }
      
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final discount = (data['discount'] as num?)?.toDouble() ?? 0;
      
      // Validate discount is valid and greater than 0
      if (discount <= 0 || discount > 100) {
        throw Exception('Invalid discount value');
      }
      
      setState(() {
        _appliedCoupon = code;
        _couponDiscount = discount;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon applied! ${discount.toStringAsFixed(0)}% discount'), backgroundColor: Colors.green),
      );
    } catch (e) {
      // Clear any previously applied coupon on error
      setState(() {
        _appliedCoupon = null;
        _couponDiscount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid coupon code'), backgroundColor: Colors.red),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0;
      _couponCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(builder: (_, cart, __) {
        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Start Shopping'),
                ),
              ],
            ),
          );
        }

        final subtotal = cart.total;
        final discountAmount = subtotal * (_couponDiscount / 100);
        final total = subtotal - discountAmount;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cart Items
                  ...cart.items.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.cake, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.cake, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                // Quantity Controls
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.colorScheme.outline),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: item.quantity > 1
                                                ? () => cart.updateQuantity(item.cakeId, item.quantity - 1)
                                                : null,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: () => cart.updateQuantity(item.cakeId, item.quantity + 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Price and Delete
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${item.lineTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => cart.removeItem(item.cakeId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // Coupon Section
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_offer_outlined, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text('Apply Coupon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_appliedCoupon == null)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponCtrl,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter coupon code',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: _applyCoupon,
                                  child: const Text('Apply'),
                                ),
                              ],
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Coupon: $_appliedCoupon', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text('${_couponDiscount.toStringAsFixed(0)}% discount applied'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: _removeCoupon,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Summary and Checkout
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                          Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      if (_couponDiscount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount (${_couponDiscount.toStringAsFixed(0)}%):', style: TextStyle(color: Colors.green[700], fontSize: 14)),
                            Text('-₹${discountAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(context, CheckoutScreen.routeName, arguments: total),
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
