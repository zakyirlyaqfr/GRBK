import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../services/pocketbase_service.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  final PocketBaseService _pocketBaseService = PocketBaseService();

  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalCartValue => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

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

      await loadCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Increase quantity
  Future<void> increaseQuantity(CartModel cartItem) async {
    await updateCartItemQuantity(cartItem.id, cartItem.quantity + 1);
  }

  // Decrease quantity
  Future<void> decreaseQuantity(CartModel cartItem) async {
    if (cartItem.quantity > 1) {
      await updateCartItemQuantity(cartItem.id, cartItem.quantity - 1);
    } else {
      await removeFromCart(cartItem.id);
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
      
      final index = _cartItems.indexWhere((item) => item.id == cartId);
      if (index != -1) {
        final updatedItem = _cartItems[index].copyWith(quantity: newQuantity);
        _cartItems[index] = updatedItem;
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

  // Clear cart for payment
  Future<void> clearCartForPayment(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await CartService.clearCartForUser(userId);
      _cartItems.clear();
      
      debugPrint('✅ Cart cleared for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing cart: $e');
      _error = 'Failed to clear cart';
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
      debugPrint('Error getting product quantity in cart: $e');
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
