import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/api_response.dart';
import '../config/app_config.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  // Headers untuk request
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Initialize service
  Future<void> initialize() async {
    await _loadAuthToken();
  }

  // Load auth token from SharedPreferences
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Save auth token to SharedPreferences
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _authToken = token;
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  // Generic HTTP request method
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      http.Response response;
      final uri = Uri.parse(url);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers)
              .timeout(AppConfig.connectionTimeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectionTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectionTimeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.connectionTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers)
              .timeout(AppConfig.connectionTimeout);
          break;
        default:
          throw ApiException.unknown('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format');
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          final result = fromJson(data);
          return ApiResponse.success(result, statusCode: statusCode);
        } else {
          return ApiResponse.success(data as T, statusCode: statusCode);
        }
      } else {
        final message = data['message'] ?? 'Request failed';
        return ApiResponse.error(message, statusCode: statusCode, errors: data);
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: ${e.toString()}',
        statusCode: statusCode,
      );
    }
  }

  // Authentication: Login user
  Future<ApiResponse<Map<String, dynamic>>> login(
      String email, String password) async {
    try {
      const url =
          '${AppConfig.pocketBaseUrl}/api/collections/users/auth-with-password';
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        url,
        body: {
          'identity': email,
          'password': password,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String?;
        if (token != null) {
          await _saveAuthToken(token);
        }
        return response;
      } else {
        throw Exception(response.message ?? 'Login failed');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error during login: $e');
      }
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  // Authentication: Signup user
  Future<ApiResponse<Map<String, dynamic>>> signup({
    required String email,
    required String password,
    required String passwordConfirm,
    String? name,
  }) async {
    try {
      const url = '${AppConfig.pocketBaseUrl}/api/collections/users/records';
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        url,
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'name': name ?? '',
        },
        fromJson: (json) => json,
      );

      if (response.success) {
        return await login(email, password); // Auto-login after signup
      } else {
        throw Exception(response.message ?? 'Signup failed');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error during signup: $e');
      }
      return ApiResponse.error('Signup failed: ${e.toString()}');
    }
  }

  // Get all products - FIXED METHOD
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 50,
    String? category,
    String? search,
    bool? isPopular,
  }) async {
    try {
      String url = '${AppConfig.productsUrl}?page=$page&perPage=$perPage';

      // Add filters
      List<String> filters = [];
      if (category != null && category != 'All') {
        filters.add('category="$category"');
      }
      if (search != null && search.isNotEmpty) {
        filters.add('name~"$search"');
      }
      if (isPopular != null) {
        filters.add('isPopular=$isPopular');
      }

      if (filters.isNotEmpty) {
        url += '&filter=${filters.join(' && ')}';
      }

      // Add sorting
      url += '&sort=-created';

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>;

        // Properly convert each item to a Product
        return items.map((item) {
          // Make sure item is a Map<String, dynamic> before conversion
          if (item is Map<String, dynamic>) {
            return Product.fromJson(item);
          } else {
            throw const FormatException('Invalid product data format');
          }
        }).toList();
      } else {
        throw Exception('Failed to load products: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error loading products: $e');
      }
      throw Exception('Failed to load products: $e');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final url = '${AppConfig.productsUrl}/$id';

      final response = await _makeRequest<Product>(
        'GET',
        url,
        fromJson: (json) => Product.fromJson(json),
      );

      if (response.success) {
        return response.data;
      } else {
        throw Exception(response.message ?? 'Product not found');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error loading product: $e');
      }
      rethrow;
    }
  }

  // Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      final url = AppConfig.productsUrl;
      final response = await _makeRequest<Product>(
        'POST',
        url,
        body: product.toJson(),
        fromJson: (json) => Product.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to create product');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error creating product: $e');
      }
      rethrow;
    }
  }

  // Update an existing product
  Future<Product> updateProduct(String id, Product product) async {
    try {
      final url = '${AppConfig.productsUrl}/$id';
      final response = await _makeRequest<Product>(
        'PATCH',
        url,
        body: product.toJson(),
        fromJson: (json) => Product.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to update product');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error updating product: $e');
      }
      rethrow;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String id) async {
    try {
      final url = '${AppConfig.productsUrl}/$id';
      final response = await _makeRequest<Map<String, dynamic>>(
        'DELETE',
        url,
        fromJson: (json) => json,
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message ?? 'Failed to delete product');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Error deleting product: $e');
      }
      rethrow;
    }
  }

  // Get popular products
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    return getProducts(isPopular: true, perPage: limit);
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return getProducts(category: category);
  }

  // Test connection to PocketBase
  Future<bool> testConnection() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.pocketBaseUrl}/api/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.enableLogging) {
        debugPrint('Connection test failed: $e');
      }
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }

  // Add this to your PocketBaseService class
  Future<bool> testImageUrl(String url) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Image URL test: $url - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Image URL test failed: $url - Error: $e');
      return false;
    }
  }
}
