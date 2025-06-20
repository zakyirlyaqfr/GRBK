import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../utils/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

// Web-specific imports - conditional
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderData();
    });
  }

  Future<void> _loadOrderData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      await orderProvider.loadAllOrders();
      
      if (mounted) {
        setState(() {
          _orders = orderProvider.orders;
          _isLoading = false;
        });
        
        debugPrint('✅ Loaded ${_orders.length} orders for reports');
      }
    } catch (e) {
      debugPrint('❌ Error loading order data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Calculate total revenue from all orders
  int get _totalRevenue {
    return _orders.fold(0, (sum, order) {
      final totalPrice = order.items['total_price'] as int? ?? 0;
      return sum + totalPrice;
    });
  }
  
  // Total number of orders
  int get _totalSales => _orders.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isVerySmallScreen = constraints.maxWidth < 400;
            
            return Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Penjualan',
                              style: GoogleFonts.oswald(
                                fontSize: isVerySmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                            Text(
                              'Analisis penjualan dan pendapatan GRBK Coffee',
                              style: GoogleFonts.poppins(
                                fontSize: isVerySmallScreen ? 11 : 12,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildExportButton('PDF', Icons.picture_as_pdf_rounded, Colors.red),
                          SizedBox(width: isVerySmallScreen ? 6 : 8),
                          _buildExportButton('Excel', Icons.table_chart_rounded, Colors.green),
                          SizedBox(width: isVerySmallScreen ? 6 : 8),
                          _buildRefreshButton(),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isVerySmallScreen ? 16 : 20),
                  
                  // Revenue and Sales Cards
                  isSmallScreen
                      ? Column(
                          children: [
                            _buildStatCard(
                              'Total Pendapatan',
                              'Rp ${_formatCurrency(_totalRevenue)}',
                              Icons.attach_money_rounded,
                              AppTheme.primaryGradient,
                              constraints,
                            ),
                            SizedBox(height: isVerySmallScreen ? 8 : 10),
                            _buildStatCard(
                              'Jumlah Penjualan',
                              '$_totalSales Pesanan',
                              Icons.receipt_long_rounded,
                              const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                              constraints,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Pendapatan',
                                'Rp ${_formatCurrency(_totalRevenue)}',
                                Icons.attach_money_rounded,
                                AppTheme.primaryGradient,
                                constraints,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                'Jumlah Penjualan',
                                '$_totalSales Pesanan',
                                Icons.receipt_long_rounded,
                                const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                                constraints,
                              ),
                            ),
                          ],
                        ),
                  
                  SizedBox(height: isVerySmallScreen ? 16 : 20),
                  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 10 : 12, 
                      vertical: isVerySmallScreen ? 6 : 8
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warmBeige.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded, 
                          color: AppTheme.deepNavy, 
                          size: isVerySmallScreen ? 14 : 16
                        ),
                        SizedBox(width: isVerySmallScreen ? 6 : 8),
                        Text(
                          'Semua Transaksi',
                          style: GoogleFonts.poppins(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: isVerySmallScreen ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isVerySmallScreen ? 12 : 16),
                  
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.deepNavy.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                                  decoration: const BoxDecoration(
                                    gradient: AppTheme.lightGradient,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Detail Transaksi',
                                          style: GoogleFonts.oswald(
                                            fontSize: isVerySmallScreen ? 12 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Waktu',
                                          style: GoogleFonts.oswald(
                                            fontSize: isVerySmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Items',
                                          style: GoogleFonts.oswald(
                                            fontSize: isVerySmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Total',
                                          style: GoogleFonts.oswald(
                                            fontSize: isVerySmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.deepNavy,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Expanded(
                                  child: _orders.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.receipt_long_rounded,
                                                color: AppTheme.charcoalGray.withValues(alpha: 0.5),
                                                size: isVerySmallScreen ? 40 : 50,
                                              ),
                                              SizedBox(height: isVerySmallScreen ? 8 : 12),
                                              Text(
                                                'Tidak ada data penjualan',
                                                style: GoogleFonts.poppins(
                                                  fontSize: isVerySmallScreen ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                                                ),
                                              ),
                                              SizedBox(height: isVerySmallScreen ? 4 : 6),
                                              Text(
                                                'Belum ada transaksi yang tercatat',
                                                style: GoogleFonts.poppins(
                                                  fontSize: isVerySmallScreen ? 10 : 12,
                                                  color: AppTheme.charcoalGray.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                                          itemCount: _orders.length,
                                          itemBuilder: (context, index) {
                                            final order = _orders[index];
                                            return _buildSalesRow(order, index, isVerySmallScreen);
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.deepNavy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.deepNavy.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        onPressed: _isLoading ? null : _loadOrderData,
        icon: _isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.deepNavy,
                ),
              )
            : Icon(Icons.refresh_rounded, color: AppTheme.deepNavy, size: 16),
        tooltip: 'Refresh Data',
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildSalesRow(OrderModel order, int index, bool isVerySmallScreen) {
    final totalPrice = order.items['total_price'] as int? ?? 0;
    final totalItems = order.items['total_items'] as int? ?? 0;
    final items = order.items['items'] as List<dynamic>? ?? [];
    
    // Get first item name for display (or show count if multiple)
    String itemsDisplay = '';
    if (items.isNotEmpty) {
      final firstItem = items.first;
      final productName = firstItem['product_name'] ?? firstItem['productName'] ?? 'Unknown Product';
      if (items.length == 1) {
        itemsDisplay = productName;
      } else {
        itemsDisplay = '$productName +${items.length - 1} more';
      }
    } else {
      itemsDisplay = 'No items';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _showOrderDetailsDialog(order),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id.substring(0, 8).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  Text(
                    'Order #${order.id.substring(0, 4)}',
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 9 : 10,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    '${order.created.day}/${order.created.month}/${order.created.year}',
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 8 : 9,
                      color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Text(
                '${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(
                  fontSize: isVerySmallScreen ? 9 : 10,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warmBeige.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$totalItems items',
                      style: GoogleFonts.poppins(
                        fontSize: isVerySmallScreen ? 8 : 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemsDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 8 : 9,
                      color: AppTheme.charcoalGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Text(
                'Rp ${_formatCurrency(totalPrice)}',
                style: GoogleFonts.oswald(
                  fontSize: isVerySmallScreen ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(OrderModel order) {
    final items = order.items['items'] as List<dynamic>? ?? [];
    final totalPrice = order.items['total_price'] as int? ?? 0;
    final totalItems = order.items['total_items'] as int? ?? 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order Details',
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.lightGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                    Text(
                      'Payment ID: ${order.paymentId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'Date: ${order.created.day}/${order.created.month}/${order.created.year} ${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Items (${items.length}):',
                style: GoogleFonts.oswald(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final productName = item['product_name'] ?? item['productName'] ?? 'Unknown Product';
                    final productPrice = item['product_price'] ?? item['productPrice'] ?? 0;
                    final quantity = item['quantity'] ?? 1;
                    final itemTotal = item['total_price'] ?? item['totalPrice'] ?? (productPrice * quantity);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.softWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
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
                                Text(
                                  'Rp ${_formatCurrency(productPrice)} × $quantity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${_formatCurrency(itemTotal)}',
                            style: GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($totalItems items)',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(totalPrice)}',
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: TextButton.icon(
        onPressed: () => _exportReport(label),
        icon: Icon(icon, color: color, size: 16),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Gradient gradient, BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : 14),
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
              Icon(icon, color: Colors.white, size: isVerySmallScreen ? 18 : 20),
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
          SizedBox(height: isVerySmallScreen ? 6 : 8),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: isVerySmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 1 : 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 9 : 10,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(String format) async {
    try {
      if (format == 'PDF') {
        await _exportToPdf();
      } else {
        await _exportToExcel();
      }
      
      _showSuccessSnackBar('Laporan berhasil diekspor ke $format!');
    } catch (e) {
      _showErrorSnackBar('Gagal mengekspor laporan: ${e.toString()}');
    }
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GRBK Coffee - Laporan Penjualan',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Semua Transaksi',
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 15),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Pendapatan',
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          'Rp ${_formatCurrency(_totalRevenue)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Jumlah Pesanan',
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          '$_totalSales',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 15),
              
              pw.Container(
                color: PdfColors.grey300,
                padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Order ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Payment ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Time',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Items',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final bgColor = index % 2 == 0 ? PdfColors.grey100 : PdfColors.white;
                  final totalPrice = order.items['total_price'] as int? ?? 0;
                  final totalItems = order.items['total_items'] as int? ?? 0;
                  
                  return pw.Container(
                    color: bgColor,
                    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            order.id,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            order.paymentId,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '${order.created.day}/${order.created.month}/${order.created.year}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '$totalItems',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Rp ${_formatCurrency(totalPrice)}',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    final bytes = await pdf.save();
    
    if (kIsWeb) {
      _downloadFileWeb(bytes, 'GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', 'application/pdf');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
    }
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('GRBK Coffee - Laporan Penjualan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('Semua Transaksi');
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Total Pendapatan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = TextCellValue('Rp ${_formatCurrency(_totalRevenue)}');
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3)).value = TextCellValue('Jumlah Pesanan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3)).value = IntCellValue(_totalSales);
    
    final headers = ['Order ID', 'Payment ID', 'Date', 'Time', 'Items', 'Total'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5)).value = TextCellValue(headers[i]);
    }
    
    for (var i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      final totalPrice = order.items['total_price'] as int? ?? 0;
      final totalItems = order.items['total_items'] as int? ?? 0;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 6)).value = TextCellValue(order.id);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 6)).value = TextCellValue(order.paymentId);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6)).value = TextCellValue('${order.created.day}/${order.created.month}/${order.created.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6)).value = TextCellValue('${order.created.hour}:${order.created.minute.toString().padLeft(2, '0')}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 6)).value = IntCellValue(totalItems);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 6)).value = TextCellValue('Rp ${_formatCurrency(totalPrice)}');
    }
    
    final bytes = excel.encode();
    
    if (bytes != null) {
      if (kIsWeb) {
        _downloadFileWeb(Uint8List.fromList(bytes), 'GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(bytes);
      }
    }
  }

  void _downloadFileWeb(Uint8List bytes, String filename, String mimeType) {
    if (kIsWeb) {
      try {
        final blob = html.Blob([bytes], mimeType);
        final url = html.Url.createObjectUrlFromBlob(blob);
        // ignore: unused_local_variable
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        debugPrint('Error downloading file: $e');
        rethrow;
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
