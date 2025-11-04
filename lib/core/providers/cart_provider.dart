import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._orderService);

  final OrderService _orderService;
  final List<CartItem> _items = [];
  bool isPlacing = false;
  String? lastOrderId;
  String? error;

  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, it) => sum + it.lineTotal);

  void addItem(CartItem item) {
    final idx = _items.indexWhere((e) => e.cakeId == item.cakeId);
    if (idx >= 0) {
      _items[idx].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String cakeId) {
    _items.removeWhere((e) => e.cakeId == cakeId);
    notifyListeners();
  }

  void updateQuantity(String cakeId, int quantity) {
    final idx = _items.indexWhere((e) => e.cakeId == cakeId);
    if (idx >= 0) {
      _items[idx].quantity = quantity.clamp(1, 99);
      notifyListeners();
    }
  }

  Future<bool> checkout(String address) async {
    if (_items.isEmpty) return false;
    isPlacing = true;
    error = null;
    notifyListeners();
    try {
      final res = await _orderService.createOrder(address: address, items: _items);
      lastOrderId = res['id'] as String? ?? res['_id'] as String?;
      _items.clear();
      return true;
    } catch (e) {
      error = 'Checkout failed';
      return false;
    } finally {
      isPlacing = false;
      notifyListeners();
    }
  }
}


