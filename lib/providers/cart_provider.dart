import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../services/pocketbase_service.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // Get PocketBase service instance
  final PocketBaseService _pocketBaseService = PocketBaseService();

  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  int get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // Check if user is authenticated
  bool get isAuthenticated => _pocketBaseService.isAuthenticated;

  // Load cart items from PocketBase
  Future<void> loadCartItems() async {
    if (!_pocketBaseService.isAuthenticated) {
      _error = 'User not authenticated';
      _cartItems = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await CartService.getCartItems();
    } catch (e) {
      _error = e.toString();
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String temperature,
    required String sweetness,
    required String specialNotes,
  }) async {
    if (!_pocketBaseService.isAuthenticated) {
      _error = 'User not authenticated. Please login first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CartService.addToCart(
        productId: productId,
        quantity: quantity,
        temperature: temperature,
        sweetness: sweetness,
        specialNotes: specialNotes,
      );

      // Reload cart items to get updated data
      await loadCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String cartId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartId);
      return;
    }

    if (!_pocketBaseService.isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CartService.updateCartItem(cartId, newQuantity);
      
      // Update local state
      final index = _cartItems.indexWhere((item) => item.id == cartId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartId) async {
    if (!_pocketBaseService.isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CartService.removeFromCart(cartId);
      
      // Update local state
      _cartItems.removeWhere((item) => item.id == cartId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (!_pocketBaseService.isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CartService.clearCart();
      _cartItems.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get cart item count for a specific product
  Future<int> getProductQuantityInCart(String productId) async {
    try {
      return await CartService.getProductQuantityInCart(productId);
    } catch (e) {
      print('Error getting product quantity in cart: $e');
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
