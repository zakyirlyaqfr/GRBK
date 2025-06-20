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

  // Create product with improved image handling
  Future<ProductModel> createProduct({
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    String? webImageData,
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
      request.fields['stock'] = 'true';

      debugPrint('Creating product with fields: ${request.fields}');

      // Handle image upload
      if (imageFile != null && !kIsWeb) {
        // Mobile/Desktop platform
        debugPrint('Adding mobile image file: ${imageFile.path}');
        var multipartFile = await http.MultipartFile.fromPath(
          'image', // Make sure this matches your PocketBase schema field name
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
        debugPrint('Mobile image file added successfully');
      } else if (webImageData != null && webImageData.isNotEmpty && kIsWeb) {
        // Web platform
        debugPrint('Processing web image data');
        try {
          // Extract base64 data from data URL
          final RegExp regex = RegExp(r'data:image/([^;]+);base64,');
          final match = regex.firstMatch(webImageData);
          
          if (match != null) {
            final String imageType = match.group(1) ?? 'png';
            final String base64Str = webImageData.replaceAll(regex, '');
            final bytes = base64Decode(base64Str);
            
            final multipartFile = http.MultipartFile.fromBytes(
              'image', // Make sure this matches your PocketBase schema field name
              bytes,
              filename: 'product_${DateTime.now().millisecondsSinceEpoch}.$imageType',
              contentType: MediaType('image', imageType),
            );
            request.files.add(multipartFile);
            debugPrint('Web image added successfully - Size: ${bytes.length} bytes');
          } else {
            debugPrint('Invalid web image data format');
          }
        } catch (e) {
          debugPrint('Error processing web image: $e');
        }
      }

      debugPrint('Sending request to: ${request.url}');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files: ${request.files.length}');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Product created successfully with image: ${data['image']}');
        return ProductModel.fromJson(data);
      } else {
        // Enhanced error handling
        try {
          final errorData = jsonDecode(response.body);
          debugPrint('Error details: $errorData');
          
          // Check for specific field errors
          if (errorData['data'] != null) {
            final fieldErrors = errorData['data'] as Map<String, dynamic>;
            if (fieldErrors['image'] != null) {
              throw Exception('Image upload error: ${fieldErrors['image']['message']}');
            }
          }
          
          throw Exception('Failed to create product: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}');
        } catch (e) {
          if (e.toString().contains('Image upload error')) rethrow;
          throw Exception('Failed to create product: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  // Update product with improved image handling
  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    String? webImageData,
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

      // Handle image upload (same logic as create)
      if (imageFile != null && !kIsWeb) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
        debugPrint('Update: Mobile image file added');
      } else if (webImageData != null && webImageData.isNotEmpty && kIsWeb) {
        try {
          final RegExp regex = RegExp(r'data:image/([^;]+);base64,');
          final match = regex.firstMatch(webImageData);
          
          if (match != null) {
            final String imageType = match.group(1) ?? 'png';
            final String base64Str = webImageData.replaceAll(regex, '');
            final bytes = base64Decode(base64Str);
            
            final multipartFile = http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: 'product_${DateTime.now().millisecondsSinceEpoch}.$imageType',
              contentType: MediaType('image', imageType),
            );
            request.files.add(multipartFile);
            debugPrint('Update: Web image added successfully');
          }
        } catch (e) {
          debugPrint('Error processing web image for update: $e');
        }
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
      rethrow;
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

      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  // Get image URL with improved error handling
  String getImageUrl(ProductModel product) {
    if (product.image == null || product.image!.isEmpty) {
      return '';
    }
    
    // PocketBase file URL format
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

  // Fetch a single product by its ID
  Future<ProductModel?> fetchProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collections/$collection/records/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data);
      } else {
        debugPrint('Failed to fetch product by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      return null;
    }
  }
}
