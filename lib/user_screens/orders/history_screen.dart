import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../product/product_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../cart/cart_screen.dart';
import '../../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final int initialIndex;
  
  const HistoryScreen({super.key, this.initialIndex = 1});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _currentIndex;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final PageController _bannerPageController = PageController();
  int _currentBannerIndex = 0;

  // Banner/Promotional images for sliding (like Gojek)
  final List<Map<String, String>> _bannerImages = [
    {
      'image': 'assets/images/banner1.jpg',
      'title': 'Special Promo Today!',
      'subtitle': 'Get 20% off for all coffee drinks'
    },
    {
      'image': 'assets/images/banner2.jpg',
      'title': 'New Menu Alert!',
      'subtitle': 'Try our signature blend coffee'
    },
    {
      'image': 'assets/images/banner3.jpg',
      'title': 'Happy Hour',
      'subtitle': 'Buy 2 get 1 free every 3-5 PM'
    },
    {
      'image': 'assets/images/banner4.jpg',
      'title': 'Weekend Special',
      'subtitle': 'Fresh pastries available now'
    },
  ];

  // Updated categories
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

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'GRBK001',
      'date': '2024-01-15',
      'time': '14:30',
      'status': 'Completed',
      'total': 78000,
      'items': [
        {
          'name': 'GRBK Special Blend',
          'price': 35000,
          'image': '☕',
          'category': 'Kopi Susu',
          'description': 'Our signature specialty coffee blend with notes of chocolate and caramel',
        },
        {
          'name': 'Artisan Croissant',
          'price': 18000,
          'image': '🥐',
          'category': 'Food',
          'description': 'Buttery croissant baked fresh daily',
        },
      ],
    },
    {
      'id': 'GRBK002',
      'date': '2024-01-14',
      'time': '09:15',
      'status': 'Completed',
      'total': 53000,
      'items': [
        {
          'name': 'Single Origin Americano',
          'price': 25000,
          'image': '☕',
          'category': 'Basic Espresso',
          'description': 'Bold and smooth americano from single origin beans',
        },
        {
          'name': 'Matcha Latte',
          'price': 30000,
          'image': '🍵',
          'category': 'Milk Base',
          'description': 'Premium matcha with creamy milk foam',
        },
      ],
    },
    {
      'id': 'GRBK003',
      'date': '2024-01-13',
      'time': '16:45',
      'status': 'Completed',
      'total': 46000,
      'items': [
        {
          'name': 'Lemon Mint Refresher',
          'price': 28000,
          'image': '🍋',
          'category': 'Sparkling Fruity',
          'description': 'Fresh lemon with mint leaves, perfect for hot days',
        },
        {
          'name': 'Earl Grey Tea',
          'price': 22000,
          'image': '🫖',
          'category': 'Tea Series',
          'description': 'Classic earl grey with bergamot essence',
        },
      ],
    },
    {
      'id': 'GRBK004',
      'date': '2024-01-12',
      'time': '11:20',
      'status': 'Completed',
      'total': 35000,
      'items': [
        {
          'name': 'GRBK Special Blend',
          'price': 35000,
          'image': '☕',
          'category': 'Kopi Susu',
          'description': 'Our signature specialty coffee blend with notes of chocolate and caramel',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Auto-slide banner every 4 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    if (mounted) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _bannerPageController.hasClients) {
          int nextPage = (_currentBannerIndex + 1) % _bannerImages.length;
          _bannerPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startAutoSlide();
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _products;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product['category'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((product) => 
        product['name'].toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildHistoryContent(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildEnhancedBottomNavBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                // Top Header with greeting and logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting Text
                    Flexible(
                      child: Text(
                        'Hi! #TeamGRBK',
                        style: GoogleFonts.oswald(
                          color: AppTheme.lightCream,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.lightCream,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.richBlack.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/grbk_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_cafe,
                              color: AppTheme.deepNavy,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Banner/Promotional Images Slider (like Gojek)
                  _buildBannerSlider(),
                  
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  _buildSearchBar(),
                  
                  const SizedBox(height: 20),
                  
                  // Categories
                  _buildCategories(),
                  
                  const SizedBox(height: 20),
                  
                  // Products Section
                  _buildProductsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    return SafeArea(
      child: Column(
        children: [
          // Enhanced Header Section
          _buildEnhancedHeader(),
          
          // Orders List
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 180,
      child: Stack(
        children: [
          // Banner PageView
          PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              final banner = _bannerImages[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.deepNavy.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.neutralGradient,
                        ),
                        child: Image.asset(
                          banner['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: AppTheme.lightGradient,
                              ),
                              child: const Center(
                                child: Text(
                                  '☕ GRBK Special ☕',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Overlay Content
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Text Content
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title']!,
                              style: GoogleFonts.oswald(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentBannerIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: GoogleFonts.poppins(
          color: AppTheme.deepNavy,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search specialty coffee...',
          hintStyle: GoogleFonts.poppins(
            color: AppTheme.charcoalGray.withValues(alpha: 0.7),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_rounded, 
              color: Colors.white,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.warmBeige,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppTheme.deepNavy.withValues(alpha: 0.3)
                        : AppTheme.richBlack.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : AppTheme.deepNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Products',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildEnhancedProductCard(product);
            },
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEnhancedProductCard(Map<String, dynamic> product) {
    final bool isAvailable = product['isAvailable'] ?? true;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.neutralGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              product['image'],
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Out of stock overlay
                    if (!isAvailable)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 6
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'NOT AVAILABLE',
                                  style: GoogleFonts.oswald(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product name with overflow protection
                      Flexible(
                        child: Text(
                          product['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price and button row with overflow protection
                      Row(
                        children: [
                          // Price with flexible width
                          Expanded(
                            child: Text(
                              'Rp ${product['price']}',
                              style: GoogleFonts.oswald(
                                color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Add button with fixed size
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isAvailable 
                                  ? AppTheme.primaryGradient 
                                  : LinearGradient(
                                      colors: [
                                        AppTheme.charcoalGray.withValues(alpha: 0.5),
                                        AppTheme.charcoalGray.withValues(alpha: 0.3),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isAvailable ? [
                                BoxShadow(
                                  color: AppTheme.deepNavy.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ] : [],
                            ),
                            child: Icon(
                              isAvailable ? Icons.add_rounded : Icons.block_rounded,
                              color: Colors.white,
                              size: 20,
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
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Main Header Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Updated greeting with cool font
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppTheme.lightCream,
                          AppTheme.warmBeige,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'How much #TeamGRBK',
                        style: GoogleFonts.oswald(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your order here!',
                      style: GoogleFonts.poppins(
                        color: AppTheme.warmBeige,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Decorative Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.lightCream,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.richBlack.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/grbk_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.deepNavy,
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatContainer(
                  'Total Orders',
                  '${_orders.length}',
                  Icons.shopping_bag_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatContainer(
                  'Total Spent',
                  'Rp ${_orders.fold(0, (sum, order) => sum + (order['total'] as int))}',
                  Icons.payments_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.lightCream,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightCream,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.warmBeige,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildEnhancedOrderCard(order);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.lightGradient,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: AppTheme.charcoalGray,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your coffee journey starts here!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.charcoalGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['id']}',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                        Text(
                          '${order['date']} • ${order['time']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.charcoalGray,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        order['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Order Items Preview
                ...order['items'].take(2).map<Widget>((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.softWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.neutralGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            item['image'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${item['price']}',
                        style: GoogleFonts.oswald(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                    ],
                  ),
                )),
                
                if (order['items'].length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${order['items'].length - 2} more items',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Order Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                          Text(
                            'Rp ${order['total']}',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepNavy.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showReorderOptions(order['items']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Reorder',
                            style: GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.deepNavy,
          unselectedItemColor: AppTheme.charcoalGray.withValues(alpha: 0.6),
          selectedLabelStyle: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 0 ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: _currentIndex == 0 ? Colors.white : AppTheme.charcoalGray.withValues(alpha: 0.6),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 1 ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: _currentIndex == 1 ? Colors.white : AppTheme.charcoalGray.withValues(alpha: 0.6),
                ),
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 2 ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: _currentIndex == 2 ? Colors.white : AppTheme.charcoalGray.withValues(alpha: 0.6),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.shopping_cart_rounded, 
          color: Colors.white, 
          size: 28,
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.warmBeige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: GoogleFonts.oswald(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightCream,
                        ),
                      ),
                      Text(
                        '${order['date']} • ${order['time']}',
                        style: GoogleFonts.poppins(
                          color: AppTheme.warmBeige,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightCream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: order['items'].length,
                itemBuilder: (context, index) {
                  final item = order['items'][index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.softWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepNavy.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.neutralGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              item['image'],
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                              Text(
                                'Rp ${item['price']}',
                                style: GoogleFonts.oswald(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: item),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReorderOptions(List<dynamic> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reorder Items',
              style: GoogleFonts.oswald(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to reorder these items',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.charcoalGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.deepNavy, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _reorderAllItems(items);
                      },
                      child: Text(
                        'Add All to Cart',
                        style: GoogleFonts.poppins(
                          color: AppTheme.deepNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _selectItemsToReorder(items);
                      },
                      child: Text(
                        'Select Items',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reorderAllItems(List<dynamic> items) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All items added to cart!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.deepNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _selectItemsToReorder(List<dynamic> items) {
    // Navigate to first item's detail screen as an example
    if (items.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: items[0]),
        ),
      );
    }
  }
}