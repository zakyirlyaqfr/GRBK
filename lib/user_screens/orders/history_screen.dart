import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../product/product_detail_screen.dart';
import '../../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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