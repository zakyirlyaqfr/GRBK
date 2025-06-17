import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8090/api';
  static const String collection = 'products';

  // Test connection to PocketBase
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collections/$collection/records'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Get products response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Create product with better error handling
  Future<ProductModel> createProduct({
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/collections/$collection/records'),
      );

      // Add text fields
      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['stock'] = 'true'; // Default stock to true

      debugPrint('Creating product with fields:');
      debugPrint('Name: $name');
      debugPrint('Price: $price');
      debugPrint('Category: $category');
      debugPrint('Description: $description');

      // Add image file if provided
      if (imageFile != null) {
        var imageStream = http.ByteStream(imageFile.openRead());
        var imageLength = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
        debugPrint('Image file added: ${imageFile.path}');
      }

      // Send request
      debugPrint('Sending request to: ${request.url}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Create product response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data);
      } else {
        // Parse error response for better debugging
        try {
          final errorData = jsonDecode(response.body);
          debugPrint('Error details: $errorData');
          throw Exception('Failed to create product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Failed to create product: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
      throw Exception('Error creating product: $e');
    }
  }

  // Update product
  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/collections/$collection/records/$id'),
      );

      // Add text fields
      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      request.fields['description'] = description;

      // Add image file if provided
      if (imageFile != null) {
        var imageStream = http.ByteStream(imageFile.openRead());
        var imageLength = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update product response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception('Failed to update product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Failed to update product: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }

  // Update product stock
  Future<Map<String, dynamic>> updateProductStock(String id, bool stock) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/collections/$collection/records/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'stock': stock}),
      );

      debugPrint('Update stock response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Stock updated successfully'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Failed to update stock'};
      }
    } catch (e) {
      debugPrint('Error updating product stock: $e');
      return {'success': false, 'message': 'Error updating stock: $e'};
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/collections/$collection/records/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Delete product response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return response.statusCode == 204; // PocketBase returns 204 for successful delete
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  // Get image URL
  String getImageUrl(ProductModel product) {
    if (product.image == null || product.image!.isEmpty) {
      return '';
    }
    return '$baseUrl/files/$collection/${product.id}/${product.image}';
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      String filter = category != 'All' ? '?filter=(category="$category")' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/collections/$collection/records$filter&sort=-created'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      throw Exception('Error fetching products by category: $e');
    }
  }

  // Get product statistics
  Future<Map<String, int>> getProductStats() async {
    try {
      final products = await getAllProducts();
      final available = products.where((p) => p.stock).length;
      final unavailable = products.where((p) => !p.stock).length;
      
      return {
        'total': products.length,
        'available': available,
        'unavailable': unavailable,
      };
    } catch (e) {
      debugPrint('Error fetching product stats: $e');
      return {'total': 0, 'available': 0, 'unavailable': 0};
    }
  }
}
