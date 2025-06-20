import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../models/cart_model.dart';
import 'pocketbase_service.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final PocketBaseService _pocketBaseService = PocketBaseService();
  // ignore: unused_field
  final PocketBaseService _userService = PocketBaseService();

  // Create payment from cart items
  Future<PaymentModel?> createPaymentFromCart({
    required List<CartModel> cartItems,
  }) async {
    try {
      if (cartItems.isEmpty) {
        debugPrint('Error: Cannot create payment with empty cart');
        return null;
      }

      // Extract and validate user IDs from cart items
      final userIds = cartItems.map((item) => item.usersId).toSet();
      
      if (userIds.isEmpty) {
        debugPrint('Error: No user IDs found in cart items');
        return null;
      }
      
      if (userIds.length > 1) {
        debugPrint('Error: Cart items belong to multiple users: $userIds');
        debugPrint('Cannot create a single payment for multiple users');
        return null;
      }
      
      final userId = userIds.first;
      debugPrint('Creating payment for user: $userId');
      
      // Validate that the user exists
      final isValidUser = await _validateUserExists(userId);
      if (!isValidUser) {
        debugPrint('Error: User $userId does not exist in users collection');
        return null;
      }
      
      // Calculate totals
      int totalPrice = 0;
      int totalItems = 0;
      
      List<PaymentItem> paymentItems = cartItems.map((cartItem) {
        totalPrice += cartItem.totalPrice;
        totalItems += cartItem.quantity;
        return PaymentItem(
          productId: cartItem.productsId,
          productName: cartItem.productName ?? 'Unknown Product',
          productPrice: cartItem.productPrice ?? 0,
          quantity: cartItem.quantity,
          temperature: cartItem.temperature,
          sweetness: cartItem.sweetness,
          specialNotes: cartItem.specialNotes,
          totalPrice: cartItem.totalPrice,
        );
      }).toList();

      final paymentData = {
        'users_id': userId,
        'total_price': totalPrice,
        'total_items': totalItems,
        'status': false, // Boolean: false = pending, true = confirmed
        'items': paymentItems.map((item) => item.toJson()).toList(),
      };

      debugPrint('Creating payment with data: ${jsonEncode(paymentData)}');
      
      // Use correct collection name - check if it's 'payment' or 'payments'
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records';
      debugPrint('API URL: $apiUrl');

      final headers = await _getAuthHeaders();
      debugPrint('Request headers: ${headers.keys.join(', ')}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(paymentData),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final payment = PaymentModel.fromJson(responseData);
        
        // Update cart items with payment_id after successful payment creation
        await _updateCartItemsWithPaymentId(cartItems, payment.id);
        
        return payment;
      } else {
        debugPrint('Error creating payment: ${response.body}');
        _handleApiError(response);
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating payment: $e');
      return null;
    }
  }
  
  // Update cart items with payment_id after payment creation
  Future<void> _updateCartItemsWithPaymentId(List<CartModel> cartItems, String paymentId) async {
    try {
      debugPrint('Updating ${cartItems.length} cart items with payment_id: $paymentId');
      
      final headers = await _getAuthHeaders();
      
      for (final cartItem in cartItems) {
        final updateData = {
          'payment_id': paymentId,
        };
        
        final response = await http.patch(
          Uri.parse('${PocketBaseService.baseUrl}/api/collections/cart/records/${cartItem.id}'),
          headers: headers,
          body: jsonEncode(updateData),
        );
        
        if (response.statusCode == 200) {
          debugPrint('✅ Updated cart item ${cartItem.id} with payment_id');
        } else {
          debugPrint('❌ Failed to update cart item ${cartItem.id}: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Exception updating cart items with payment_id: $e');
    }
  }
  
  // Validate that a user exists in the users collection
  Future<bool> _validateUserExists(String userId) async {
    try {
      debugPrint('Validating user exists: $userId');
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/collections/users/records/$userId'),
        headers: headers,
      );
      
      debugPrint('User validation status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ User $userId exists');
        return true;
      } else if (response.statusCode == 404) {
        debugPrint('❌ User $userId not found');
        return false;
      } else {
        debugPrint('❌ Error validating user: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception validating user: $e');
      return false;
    }
  }
  
  // Get the correct collection name for payments
  Future<String> _getCorrectCollectionName() async {
    try {
      // Try both 'payment' and 'payments' to see which exists
      final headers = await _getAuthHeaders();
      
      // First try 'payment'
      final paymentResponse = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/collections/payment/records?page=1&perPage=1'),
        headers: headers,
      );
      
      if (paymentResponse.statusCode == 200) {
        debugPrint('Using collection name: payment');
        return 'payment';
      }
      
      // Then try 'payments'
      final paymentsResponse = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/collections/payments/records?page=1&perPage=1'),
        headers: headers,
      );
      
      if (paymentsResponse.statusCode == 200) {
        debugPrint('Using collection name: payments');
        return 'payments';
      }
      
      // Default to 'payment' if both fail
      debugPrint('Could not determine collection name, defaulting to: payment');
      return 'payment';
    } catch (e) {
      debugPrint('Error determining collection name: $e');
      return 'payment';
    }
  }
  
  // Get properly formatted auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    // Try to get auth token
    final authToken = _pocketBaseService.authToken;
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
      debugPrint('Added auth token to headers');
    } else {
      debugPrint('No auth token available - making unauthenticated request');
    }
    
    return headers;
  }
  
  // Handle API errors with detailed logging
  void _handleApiError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        debugPrint('❌ Bad Request (400): Invalid data sent to server');
        break;
      case 401:
        debugPrint('❌ Unauthorized (401): Invalid or missing authentication token');
        break;
      case 403:
        debugPrint('❌ Forbidden (403): Insufficient permissions');
        break;
      case 404:
        debugPrint('❌ Not Found (404): Collection or record not found');
        break;
      case 422:
        debugPrint('❌ Unprocessable Entity (422): Validation failed');
        break;
      default:
        debugPrint('❌ HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      debugPrint('Getting payment by ID: $paymentId');
      
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records/$paymentId?expand=users_id';
      debugPrint('API URL: $apiUrl');

      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PaymentModel.fromJson(responseData);
      } else {
        debugPrint('Error getting payment: ${response.body}');
        _handleApiError(response);
        return null;
      }
    } catch (e) {
      debugPrint('Exception getting payment: $e');
      return null;
    }
  }

  // Update payment status - now accepts boolean
  Future<bool> updatePaymentStatus(String paymentId, bool status) async {
    try {
      debugPrint('Updating payment status: $paymentId to $status');
      
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records/$paymentId';
      debugPrint('API URL: $apiUrl');

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({'status': status}), // Boolean value
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If payment is confirmed (status = true), clear cart items
        if (status == true) {
          debugPrint('Payment confirmed, clearing cart items...');
          await clearCartForPayment(paymentId);
        }
        return true;
      } else {
        debugPrint('Error updating payment status: ${response.body}');
        _handleApiError(response);
        return false;
      }
    } catch (e) {
      debugPrint('Exception updating payment status: $e');
      return false;
    }
  }

  // Clear cart items for a specific payment when confirmed
  Future<bool> clearCartForPayment(String paymentId) async {
    try {
      debugPrint('Clearing cart items for payment: $paymentId');
      
      final headers = await _getAuthHeaders();
      
      // First, get all cart items with this payment_id
      final getResponse = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/collections/cart/records?filter=(payment_id="$paymentId")'),
        headers: headers,
      );
      
      if (getResponse.statusCode == 200) {
        final responseData = jsonDecode(getResponse.body);
        final List<dynamic> cartItems = responseData['items'] ?? [];
        
        debugPrint('Found ${cartItems.length} cart items to delete for payment $paymentId');
        
        // Delete each cart item
        int deletedCount = 0;
        for (final item in cartItems) {
          final itemId = item['id'];
          final deleteResponse = await http.delete(
            Uri.parse('${PocketBaseService.baseUrl}/api/collections/cart/records/$itemId'),
            headers: headers,
          );
          
          if (deleteResponse.statusCode == 204) {
            deletedCount++;
            debugPrint('✅ Deleted cart item: $itemId');
          } else {
            debugPrint('❌ Failed to delete cart item $itemId: ${deleteResponse.body}');
          }
        }
        
        debugPrint('Successfully deleted $deletedCount out of ${cartItems.length} cart items');
        return deletedCount == cartItems.length;
      } else {
        debugPrint('Error getting cart items for payment: ${getResponse.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception clearing cart for payment: $e');
      return false;
    }
  }

  // Get payments by user ID
  Future<List<PaymentModel>> getPaymentsByUserId(String userId) async {
    try {
      // Validate user exists first
      final isValidUser = await _validateUserExists(userId);
      if (!isValidUser) {
        debugPrint('Invalid user ID for getting payments: $userId');
        return [];
      }
      
      debugPrint('Getting payments for user: $userId');
      
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records?filter=(users_id="$userId")&expand=users_id&sort=-created';
      debugPrint('API URL: $apiUrl');

      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];
        return items.map((item) => PaymentModel.fromJson(item)).toList();
      } else {
        debugPrint('Error getting payments: ${response.body}');
        _handleApiError(response);
        return [];
      }
    } catch (e) {
      debugPrint('Exception getting payments: $e');
      return [];
    }
  }

  // Get all payments
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records?sort=-created';
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> items = responseData['items'] ?? [];
        return items.map((item) => PaymentModel.fromJson(item)).toList();
      } else {
        debugPrint('Error getting all payments: ${response.body}');
        _handleApiError(response);
        return [];
      }
    } catch (e) {
      debugPrint('Exception getting all payments: $e');
      return [];
    }
  }

  // Create payment (not from cart, but from provided data)
  Future<PaymentModel?> createPayment({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalItems,
    required int totalPrice,
  }) async {
    try {
      final collectionName = await _getCorrectCollectionName();
      final apiUrl = '${PocketBaseService.baseUrl}/api/collections/$collectionName/records';
      final headers = await _getAuthHeaders();

      final paymentData = {
        'users_id': userId,
        'total_price': totalPrice,
        'total_items': totalItems,
        'status': false,
        'items': items,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PaymentModel.fromJson(responseData);
      } else {
        debugPrint('Error creating payment: ${response.body}');
        _handleApiError(response);
        return null;
      }
    } catch (e) {
      debugPrint('Exception creating payment: $e');
      return null;
    }
  }

  // Test connection to PocketBase
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing PocketBase connection...');
      debugPrint('Base URL: ${PocketBaseService.baseUrl}');

      final response = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/health'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Health check status: ${response.statusCode}');
      debugPrint('Health check body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error testing connection: $e');
      return false;
    }
  }

  // List all collections (for debugging)
  Future<void> listCollections() async {
    try {
      debugPrint('Listing collections...');
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${PocketBaseService.baseUrl}/api/collections'),
        headers: headers,
      );

      debugPrint('Collections response status: ${response.statusCode}');
      debugPrint('Collections response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final collections = data['items'] as List;
        debugPrint('✅ Found ${collections.length} collections:');
        for (var collection in collections) {
          debugPrint('  - ${collection['name']} (${collection['type']})');
        }
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      debugPrint('Error listing collections: $e');
    }
  }
  
  // Create multiple payments for different users (if needed)
  Future<List<PaymentModel>> createPaymentsFromMultiUserCart({
    required List<CartModel> cartItems,
  }) async {
    try {
      if (cartItems.isEmpty) {
        debugPrint('Error: Cannot create payments with empty cart');
        return [];
      }

      // Group cart items by user ID
      final Map<String, List<CartModel>> itemsByUser = {};
      for (final item in cartItems) {
        if (!itemsByUser.containsKey(item.usersId)) {
          itemsByUser[item.usersId] = [];
        }
        itemsByUser[item.usersId]!.add(item);
      }

      debugPrint('Creating payments for ${itemsByUser.length} users');

      final List<PaymentModel> payments = [];
      
      // Create a payment for each user
      for (final entry in itemsByUser.entries) {
        final userId = entry.key;
        final userItems = entry.value;
        
        debugPrint('Creating payment for user $userId with ${userItems.length} items');
        
        final payment = await createPaymentFromCart(cartItems: userItems);
        if (payment != null) {
          payments.add(payment);
        } else {
          debugPrint('Failed to create payment for user $userId');
        }
      }

      return payments;
    } catch (e) {
      debugPrint('Exception creating multi-user payments: $e');
      return [];
    }
  }
}
