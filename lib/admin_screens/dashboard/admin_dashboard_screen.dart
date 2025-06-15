import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _selectedCategory = 'Semua';
  
  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarSlideAnimation;

  final List<String> _categories = ['Semua', 'Coffee', 'Non-Coffee', 'Food', 'Snack'];
  
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'GRBK Special Blend',
      'category': 'Coffee',
      'price': 35000,
      'stock': 25,
      'image': 'assets/coffee1.jpg',
      'isAvailable': true,
    },
    {
      'name': 'Caramel Macchiato',
      'category': 'Coffee',
      'price': 42000,
      'stock': 18,
      'image': 'assets/coffee2.jpg',
      'isAvailable': true,
    },
    {
      'name': 'Iced Chocolate',
      'category': 'Non-Coffee',
      'price': 28000,
      'stock': 0,
      'image': 'assets/chocolate.jpg',
      'isAvailable': false,
    },
    {
      'name': 'Artisan Croissant',
      'category': 'Food',
      'price': 18000,
      'stock': 12,
      'image': 'assets/croissant.jpg',
      'isAvailable': true,
    },
    {
      'name': 'Blueberry Muffin',
      'category': 'Snack',
      'price': 15000,
      'stock': 8,
      'image': 'assets/muffin.jpg',
      'isAvailable': true,
    },
    {
      'name': 'Green Tea Latte',
      'category': 'Non-Coffee',
      'price': 32000,
      'stock': 15,
      'image': 'assets/greentea.jpg',
      'isAvailable': true,
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
    
    _sidebarSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    
    if (_isSidebarOpen) {
      _sidebarController.forward();
    } else {
      _sidebarController.reverse();
    }
  }

  void _selectMenuItem(int index) {
    setState(() {
      _selectedIndex = index;
      _isSidebarOpen = false; // Auto close sidebar
    });
    _sidebarController.reverse();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'Semua') {
      return _products;
    }
    return _products.where((product) => product['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Top Bar - Optimized for iPhone 14 Pro Max
              Container(
                height: 110, // Increased for better mobile spacing
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 60, // Adjusted for iPhone notch
                  bottom: 16,
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
                      width: 40,
                      height: 40,
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
                            size: 20,
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
                    
                    // Notification & Profile
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.softWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.warmBeige.withValues(alpha: 0.3),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_rounded,
                                  color: AppTheme.deepNavy,
                                  size: 18,
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.deepNavy,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
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
          
          // Animated Sidebar - No overlay blur
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
      width: 260, // Optimized width for mobile
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
                                      color: Colors.white.withValues(alpha: 0.3),
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
      case 0: return 'Dashboard';
      case 1: return 'Kelola Menu';
      case 2: return 'Kelola Stok';
      case 3: return 'Kelola User';
      case 4: return 'Kasir';
      case 5: return 'Laporan';
      default: return 'Dashboard';
    }
  }

  String _getScreenSubtitle() {
    switch (_selectedIndex) {
      case 0: return 'Ringkasan dan katalog produk GRBK Coffee';
      case 1: return 'Manajemen menu dan produk';
      case 2: return 'Manajemen stok dan ketersediaan';
      case 3: return 'Manajemen pengguna dan admin';
      case 4: return 'Sistem kasir dan pembayaran';
      case 5: return 'Laporan penjualan dan analitik';
      default: return 'Ringkasan dan katalog produk GRBK Coffee';
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'Total Produk',
                '${_products.length}',
                Icons.inventory_rounded,
                AppTheme.primaryGradient,
              ),
              _buildStatCard(
                'Stok Tersedia',
                '${_products.where((p) => p['isAvailable']).length}',
                Icons.check_circle_rounded,
                const LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
              ),
              _buildStatCard(
                'Stok Habis',
                '${_products.where((p) => !p['isAvailable']).length}',
                Icons.warning_rounded,
                const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
              ),
              _buildStatCard(
                'Kategori',
                '${_categories.length - 1}',
                Icons.category_rounded,
                AppTheme.accentGradient,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Category Filter
          Row(
            children: [
              Text(
                'Katalog Produk',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Category Chips
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      category,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : AppTheme.deepNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.deepNavy,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.deepNavy : AppTheme.warmBeige,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, 
                      vertical: 4,
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              Icon(icon, color: Colors.white, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 10,
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
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.local_cafe_rounded,
                      size: 32,
                      color: AppTheme.deepNavy.withValues(alpha: 0.3),
                    ),
                  ),
                  // Stock Status Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, 
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product['isAvailable'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product['isAvailable'] ? 'Tersedia' : 'Habis',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['category'],
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${product['price']}',
                        style: GoogleFonts.oswald(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4, 
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmBeige.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stok: ${product['stock']}',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepNavy,
                          ),
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
    );
  }
}