import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/pocketbase_service.dart';

class OrderProvider with ChangeNotifier {
  final PocketBaseService _pocketbaseService = PocketBaseService();
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<OrderModel?> createOrder({
    required String usersId,
    required String paymentId,
    required Map<String, dynamic> items,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔄 Creating order for user: $usersId, payment: $paymentId');
      debugPrint('📦 Order items: $items');

      // Validate required data
      if (usersId.isEmpty) {
        throw Exception('User ID is required');
      }
      if (paymentId.isEmpty) {
        throw Exception('Payment ID is required');
      }
      if (items.isEmpty) {
        throw Exception('Order items are required');
      }

      // Validate items structure
      final itemsList = items['items'] as List<dynamic>? ?? [];
      if (itemsList.isEmpty) {
        throw Exception('Order must contain at least one item');
      }

      // Validate each item has required fields
      for (int i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid item format at index $i');
        }
        
        final productName = item['product_name'] ?? item['productName'];
        final productPrice = item['product_price'] ?? item['productPrice'];
        final quantity = item['quantity'];
        
        if (productName == null || productName.toString().isEmpty) {
          debugPrint('⚠️ Item $i missing product name, using default');
          item['product_name'] = 'Unknown Product';
        }
        
        if (productPrice == null) {
          debugPrint('⚠️ Item $i missing product price, using 0');
          item['product_price'] = 0;
        }
        
        if (quantity == null || quantity <= 0) {
          debugPrint('⚠️ Item $i missing or invalid quantity, using 1');
          item['quantity'] = 1;
        }
        
        // Ensure total_price is calculated if missing
        if (item['total_price'] == null && item['totalPrice'] == null) {
          final price = item['product_price'] ?? item['productPrice'] ?? 0;
          final qty = item['quantity'] ?? 1;
          item['total_price'] = price * qty;
          debugPrint('📊 Calculated total_price for item $i: ${item['total_price']}');
        }
      }

      // Check if user is authenticated
      if (!_pocketbaseService.isAuthenticated) {
        debugPrint('❌ User not authenticated, attempting to authenticate...');
        throw Exception('User must be authenticated to create orders');
      }

      debugPrint('✅ User is authenticated: ${_pocketbaseService.authToken != null}');
      debugPrint('✅ Data validation passed');

      // Prepare order data with validated items
      final orderData = {
        'users_id': usersId,
        'payment_id': paymentId,
        'items': items, // This now contains validated items
        'created': DateTime.now().toIso8601String(),
      };

      debugPrint('📝 Order data to be created: $orderData');

      try {
        // Create order in database
        final record = await _pocketbaseService.pb.collection('orders').create(body: orderData);
        
        debugPrint('✅ Order created successfully with ID: ${record.id}');

        // Convert to OrderModel
        final order = OrderModel.fromJson(record.toJson());
        
        // Add to local list
        _orders.insert(0, order);
        
        notifyListeners();
        return order;

      } catch (e) {
        // Handle specific PocketBase errors
        if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
          throw Exception('Permission denied: Please check PocketBase collection permissions for "orders". The collection may require authentication or have restrictive rules.');
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          throw Exception('Authentication required: Please ensure user is logged in.');
        } else if (e.toString().contains('404')) {
          throw Exception('Orders collection not found: Please ensure the "orders" collection exists in PocketBase.');
        } else {
          throw Exception('Database error: ${e.toString()}');
        }
      }

    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      _setError('Failed to create order: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllOrders() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔄 Loading all orders...');

      if (!_pocketbaseService.isAuthenticated) {
        throw Exception('Authentication required to load orders');
      }

      final records = await _pocketbaseService.pb
          .collection('orders')
          .getFullList(
            sort: '-created',
            expand: 'users_id,payment_id',
          );

      _orders = records.map((record) => OrderModel.fromJson(record.toJson())).toList();
      
      debugPrint('✅ Loaded ${_orders.length} orders');
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Error loading orders: $e');
      _setError('Failed to load orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrdersByUserId(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔄 Loading orders for user: $userId');

      if (!_pocketbaseService.isAuthenticated) {
        throw Exception('Authentication required to load orders');
      }

      final records = await _pocketbaseService.pb
          .collection('orders')
          .getFullList(
            filter: 'users_id = "$userId"',
            sort: '-created',
            expand: 'users_id,payment_id',
          );

      _orders = records.map((record) => OrderModel.fromJson(record.toJson())).toList();
      
      debugPrint('✅ Loaded ${_orders.length} orders for user: $userId');
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Error loading user orders: $e');
      _setError('Failed to load user orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      debugPrint('🔄 Getting order by ID: $orderId');

      if (!_pocketbaseService.isAuthenticated) {
        throw Exception('Authentication required to get order');
      }

      final record = await _pocketbaseService.pb
          .collection('orders')
          .getOne(orderId, expand: 'users_id,payment_id');

      final order = OrderModel.fromJson(record.toJson());
      
      debugPrint('✅ Found order: ${order.id}');
      return order;

    } catch (e) {
      debugPrint('❌ Error getting order: $e');
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
