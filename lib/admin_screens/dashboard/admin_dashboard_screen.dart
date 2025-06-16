import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../utils/app_theme.dart';
import '../menu/menu_management_screen.dart';
import '../stock/stock_management_screen.dart';
import '../users/user_management_screen.dart';
import '../cashier/cashier_screen.dart';
import '../reports/reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _selectedCategory = 'All';

  late AnimationController _sidebarController;
  late AnimationController _overlayController;
  late Animation<Offset> _sidebarSlideAnimation;
  late Animation<double> _overlayOpacityAnimation;

  // Updated categories to match home_screen.dart
  final List<String> _categories = [
    'All',
    'Kopi Susu',
    'Basic Espresso',
    'Sparkling Fruity',
    'Milk Base',
    'Tea Series',
    'Food'
  ];

  // Updated products to match home_screen.dart structure
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'GRBK Special Blend',
      'price': 35000,
      'image': '☕',
      'category': 'Kopi Susu',
      'description':
          'Our signature specialty coffee blend with notes of chocolate and caramel',
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

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_rounded,
      'screen': 'dashboard',
    },
    {
      'title': 'Kelola Menu',
      'icon': Icons.restaurant_menu_rounded,
      'screen': 'menu',
    },
    {
      'title': 'Kelola Stok',
      'icon': Icons.inventory_rounded,
      'screen': 'stock',
    },
    {
      'title': 'Kelola User',
      'icon': Icons.people_rounded,
      'screen': 'users',
    },
    {
      'title': 'Kasir',
      'icon': Icons.point_of_sale_rounded,
      'screen': 'cashier',
    },
    {
      'title': 'Laporan',
      'icon': Icons.analytics_rounded,
      'screen': 'reports',
    },
  ];

  @override
  void initState() {
    super.initState();

    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _sidebarSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));

    _overlayOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });

    if (_isSidebarOpen) {
      _sidebarController.forward();
      _overlayController.forward();
    } else {
      _sidebarController.reverse();
      _overlayController.reverse();
    }
  }

  void _closeSidebar() {
    if (_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = false;
      });
      _sidebarController.reverse();
      _overlayController.reverse();
    }
  }

  void _selectMenuItem(int index) {
    setState(() {
      _selectedIndex = index;
      _isSidebarOpen = false; // Auto close sidebar
    });
    _sidebarController.reverse();
    _overlayController.reverse();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where((product) => product['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: Stack(
        children: [
          // Main Content with Gesture Detection
          GestureDetector(
            onTap: _isSidebarOpen ? _closeSidebar : null,
            child: AbsorbPointer(
              absorbing:
                  _isSidebarOpen, // Disable interactions when sidebar is open
              child: Column(
                children: [
                  // Top Bar - Optimized for iPhone 14 Pro Max
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 50,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepNavy.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Hamburger Menu Button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.softWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.warmBeige.withValues(alpha: 0.3),
                            ),
                          ),
                          child: IconButton(
                            onPressed: _toggleSidebar,
                            icon: AnimatedRotation(
                              turns: _isSidebarOpen ? 0.25 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: AppTheme.deepNavy,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getScreenTitle(),
                                style: GoogleFonts.oswald(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                              Text(
                                _getScreenSubtitle(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppTheme.charcoalGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _buildScreenContent(),
                  ),
                ],
              ),
            ),
          ),

          // Overlay when sidebar is open
          AnimatedBuilder(
            animation: _overlayOpacityAnimation,
            builder: (context, child) {
              return _overlayOpacityAnimation.value > 0
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: _overlayOpacityAnimation.value,
                        ),
                        child: GestureDetector(
                          onTap: _closeSidebar,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Animated Sidebar
          SlideTransition(
            position: _sidebarSlideAnimation,
            child: _buildSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'GRBK Admin',
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Coffee Management',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = _selectedIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectMenuItem(index),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'],
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item['title'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Divider(color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin GRBK',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Super Admin',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Kelola Menu';
      case 2:
        return 'Kelola Stok';
      case 3:
        return 'Kelola User';
      case 4:
        return 'Kasir';
      case 5:
        return 'Laporan';
      default:
        return 'Dashboard';
    }
  }

  String _getScreenSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Ringkasan dan katalog produk GRBK Coffee';
      case 1:
        return 'Manajemen menu dan produk';
      case 2:
        return 'Manajemen stok dan ketersediaan';
      case 3:
        return 'Manajemen pengguna dan admin';
      case 4:
        return 'Sistem kasir dan pembayaran';
      case 5:
        return 'Laporan penjualan dan analitik';
      default:
        return 'Ringkasan dan katalog produk GRBK Coffee';
    }
  }

  Widget _buildScreenContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const MenuManagementScreen();
      case 2:
        return const StockManagementScreen();
      case 3:
        return const UserManagementScreen();
      case 4:
        return const CashierScreen();
      case 5:
        return const ReportsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          Container(
            height: 200,
            child: Column(
              children: [
                // Baris pertama
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Produk',
                          '${_products.length}',
                          Icons.inventory_rounded,
                          AppTheme.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Stok Tersedia',
                          '${_products.where((p) => p['isAvailable']).length}',
                          Icons.check_circle_rounded,
                          const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Baris kedua
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Stok Habis',
                          '${_products.where((p) => !p['isAvailable']).length}',
                          Icons.warning_rounded,
                          const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Kategori',
                          '${_categories.length - 1}',
                          Icons.category_rounded,
                          AppTheme.accentGradient,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Product Section Header
          Text(
            'Our Products',
            style: GoogleFonts.oswald(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),

          const SizedBox(height: 12),

          // Categories
          Container(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppTheme.warmBeige,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppTheme.deepNavy.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
          ),

          const SizedBox(height: 16),

          // Product Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildEnhancedProductCard(product);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProductCard(Map<String, dynamic> product) {
    final bool isAvailable = product['isAvailable'] ?? true;

    return Container(
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
                                    horizontal: 12, vertical: 6),
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
                        color: isAvailable
                            ? AppTheme.deepNavy
                            : AppTheme.charcoalGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${product['price']}',
                      style: GoogleFonts.oswald(
                        color: isAvailable
                            ? AppTheme.deepNavy
                            : AppTheme.charcoalGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
}
