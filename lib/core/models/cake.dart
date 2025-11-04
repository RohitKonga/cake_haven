class Cake {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double discount;
  final String? imageUrl;

  Cake({required this.id, required this.name, this.description, required this.price, this.discount = 0, this.imageUrl});

  factory Cake.fromJson(Map<String, dynamic> json) {
    return Cake(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}


