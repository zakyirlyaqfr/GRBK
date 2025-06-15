import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
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
      'isAvailable': true, // Available
    },
    {
      'name': 'Single Origin Americano',
      'price': 25000,
      'image': '☕',
      'category': 'Basic Espresso',
      'description': 'Bold and smooth americano from single origin beans',
      'isAvailable': false, // Out of stock
    },
    {
      'name': 'Matcha Latte',
      'price': 30000,
      'image': '🍵',
      'category': 'Milk Base',
      'description': 'Premium matcha with creamy milk foam',
      'isAvailable': true, // Available
    },
    {
      'name': 'Lemon Mint Refresher',
      'price': 28000,
      'image': '🍋',
      'category': 'Sparkling Fruity',
      'description': 'Fresh lemon with mint leaves, perfect for hot days',
      'isAvailable': false, // Out of stock
    },
    {
      'name': 'Earl Grey Tea',
      'price': 22000,
      'image': '🫖',
      'category': 'Tea Series',
      'description': 'Classic earl grey with bergamot essence',
      'isAvailable': true, // Available
    },
    {
      'name': 'Artisan Croissant',
      'price': 18000,
      'image': '🥐',
      'category': 'Food',
      'description': 'Buttery croissant baked fresh daily',
      'isAvailable': false, // Out of stock
    },
  ];

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
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const HistoryScreen(),
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
                    Text(
                      'Hi! #TeamGRBK',
                      style: GoogleFonts.oswald(
                        color: AppTheme.lightCream,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
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
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
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
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${product['price']}',
                            style: GoogleFonts.oswald(
                              color: isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
}