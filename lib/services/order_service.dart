import 'package:flutter/foundation.dart';
import '../services/pocketbase_service.dart';
import '../models/order_model.dart';

class OrderService {
  final PocketBaseService _pocketbaseService = PocketBaseService();

  // Test connection to PocketBase
  Future<bool> testConnection() async {
    try {
      return _pocketbaseService.isAuthenticated;
    } catch (e) {
      debugPrint('❌ PocketBase connection failed: $e');
      return false;
    }
  }

  // Create a new order
  Future<OrderModel?> createOrder({
    required String usersId,
    required String paymentId,
    required Map<String, dynamic> items,
  }) async {
    try {
      final record = await _pocketbaseService.pb.collection('orders').create(body: {
        'users_id': usersId,
        'payment_id': paymentId,
        'items': items,
      });

      return OrderModel.fromJson(record.toJson());
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      return null;
    }
  }

  // Get orders by user ID
  Future<List<OrderModel>> getOrdersByUserId(String usersId) async {
    try {
      final records = await _pocketbaseService.pb.collection('orders').getList(
        filter: 'users_id = "$usersId"',
        sort: '-created',
      );

      return records.items
          .map((record) => OrderModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching orders by user ID: $e');
      return [];
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final record = await _pocketbaseService.pb.collection('orders').getOne(orderId);
      return OrderModel.fromJson(record.toJson());
    } catch (e) {
      debugPrint('❌ Error fetching order by ID: $e');
      return null;
    }
  }

  // Get orders by payment ID
  Future<List<OrderModel>> getOrdersByPaymentId(String paymentId) async {
    try {
      final records = await _pocketbaseService.pb.collection('orders').getList(
        filter: 'payment_id = "$paymentId"',
        sort: '-created',
      );

      return records.items
          .map((record) => OrderModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching orders by payment ID: $e');
      return [];
    }
  }

  // Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final records = await _pocketbaseService.pb.collection('orders').getList(
        sort: '-created',
      );

      return records.items
          .map((record) => OrderModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching all orders: $e');
      return [];
    }
  }

  // Update order
  Future<OrderModel?> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      final record = await _pocketbaseService.pb.collection('orders').update(orderId, body: data);
      return OrderModel.fromJson(record.toJson());
    } catch (e) {
      debugPrint('❌ Error updating order: $e');
      return null;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _pocketbaseService.pb.collection('orders').delete(orderId);
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting order: $e');
      return false;
    }
  }
}
