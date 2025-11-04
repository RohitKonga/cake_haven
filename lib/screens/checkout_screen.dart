import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  static const String routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'Enter delivery address')),
            const SizedBox(height: 16),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Row(children: [Radio(value: true, groupValue: true, onChanged: null), Text('Cash on Delivery')]),
            const Spacer(),
            Consumer<CartProvider>(builder: (_, cart, __) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: cart.isPlacing
                      ? null
                      : () async {
                          final ok = await cart.checkout(_addressCtrl.text.trim());
                          if (!mounted) return;
                          if (ok) Navigator.popUntil(context, ModalRoute.withName('/home'));
                        },
                  child: cart.isPlacing ? const Text('Placing...') : const Text('Place Order'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


