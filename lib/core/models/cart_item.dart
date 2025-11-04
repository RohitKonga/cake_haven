class CartItem {
  final String cakeId;
  final String name;
  final double price;
  int quantity;

  CartItem({required this.cakeId, required this.name, required this.price, this.quantity = 1});

  double get lineTotal => price * quantity;
}


