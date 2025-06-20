class OrderModel {
  final String id;
  final String usersId;
  final String paymentId;
  final Map<String, dynamic> items;
  final DateTime created;
  final DateTime updated;

  OrderModel({
    required this.id,
    required this.usersId,
    required this.paymentId,
    required this.items,
    required this.created,
    required this.updated,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      usersId: json['users_id'] ?? '',
      paymentId: json['payment_id'] ?? '',
      items: json['items'] ?? {},
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users_id': usersId,
      'payment_id': paymentId,
      'items': items,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, usersId: $usersId, paymentId: $paymentId, items: $items, created: $created, updated: $updated)';
  }
}
