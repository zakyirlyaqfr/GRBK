import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_model.dart';
import 'pocketbase_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class CartService {
  static const String baseUrl = 'http://127.0.0.1:8090'; // Replace with your PocketBase URL
  static const String collection = 'cart';
  
  // Get PocketBase service instance
  static final PocketBaseService _pocketBaseService = PocketBaseService();

  // Validate if user exists and is authenticated
  static Future<String?> _getValidUserId() async {
    if (!_pocketBaseService.isAuthenticated || _pocketBaseService.currentUser == null) {
      throw Exception('User not authenticated. Please login first.');
    }
    
    final userId = _pocketBaseService.currentUser!.id;
    
    // Verify user exists in database
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_pocketBaseService.authToken}',
        },
      );
      
      if (response.statusCode == 200) {
        return userId;
      } else {
        throw Exception('User not found in database');
      }
    } catch (e) {
      throw Exception('Error validating user: $e');
    }
  }

  // Get authenticated headers
  static Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_pocketBaseService.authToken != null) 
        'Authorization': 'Bearer ${_pocketBaseService.authToken}',
    };
  }

  // Get all cart items for the authenticated user with product details
  static Future<List<CartModel>> getCartItems() async {
    try {
      final userId = await _getValidUserId();
      if (userId == null) {
        throw Exception('Invalid user ID');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/$collection/records?filter=users_id="$userId"&expand=products_id'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => CartModel.fromJson(item)).toList();
      } else {
        debugPrint('Error details: ${response.body}');
        throw Exception('Failed to load cart items: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }

  // Validate product exists
  static Future<bool> _validateProduct(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/products/records/$productId'),
        headers: _getAuthHeaders(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Add item to cart
  static Future<CartModel> addToCart({
    required String productId,
    required int quantity,
    required String temperature,
    required String sweetness,
    required String specialNotes,
  }) async {
    try {
      // Validate user authentication
      final userId = await _getValidUserId();
      if (userId == null) {
        throw Exception('Invalid user ID');
      }

      // Validate product exists
      final productExists = await _validateProduct(productId);
      if (!productExists) {
        throw Exception('Product not found');
      }

      // Check if item already exists in cart
      final existingItems = await getCartItems();
      final existingItem = existingItems.where((item) => 
        item.productsId == productId && 
        item.temperature == temperature && 
        item.sweetness == sweetness &&
        item.specialNotes == specialNotes
      ).firstOrNull;

      if (existingItem != null) {
        // Update existing item quantity
        return await updateCartItem(
          existingItem.id, 
          existingItem.quantity + quantity
        );
      } else {
        // Create new cart item
        final cartData = {
          'users_id': userId,
          'products_id': productId,
          'quantity': quantity,
          'temperature': temperature,
          'sweetness': sweetness,
          'special_notes': specialNotes,
        };

        debugPrint('Creating cart item with data: $cartData'); // Debug log

        final response = await http.post(
          Uri.parse('$baseUrl/api/collections/$collection/records'),
          headers: _getAuthHeaders(),
          body: json.encode(cartData),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Fetch the created item with expanded product details
          final expandedResponse = await http.get(
            Uri.parse('$baseUrl/api/collections/$collection/records/${data['id']}?expand=products_id'),
            headers: _getAuthHeaders(),
          );

          if (expandedResponse.statusCode == 200) {
            final expandedData = json.decode(expandedResponse.body);
            return CartModel.fromJson(expandedData);
          } else {
            debugPrint('Error details: ${expandedResponse.body}');
            return CartModel.fromJson(data);
          }
        } else {
          debugPrint('Error details: ${response.body}');
          throw Exception('Failed to add item to cart: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error adding item to cart: $e');
    }
  }

  // Update cart item quantity
  static Future<CartModel> updateCartItem(String cartId, int newQuantity) async {
    try {
      // Validate user authentication
      await _getValidUserId();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/collections/$collection/records/$cartId'),
        headers: _getAuthHeaders(),
        body: json.encode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Fetch updated item with expanded product details
        final expandedResponse = await http.get(
          Uri.parse('$baseUrl/api/collections/$collection/records/$cartId?expand=products_id'),
          headers: _getAuthHeaders(),
        );

        if (expandedResponse.statusCode == 200) {
          final expandedData = json.decode(expandedResponse.body);
          return CartModel.fromJson(expandedData);
        } else {
          debugPrint('Error details: ${expandedResponse.body}');
          return CartModel.fromJson(data);
        }
      } else {
        debugPrint('Error details: ${response.body}');
        throw Exception('Failed to update cart item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String cartId) async {
    try {
      // Validate user authentication
      await _getValidUserId();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/collections/$collection/records/$cartId'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode != 204) {
        debugPrint('Error details: ${response.body}');
        throw Exception('Failed to remove item from cart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error removing item from cart: $e');
    }
  }

  // Clear all cart items for the authenticated user
  static Future<void> clearCart() async {
    try {
      final cartItems = await getCartItems();
      
      for (final item in cartItems) {
        await removeFromCart(item.id);
      }
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  // Get cart item count for a specific product for the authenticated user
  static Future<int> getProductQuantityInCart(String productId) async {
    try {
      final cartItems = await getCartItems();
      return cartItems
          .where((item) => item.productsId == productId)
          .fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      debugPrint('Error getting product quantity in cart: $e');
      return 0;
    }
  }
}
