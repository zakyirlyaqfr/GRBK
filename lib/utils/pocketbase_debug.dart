import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PocketBaseDebug {
  static const String baseUrl = 'http://127.0.0.1:8090';
  
  static Future<void> debugPocketBase() async {
    debugPrint('=== PocketBase Debug Info ===');
    
    // Test basic connection
    await _testConnection();
    
    // List collections
    await _listCollections();
    
    // Test specific collection
    await _testCollection('payment');
    await _testCollection('users');
    await _testCollection('cart');
    await _testCollection('products');
    
    debugPrint('=== End Debug Info ===');
  }
  
  static Future<void> _testConnection() async {
    try {
      debugPrint('Testing connection to: $baseUrl');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      debugPrint('Health check - Status: ${response.statusCode}');
      debugPrint('Health check - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ PocketBase is running');
      } else {
        debugPrint('❌ PocketBase health check failed');
      }
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
    }
  }
  
  static Future<void> _listCollections() async {
    try {
      debugPrint('Listing collections...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/collections'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      debugPrint('Collections - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final collections = data['items'] as List;
        debugPrint('✅ Found ${collections.length} collections:');
        for (var collection in collections) {
          debugPrint('  - ${collection['name']} (${collection['type']})');
        }
      } else {
        debugPrint('❌ Failed to list collections: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error listing collections: $e');
    }
  }
  
  static Future<void> _testCollection(String collectionName) async {
    try {
      debugPrint('Testing collection: $collectionName');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/$collectionName/records?page=1&perPage=1'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      debugPrint('$collectionName - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ $collectionName collection accessible (${data['totalItems']} items)');
      } else {
        debugPrint('❌ $collectionName collection error: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error testing $collectionName: $e');
    }
  }
}
