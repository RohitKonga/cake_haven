import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:async';

class RazorpayService {
  late Razorpay _razorpay;
  Completer<Map<String, dynamic>?>? _paymentCompleter;

  // Test keys - Replace these with your actual Razorpay test keys
  static const String _keyId = 'rzp_test_RhsnVweTWG7Fsy'; // Replace with your test key ID
  static const String _keySecret = 'hUvWMW3NAihLdmwHtb02GUrm'; // Replace with your test key secret

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static String get keyId => _keyId;
  static String get keySecret => _keySecret;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete({
        'success': true,
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete({
        'success': false,
        'error': response.message ?? 'Payment failed',
        'code': response.code?.toString(),
      });
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete({
        'success': false,
        'error': 'External wallet selected: ${response.walletName}',
      });
    }
  }

  Future<Map<String, dynamic>?> openCheckout({
    required double amount,
    String? orderId,
    required String name,
    required String email,
    required String contact,
  }) async {
    _paymentCompleter = Completer<Map<String, dynamic>?>();

    // Convert amount to paise (Razorpay expects amount in smallest currency unit)
    final amountInPaise = (amount * 100).toInt();

    final options = {
      'key': _keyId,
      'amount': amountInPaise,
      'name': 'Cake Haven',
      'description': 'Order Payment',
      if (orderId != null) 'order_id': orderId,
      'prefill': {
        'contact': contact,
        'email': email,
        'name': name,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': '#FF69B4' // Pink color matching your app theme
      }
    };

    try {
      _razorpay.open(options);
      return await _paymentCompleter!.future;
    } catch (e) {
      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.complete({
          'success': false,
          'error': 'Failed to open payment gateway: ${e.toString()}',
        });
      }
      return await _paymentCompleter!.future;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

