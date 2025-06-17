class ProductModel {
  final String id;
  final String name;
  final int price;
  final String? image;
  final String category;
  final String description;
  final bool stock;
  final DateTime created;
  final DateTime updated;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    required this.category,
    required this.description,
    required this.stock,
    required this.created,
    required this.updated,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      stock: json['stock'] ?? true,
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'stock': stock,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    int? price,
    String? image,
    String? category,
    String? description,
    bool? stock,
    DateTime? created,
    DateTime? updated,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // Helper getter for backward compatibility
  bool get isAvailable => stock;
}
