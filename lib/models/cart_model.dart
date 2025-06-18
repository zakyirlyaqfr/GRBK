class CartModel {
  final String id;
  final String usersId;
  final String productsId;
  final int quantity;
  final String temperature;
  final String sweetness;
  final String specialNotes;
  final DateTime created;
  final DateTime updated;

  // Additional fields for display (populated from relations)
  final String? productName;
  final int? productPrice;
  final String? productImage;
  final String? productCategory;

  CartModel({
    required this.id,
    required this.usersId,
    required this.productsId,
    required this.quantity,
    required this.temperature,
    required this.sweetness,
    required this.specialNotes,
    required this.created,
    required this.updated,
    this.productName,
    this.productPrice,
    this.productImage,
    this.productCategory,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? '',
      usersId: json['users_id'] ?? '',
      productsId: json['products_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      temperature: json['temperature'] ?? '',
      sweetness: json['sweetness'] ?? '',
      specialNotes: json['special_notes'] ?? '',
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
      // Expanded fields from relations
      productName: json['expand']?['products_id']?['name'],
      productPrice: json['expand']?['products_id']?['price'],
      productImage: json['expand']?['products_id']?['image'],
      productCategory: json['expand']?['products_id']?['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users_id': usersId,
      'products_id': productsId,
      'quantity': quantity,
      'temperature': temperature,
      'sweetness': sweetness,
      'special_notes': specialNotes,
    };
  }

  CartModel copyWith({
    String? id,
    String? usersId,
    String? productsId,
    int? quantity,
    String? temperature,
    String? sweetness,
    String? specialNotes,
    DateTime? created,
    DateTime? updated,
    String? productName,
    int? productPrice,
    String? productImage,
    String? productCategory,
  }) {
    return CartModel(
      id: id ?? this.id,
      usersId: usersId ?? this.usersId,
      productsId: productsId ?? this.productsId,
      quantity: quantity ?? this.quantity,
      temperature: temperature ?? this.temperature,
      sweetness: sweetness ?? this.sweetness,
      specialNotes: specialNotes ?? this.specialNotes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      productCategory: productCategory ?? this.productCategory,
    );
  }

  int get totalPrice => (productPrice ?? 0) * quantity;
}
