import 'dart:convert';
import '../models/cart_item.dart';
import 'api_client.dart';

class OrderService {
  OrderService(this.client);
  final ApiClient client;

  Future<Map<String, dynamic>> createOrder({required String address, required List<CartItem> items, String paymentMethod = 'COD'}) async {
    final body = {
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items
          .map((e) => {
                'cakeId': e.cakeId,
                'quantity': e.quantity,
              })
          .toList(),
    };
    final res = await client.post('/api/orders', body);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}


