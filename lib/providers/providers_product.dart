import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/pocketbase_service.dart';

class ProductProvider with ChangeNotifier {
  final PocketBaseService _pocketBaseService = PocketBaseService();
  
  List<Product> _products = [];
  List<Product> _popularProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Getters
  List<Product> get products => _products;
  List<Product> get popularProducts => _popularProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Filtered products based on category and search
  List<Product> get filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  // Get available categories
  List<String> get categories {
    final Set<String> categorySet = {'All'};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList();
  }

  // Initialize provider
  Future<void> initialize() async {
    await _pocketBaseService.initialize();
    await loadProducts();
  }

  // Load all products
  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final products = await _pocketBaseService.getProducts();
      _products = products;
      
      // Load popular products separately
      _popularProducts = products.where((product) => product.isPopular).toList();
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts();
  }

  // Load products by category
  Future<void> loadProductsByCategory(String category) async {
    try {
      _setLoading(true);
      _clearError();

      final products = await _pocketBaseService.getProductsByCategory(category);
      _products = products;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final products = await _pocketBaseService.searchProducts(query);
      _products = products;
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search products: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Set selected category
  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      // First check if product exists in current list
      final existingProduct = _products.firstWhere(
        (product) => product.id == id,
        orElse: () => Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
        ),
      );

      if (existingProduct.id.isNotEmpty) {
        return existingProduct;
      }

      // If not found, fetch from service
      return await _pocketBaseService.getProductById(id);
    } catch (e) {
      _setError('Failed to get product: ${e.toString()}');
      return null;
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    return await _pocketBaseService.testConnection();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _pocketBaseService.dispose();
    super.dispose();
  }
}