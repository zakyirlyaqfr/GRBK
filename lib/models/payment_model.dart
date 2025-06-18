class PaymentModel {
  final String id;
  final String userId;
  final String userName;
  final int totalPrice;
  final int totalItems;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime created;
  final DateTime updated;
  final List<PaymentItem> items;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalPrice,
    required this.totalItems,
    required this.status,
    required this.created,
    required this.updated,
    required this.items,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['users_id'] ?? '',
      userName: json['expand']?['users_id']?['name'] ?? '',
      totalPrice: json['total_price'] ?? 0,
      totalItems: json['total_items'] ?? 0,
      status: json['status'] ?? 'pending',
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => PaymentItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users_id': userId,
      'total_price': totalPrice,
      'total_items': totalItems,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PaymentItem {
  final String productId;
  final String productName;
  final int productPrice;
  final int quantity;
  final String temperature;
  final String sweetness;
  final String specialNotes;
  final int totalPrice;

  PaymentItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.temperature,
    required this.sweetness,
    required this.specialNotes,
    required this.totalPrice,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productPrice: json['product_price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      temperature: json['temperature'] ?? '',
      sweetness: json['sweetness'] ?? '',
      specialNotes: json['special_notes'] ?? '',
      totalPrice: json['total_price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'temperature': temperature,
      'sweetness': sweetness,
      'special_notes': specialNotes,
      'total_price': totalPrice,
    };
  }
}
