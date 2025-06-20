import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../models/cart_model.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;
  
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all payments
  Future<void> loadAllPayments() async {
    try {
      _setLoading(true);
      _clearError();

      final payments = await _paymentService.getAllPayments();
      _payments = payments;
      
      debugPrint('✅ Loaded ${payments.length} total payments');
    } catch (e) {
      _setError('Error loading all payments: $e');
      debugPrint('❌ Error in loadAllPayments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create payment
  Future<PaymentModel?> createPayment({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalItems,
    required double totalPrice,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final payment = await _paymentService.createPayment(
        userId: userId,
        items: items,
        totalItems: totalItems,
        totalPrice: totalPrice.toInt(),
      );

      if (payment != null) {
        _payments.insert(0, payment);
        debugPrint('✅ Payment created successfully: ${payment.id}');
      } else {
        _setError('Failed to create payment');
      }

      return payment;
    } catch (e) {
      _setError('Error creating payment: $e');
      debugPrint('❌ Error in createPayment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Create payment from cart items
  Future<PaymentModel?> createPaymentFromCart({
    required List<CartModel> cartItems,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      debugPrint('PaymentProvider: Creating payment from ${cartItems.length} cart items');
      
      if (cartItems.isEmpty) {
        _setError('Cannot create payment with empty cart');
        return null;
      }
      
      final userIds = cartItems.map((item) => item.usersId).toSet();
      if (userIds.isEmpty) {
        _setError('Cart items missing user IDs');
        return null;
      }
      
      if (userIds.length > 1) {
        _setError('Cart contains items from multiple users. Cannot create single payment.');
        debugPrint('Multiple users detected: $userIds');
        return null;
      }
      
      final userId = userIds.first;
      debugPrint('PaymentProvider: Creating payment for user $userId');
      
      final payment = await _paymentService.createPaymentFromCart(
        cartItems: cartItems,
      );
      
      if (payment != null) {
        _payments.insert(0, payment);
        notifyListeners();
        debugPrint('PaymentProvider: Payment created successfully with ID ${payment.id}');
      } else {
        _setError('Failed to create payment');
      }
      
      return payment;
    } catch (e) {
      debugPrint('PaymentProvider error creating payment: $e');
      _setError('Error creating payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      debugPrint('PaymentProvider: Getting payment by ID $paymentId');
      
      final payment = await _paymentService.getPaymentById(paymentId);
      
      if (payment != null) {
        final index = _payments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _payments[index] = payment;
          notifyListeners();
        }
      }
      
      return payment;
    } catch (e) {
      debugPrint('PaymentProvider error getting payment: $e');
      return null;
    }
  }
  
  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, bool status) async {
    try {
      debugPrint('PaymentProvider: Updating payment $paymentId status to $status');
      
      final success = await _paymentService.updatePaymentStatus(paymentId, status);
      
      if (success) {
        final index = _payments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          final updatedPayment = PaymentModel(
            id: _payments[index].id,
            userId: _payments[index].userId,
            userName: _payments[index].userName,
            totalPrice: _payments[index].totalPrice,
            totalItems: _payments[index].totalItems,
            status: status,
            items: _payments[index].items,
            created: _payments[index].created,
            updated: DateTime.now(),
          );
          _payments[index] = updatedPayment;
          notifyListeners();
        }
        
        if (status == true) {
          debugPrint('Payment confirmed, clearing cart items...');
          await _paymentService.clearCartForPayment(paymentId);
        }
        
        debugPrint('PaymentProvider: Payment status updated successfully');
      } else {
        _setError('Failed to update payment status');
      }
      
      return success;
    } catch (e) {
      debugPrint('PaymentProvider error updating payment status: $e');
      _setError('Error updating payment status: $e');
      return false;
    }
  }
  
  // Get payments by user ID
  Future<void> loadPaymentsByUserId(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      debugPrint('PaymentProvider: Loading payments for user $userId');
      
      final payments = await _paymentService.getPaymentsByUserId(userId);
      
      _payments = payments;
      notifyListeners();
      
      debugPrint('PaymentProvider: Loaded ${payments.length} payments');
    } catch (e) {
      debugPrint('PaymentProvider error loading payments: $e');
      _setError('Error loading payments: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Clear payments
  void clearPayments() {
    _payments.clear();
    _clearError();
    notifyListeners();
  }
  
  // Helper methods
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
}
