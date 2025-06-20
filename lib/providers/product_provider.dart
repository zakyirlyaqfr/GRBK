import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_services.dart';

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
      debugPrint('Loaded ${_products.length} products');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create product with enhanced web image support
  Future<bool> createProduct({
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    String? webImageData, // Add this parameter
    bool stock = true,
  }) async {
    _setLoading(true);
    try {
      debugPrint('Creating product: $name');
      debugPrint('Has image file: ${imageFile != null}');
      debugPrint('Has web image data: ${webImageData != null && webImageData.isNotEmpty}');
      
      await _productService.createProduct(
        name: name,
        price: price,
        category: category,
        description: description,
        imageFile: imageFile,
        webImageData: webImageData,
      );

      await loadProducts(); // Reload products
      _error = null;
      debugPrint('Product created successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product with enhanced web image support
  Future<bool> updateProduct({
    required String id,
    required String name,
    required int price,
    required String category,
    required String description,
    File? imageFile,
    String? webImageData, // Add this parameter
    bool? stock,
  }) async {
    _setLoading(true);
    try {
      debugPrint('Updating product: $id');
      debugPrint('Has image file: ${imageFile != null}');
      debugPrint('Has web image data: ${webImageData != null && webImageData.isNotEmpty}');
      
      await _productService.updateProduct(
        id: id,
        name: name,
        price: price,
        category: category,
        description: description,
        imageFile: imageFile,
        webImageData: webImageData,
      );

      await loadProducts(); // Reload products
      _error = null;
      debugPrint('Product updated successfully');
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

  // Get image URL
  String getImageUrl(ProductModel product) {
    return _productService.getImageUrl(product);
  }

  // Get image URL from path
  String getImageUrlFromPath(String imagePath) {
    const String baseUrl = 'http://127.0.0.1:8090';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    if (imagePath.isEmpty) {
      return '';
    }
    
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
