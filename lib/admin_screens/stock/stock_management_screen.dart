import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Kopi Susu',
    'Basic Espresso',
    'Sparkling Fruity',
    'Milk Base',
    'Tea Series',
    'Food'
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'GRBK Special Blend',
      'price': 35000,
      'image': '☕',
      'category': 'Kopi Susu',
      'description': 'Our signature specialty coffee blend with notes of chocolate and caramel',
      'isAvailable': true,
    },
    {
      'name': 'Single Origin Americano',
      'price': 25000,
      'image': '☕',
      'category': 'Basic Espresso',
      'description': 'Bold and smooth americano from single origin beans',
      'isAvailable': false,
    },
    {
      'name': 'Matcha Latte',
      'price': 30000,
      'image': '🍵',
      'category': 'Milk Base',
      'description': 'Premium matcha with creamy milk foam',
      'isAvailable': true,
    },
    {
      'name': 'Lemon Mint Refresher',
      'price': 28000,
      'image': '🍋',
      'category': 'Sparkling Fruity',
      'description': 'Fresh lemon with mint leaves, perfect for hot days',
      'isAvailable': false,
    },
    {
      'name': 'Earl Grey Tea',
      'price': 22000,
      'image': '🫖',
      'category': 'Tea Series',
      'description': 'Classic earl grey with bergamot essence',
      'isAvailable': true,
    },
    {
      'name': 'Artisan Croissant',
      'price': 18000,
      'image': '🥐',
      'category': 'Food',
      'description': 'Buttery croissant baked fresh daily',
      'isAvailable': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((product) => product['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelola Stok',
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                    Text(
                      'Atur ketersediaan stok produk',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.deepNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Manajemen Stok',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stock Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              _buildStockSummaryCard(
                'Total Produk',
                _products.length.toString(),
                Icons.inventory_2_rounded,
                AppTheme.primaryGradient,
              ),
              _buildStockSummaryCard(
                'Stok Tersedia',
                _products.where((p) => p['isAvailable']).length.toString(),
                Icons.check_circle_rounded,
                const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
              ),
              _buildStockSummaryCard(
                'Stok Habis',
                _products.where((p) => !p['isAvailable']).length.toString(),
                Icons.cancel_rounded,
                const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Categories
          _buildCategories(),
          
          const SizedBox(height: 16),
          
          // Products Grid
          Expanded(
            child: _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummaryCard(String title, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.warmBeige,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppTheme.deepNavy.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : AppTheme.deepNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildStockProductCard(product, index);
      },
    );
  }

  Widget _buildStockProductCard(Map<String, dynamic> product, int index) {
    final bool isAvailable = product['isAvailable'] ?? true;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isAvailable ? AppTheme.neutralGradient : AppTheme.lightGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            product['image'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    // Stock Status Indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${product['price']}',
                      style: GoogleFonts.oswald(
                        color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    
                    // Stock Toggle
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAvailable ? 'Tersedia' : 'Habis',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                product['isAvailable'] = value;
                              });
                              _showStockUpdateSnackBar(product['name'], value);
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                            activeTrackColor: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockUpdateSnackBar(String productName, bool isAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isAvailable ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$productName ${isAvailable ? 'tersedia' : 'habis'}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: isAvailable ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}