import 'package:flutter/foundation.dart'; // Add this import for debugPrint
// import '../config/app_config.dart'; // Add this import for AppConfig

class Product {
  final String id; // String for PocketBase
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isPopular;
  final double rating;
  final int reviewCount;
  final DateTime? created;
  final DateTime? updated;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isPopular = false,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.created,
    this.updated,
  });

  // Replace the Product.fromJson method in your Product class
  // In your Product class, replace the fromJson method:
  factory Product.fromJson(Map<String, dynamic> json) {
    String id = json['id']?.toString() ?? '';

    // Handle image URL - PocketBase file fields return arrays
    String imageUrl = '';
    if (json.containsKey('imageUrl') && json['imageUrl'] != null) {
      var rawImageUrl = json['imageUrl'];

      // Check if it's an array (PocketBase file field)
      if (rawImageUrl is List && rawImageUrl.isNotEmpty) {
        // Take the first file from the array
        String filename = rawImageUrl[0].toString();
        imageUrl = 'http://127.0.0.1:8090/api/files/products/$id/$filename';
      }
      // If it's already a string
      else if (rawImageUrl is String && rawImageUrl.isNotEmpty) {
        imageUrl = 'http://127.0.0.1:8090/api/files/products/$id/$rawImageUrl';
      }

      debugPrint('=== IMAGE URL DEBUG ===');
      debugPrint('Raw imageUrl: $rawImageUrl');
      debugPrint('Constructed URL: $imageUrl');
      debugPrint('=====================');
    }

    return Product(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      imageUrl: imageUrl,
      category: json['category']?.toString() ?? '',
      isPopular: json['isPopular'] == true,
      rating: _parseDouble(json['rating'], defaultValue: 4.5),
      reviewCount: _parseInt(json['reviewCount']),
      created: json['created'] != null ? _parseDateTime(json['created']) : null,
      updated: json['updated'] != null ? _parseDateTime(json['updated']) : null,
    );
  }
  // Helper method to safely parse double values
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Helper method to safely parse int values
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Helper method to safely parse DateTime values
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Method untuk convert Product ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isPopular': isPopular,
      'rating': rating,
      'reviewCount': reviewCount,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  // Method untuk membuat copy dengan perubahan
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isPopular,
    double? rating,
    int? reviewCount,
    DateTime? created,
    DateTime? updated,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
