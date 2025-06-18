import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_services.dart'; // Fixed: tambah 's' di akhir

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  // Get available products
  List<ProductModel> get availableProducts => 
      _products.where((product) => product.stock).toList();

  // Get unavailable products
  List<ProductModel> get unavailableProducts => 
      _products.where((product) => !product.stock).toList();

  // Get product statistics
  Map<String, int> get productStats => {
    'total': _products.length,
    'available': availableProducts.length,
    'unavailable': unavailableProducts.length,
  };

  // Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _productService.getAllProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create product
  Future<bool> createProduct({
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    bool stock = true,
  }) async {
    _setLoading(true);
    try {
      // ProductService.createProduct returns ProductModel directly, not a Map
      await _productService.createProduct(
        name: name,
        price: price,
        category: category,
        description: description,
        imageFile: imageFile,
      );

      // If we get here without exception, it was successful
      await loadProducts(); // Reload products
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<bool> updateProduct({
    required String id,
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    bool? stock,
  }) async {
    _setLoading(true);
    try {
      // ProductService.updateProduct returns ProductModel directly, not a Map
      await _productService.updateProduct(
        id: id,
        name: name,
        price: price,
        category: category,
        description: description,
        imageFile: imageFile,
      );

      // If we get here without exception, it was successful
      await loadProducts(); // Reload products
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product stock
  Future<bool> updateProductStock(String id, bool stock) async {
    try {
      final result = await _productService.updateProductStock(id, stock);

      if (result['success']) {
        // Update local state immediately for better UX
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = _products[index].copyWith(stock: stock);
          notifyListeners();
        }
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating product stock: $e');
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    try {
      // ProductService.deleteProduct returns bool directly, not a Map
      final success = await _productService.deleteProduct(id);

      if (success) {
        await loadProducts(); // Reload products
        _error = null;
        return true;
      } else {
        _error = 'Failed to delete product';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get image URL - Fixed method signature
  String getImageUrl(ProductModel product) {
    return _productService.getImageUrl(product);
  }

  // Get image URL from path - NEW METHOD for cart functionality
  String getImageUrlFromPath(String imagePath) {
    // Assuming your PocketBase URL is similar to the one in CartService
    const String baseUrl = 'http://127.0.0.1:8090'; // Replace with your PocketBase URL
    
    // Check if the path already contains the full URL
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Check if path is empty or null
    if (imagePath.isEmpty) {
      return '';
    }
    
    // Construct the URL for the image
    // Format: http://your-pocketbase-url/api/files/collection_name/record_id/filename
    return '$baseUrl/api/files/products/$imagePath';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}