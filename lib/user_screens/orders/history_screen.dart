import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../services/pocketbase_service.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../services/product_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PocketBaseService _pocketbaseService = PocketBaseService();
  final ProductService _productService = ProductService();
  List<OrderModel> _userOrders = [];
  Map<String, ProductModel> _productCache = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _pocketbaseService.currentUser;
      if (user != null) {
        final orderProvider = context.read<OrderProvider>();
        await orderProvider.loadOrdersByUserId(user.id);

        _userOrders = orderProvider.orders;

        // Step 1: Kumpulkan semua product_id unik
        final productIds = <String>{};
        for (final order in _userOrders) {
          final items = order.items['items'] as List<dynamic>? ?? [];
          for (final item in items) {
            final pid = item['product_id'] ?? item['productId'];
            if (pid != null) productIds.add(pid);
          }
        }

        // Step 2: Fetch detail produk dan simpan ke cache
        for (final pid in productIds) {
          if (!_productCache.containsKey(pid)) {
            final product = await _productService.fetchProductById(pid);
            if (product != null) {
              _productCache[pid] = product;
            }
          }
        }

        debugPrint(
            '✅ Loaded ${_userOrders.length} orders for user: ${user.id}');
      }
    } catch (e) {
      debugPrint('❌ Error loading user orders: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalOrders => _userOrders.length;
  int get _totalSpent => _userOrders.fold(0, (sum, order) {
        final totalPrice = order.items['total_price'] as int? ?? 0;
        return sum + totalPrice;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildEnhancedHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildOrdersList(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Your order history!',
                      style: GoogleFonts.poppins(
                        color: AppTheme.warmBeige,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
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
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.deepNavy,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatContainer(
                  'Total Orders',
                  '$_totalOrders',
                  Icons.shopping_bag_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatContainer(
                  'Total Spent',
                  'Rp $_totalSpent',
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
    if (_userOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _userOrders.length,
      itemBuilder: (context, index) {
        final order = _userOrders[index];
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

  Widget _buildEnhancedOrderCard(OrderModel order) {
    final items = order.items['items'] as List<dynamic>? ?? [];
    final totalPrice = order.items['total_price'] as int? ?? 0;
    final totalItems = order.items['total_items'] as int? ?? 0;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                        Text(
                          '${order.created.day}/${order.created.month}/${order.created.year} • ${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.charcoalGray,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Completed',
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

                // Enhanced items display with product details
                Text(
                  'Items ($totalItems):',
                  style: GoogleFonts.oswald(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                const SizedBox(height: 8),

                ...items.take(3).map<Widget>((item) {
                  final productName = item['product_name'] ??
                      item['productName'] ??
                      'Unknown Product';
                  final productPrice =
                      item['product_price'] ?? item['productPrice'] ?? 0;
                  final quantity = item['quantity'] ?? 1;
                  final itemTotal = item['total_price'] ??
                      item['totalPrice'] ??
                      (productPrice * quantity);
                  final temperature = item['temperature'] ?? '';
                  final sweetness = item['sweetness'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.softWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Product image
                        Builder(
                          builder: (_) {
                            final productId =
                                item['product_id'] ?? item['productId'];
                            final product = _productCache[productId];
                            final imageName = product?.image;
                            if (productId != null &&
                                imageName != null &&
                                imageName.isNotEmpty) {
                              final imageUrl =
                                  '${PocketBaseService.baseUrl}/api/files/products/$productId/$imageName';
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    color: AppTheme.softWhite,
                                    child: const Icon(Icons.coffee_rounded,
                                        color: Colors.grey),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.neutralGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.coffee_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Qty: $quantity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.charcoalGray,
                                    ),
                                  ),
                                  if (temperature.isNotEmpty &&
                                      temperature != '-') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warmBeige
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        temperature,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: AppTheme.deepNavy,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (sweetness.isNotEmpty &&
                                      sweetness != '-') ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warmBeige
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        sweetness,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: AppTheme.deepNavy,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                'Rp $productPrice each',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.charcoalGray
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp $itemTotal',
                              style: GoogleFonts.oswald(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warmBeige.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.warmBeige.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.more_horiz,
                            color: AppTheme.charcoalGray,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${items.length - 3} more items',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
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
                            'Rp $totalPrice',
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
                          onPressed: () => _showReorderOptions(items),
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

  void _showOrderDetails(OrderModel order) {
    final items = order.items['items'] as List<dynamic>? ?? [];
    final totalPrice = order.items['total_price'] as int? ?? 0;
    final totalItems = order.items['total_items'] as int? ?? 0;

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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.warmBeige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.oswald(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightCream,
                        ),
                      ),
                      Text(
                        '${order.created.day}/${order.created.month}/${order.created.year} • ${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          color: AppTheme.warmBeige,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Payment ID: ${order.paymentId.substring(0, 8)}...',
                        style: GoogleFonts.poppins(
                          color: AppTheme.warmBeige.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Completed',
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Order Items',
                    style: GoogleFonts.oswald(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warmBeige.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalItems items',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final productName = item['product_name'] ??
                      item['productName'] ??
                      'Unknown Product';
                  final productPrice =
                      item['product_price'] ?? item['productPrice'] ?? 0;
                  final quantity = item['quantity'] ?? 1;
                  final itemTotal = item['total_price'] ??
                      item['totalPrice'] ??
                      (productPrice * quantity);
                  final temperature = item['temperature'] ?? '';
                  final sweetness = item['sweetness'] ?? '';
                  final specialNotes =
                      item['special_notes'] ?? item['specialNotes'] ?? '';

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
                        // Product image
                        Builder(
                          builder: (_) {
                            final productId =
                                item['product_id'] ?? item['productId'];
                            final product = _productCache[productId];
                            final imageName = product?.image;
                            if (productId != null &&
                                imageName != null &&
                                imageName.isNotEmpty) {
                              final imageUrl =
                                  '${PocketBaseService.baseUrl}/api/files/products/$productId/$imageName';
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.softWhite,
                                    child: const Icon(Icons.coffee_rounded,
                                        color: Colors.grey),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.neutralGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.coffee_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Rp $productPrice',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.charcoalGray,
                                    ),
                                  ),
                                  Text(
                                    ' × $quantity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.deepNavy,
                                    ),
                                  ),
                                ],
                              ),
                              if (temperature.isNotEmpty ||
                                  sweetness.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    if (temperature.isNotEmpty &&
                                        temperature != '-')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warmBeige
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          temperature,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                    if (sweetness.isNotEmpty &&
                                        sweetness != '-')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warmBeige
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          sweetness,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (specialNotes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightCream
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.note_rounded,
                                        size: 14,
                                        color: AppTheme.charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          specialNotes,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppTheme.charcoalGray,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp $itemTotal',
                              style: GoogleFonts.oswald(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Added $productName to favorites'),
                                      backgroundColor: AppTheme.deepNavy,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.favorite_border_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
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
                            fontSize: 14,
                            color: AppTheme.lightCream,
                          ),
                        ),
                        Text(
                          'Rp $totalPrice',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReorderOptions(items);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.deepNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reorder All',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.bold,
                        ),
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

  void _showReorderOptions(List<dynamic> items) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reorder feature coming soon!'),
        backgroundColor: AppTheme.deepNavy,
      ),
    );
  }
  // This is a placeholder for the reorder functionality.
  // You can implement the actual reorder logic here.
}
