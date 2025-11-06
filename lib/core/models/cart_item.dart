class CartItem {
  final String cakeId;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.cakeId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get lineTotal => price * quantity;
}


