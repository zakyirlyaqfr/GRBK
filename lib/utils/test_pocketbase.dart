import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../services/pocketbase_service.dart';
import '../services/payment_service.dart';
import '../models/cart_model.dart';

class TestPocketBase {
  static const String baseUrl = 'http://127.0.0.1:8090';
  
  static Future<void> runTests() async {
    debugPrint('🧪 Running PocketBase Tests...');
    
    // Test 1: Basic connection
    await _testBasicConnection();
    
    // Test 2: List users
    await _testListUsers();
    
    // Test 3: Get or create test user
    final userId = await _testGetOrCreateUser();
    
    // Test 4: Create a test payment with proper user ID
    if (userId != null) {
      await _testCreatePaymentWithValidUser(userId);
    }
    
    debugPrint('🧪 Tests completed');
  }
  
  static Future<void> _testBasicConnection() async {
    try {
      debugPrint('Test 1: Basic connection');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ Connection successful');
      } else {
        debugPrint('❌ Connection failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Connection error: $e');
    }
  }
  
  static Future<void> _testListUsers() async {
    try {
      debugPrint('Test 2: List existing users');

      final userService = PocketBaseService();
      final users = await userService.getUsers();
      
      if (users.isNotEmpty) {
        debugPrint('✅ Found ${users.length} users');
      } else {
        debugPrint('⚠️ No users found');
      }
    } catch (e) {
      debugPrint('❌ Error listing users: $e');
    }
  }
  
  static Future<String?> _testGetOrCreateUser() async {
    try {
      debugPrint('Test 3: Get or create test user');

      final userService = PocketBaseService();
      // You must implement or use a method that returns a user ID.
      // For example, if you have getOrCreateTestUser():
      final userId = await userService.getOrCreateTestUser();

      if (userId != null) {
        debugPrint('✅ Test user ready: $userId');
        return userId;
      } else {
        debugPrint('❌ Failed to get/create test user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error with test user: $e');
      return null;
    }
  }
  
  static Future<void> _testCreatePaymentWithValidUser(String userId) async {
    try {
      debugPrint('Test 4: Create test payment with valid user');
      
      // Create mock cart items with the valid user ID
      final mockCartItems = [
        CartModel(
          id: 'mock_cart_1',
          usersId: userId,
          productsId: 'mock_product_1',
          productName: 'Test Coffee',
          productPrice: 15000,
          quantity: 1,
          temperature: 'Hot',
          sweetness: 'Normal',
          specialNotes: 'Test order',
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
        CartModel(
          id: 'mock_cart_2',
          usersId: userId,
          productsId: 'mock_product_2',
          productName: 'Test Pastry',
          productPrice: 10000,
          quantity: 2,
          temperature: '',
          sweetness: '',
          specialNotes: '',
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      ];
      
      final paymentService = PaymentService();
      final payment = await paymentService.createPaymentFromCart(
        cartItems: mockCartItems,
      );
      
      if (payment != null) {
        debugPrint('✅ Payment creation successful');
        debugPrint('Created payment ID: ${payment.id}');
        debugPrint('Payment total: ${payment.totalPrice}');
        debugPrint('Payment items: ${payment.totalItems}');
      } else {
        debugPrint('❌ Payment creation failed');
      }
    } catch (e) {
      debugPrint('❌ Payment creation error: $e');
    }
  }
}
