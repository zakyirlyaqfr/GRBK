import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import '../../utils/app_theme.dart';

// Web-specific imports - conditional
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Hari Ini';
  
  final List<String> _periods = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Custom'];
  
  final List<Map<String, dynamic>> _salesData = [
    {
      'orderId': 'GRBK2024001',
      'customerName': 'Ahmad Rizki',
      'items': 3,
      'total': 88000,
      'time': '14:30',
      'paymentMethod': 'Kasir',
      'date': '16/06/2024',
    },
    {
      'orderId': 'GRBK2024002',
      'customerName': 'Sari Dewi',
      'items': 2,
      'total': 53000,
      'time': '15:15',
      'paymentMethod': 'Kasir',
      'date': '16/06/2024',
    },
    {
      'orderId': 'GRBK2024003',
      'customerName': 'Budi Santoso',
      'items': 1,
      'total': 35000,
      'time': '16:00',
      'paymentMethod': 'Kasir',
      'date': '15/06/2024',
    },
    {
      'orderId': 'GRBK2024004',
      'customerName': 'Maya Putri',
      'items': 4,
      'total': 112000,
      'time': '16:45',
      'paymentMethod': 'Kasir',
      'date': '14/06/2024',
    },
    {
      'orderId': 'GRBK2024005',
      'customerName': 'Dian Permata',
      'items': 2,
      'total': 67000,
      'time': '10:15',
      'paymentMethod': 'Kasir',
      'date': '10/06/2024',
    },
    {
      'orderId': 'GRBK2024006',
      'customerName': 'Rudi Hartono',
      'items': 3,
      'total': 95000,
      'time': '13:30',
      'paymentMethod': 'Kasir',
      'date': '05/06/2024',
    },
  ];

  List<Map<String, dynamic>> get _filteredSalesData {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'Hari Ini':
        final today = '${now.day}/${now.month}/${now.year}';
        return _salesData.where((sale) => sale['date'] == today).toList();
      
      case 'Minggu Ini':
        // Calculate the start of the week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        
        return _salesData.where((sale) {
          final parts = sale['date'].split('/');
          final saleDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
          
          return saleDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                 saleDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      
      case 'Bulan Ini':
        final thisMonth = '${now.month}/${now.year}';
        
        return _salesData.where((sale) {
          final parts = sale['date'].split('/');
          final saleMonth = '${int.parse(parts[1])}/${parts[2]}';
          
          return saleMonth == thisMonth;
        }).toList();
      
      case 'Custom':
        final selectedDateStr = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
        return _salesData.where((sale) => sale['date'] == selectedDateStr).toList();
      
      default:
        return _salesData;
    }
  }

  int get _totalRevenue => _filteredSalesData.fold(0, (sum, sale) => sum + (sale['total'] as int));
  int get _totalOrders => _filteredSalesData.length;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return Container(
          padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Responsive
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
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: isVerySmallScreen ? 16 : 20),
              
              // Period Filter - Responsive
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepNavy.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      onChanged: (value) => setState(() => _selectedPeriod = value!),
                      decoration: InputDecoration(
                        labelText: 'Periode',
                        labelStyle: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray, 
                          fontSize: isVerySmallScreen ? 11 : 12
                        ),
                        prefixIcon: const Icon(Icons.date_range_rounded, color: AppTheme.charcoalGray, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 12 : 16, 
                          vertical: isVerySmallScreen ? 10 : 12
                        ),
                      ),
                      items: _periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(
                            period,
                            style: GoogleFonts.poppins(
                              color: AppTheme.deepNavy, 
                              fontSize: isVerySmallScreen ? 12 : 14
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_selectedPeriod == 'Custom') ...[
                    SizedBox(height: isVerySmallScreen ? 10 : 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.deepNavy.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: InputDecoration(
                          labelText: 'Pilih Tanggal',
                          labelStyle: GoogleFonts.poppins(
                            color: AppTheme.charcoalGray, 
                            fontSize: isVerySmallScreen ? 11 : 12
                          ),
                          hintText: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppTheme.charcoalGray, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 12 : 16, 
                            vertical: isVerySmallScreen ? 10 : 12
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: isVerySmallScreen ? 16 : 20),
              
              // Statistics Cards - Responsive
              isSmallScreen
                  ? Column(
                      children: [
                        _buildStatCard(
                          'Total Pendapatan',
                          'Rp $_totalRevenue',
                          Icons.attach_money_rounded,
                          AppTheme.primaryGradient,
                          constraints,
                        ),
                        SizedBox(height: isVerySmallScreen ? 8 : 10),
                        _buildStatCard(
                          'Jumlah Pesanan',
                          '$_totalOrders',
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
                            'Rp $_totalRevenue',
                            Icons.attach_money_rounded,
                            AppTheme.primaryGradient,
                            constraints,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            'Jumlah Pesanan',
                            '$_totalOrders',
                            Icons.receipt_long_rounded,
                            const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                            constraints,
                          ),
                        ),
                      ],
                    ),
              
              SizedBox(height: isVerySmallScreen ? 16 : 20),
              
              // Period indicator
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
                      Icons.calendar_today_rounded, 
                      color: AppTheme.deepNavy, 
                      size: isVerySmallScreen ? 14 : 16
                    ),
                    SizedBox(width: isVerySmallScreen ? 6 : 8),
                    Text(
                      _getPeriodLabel(),
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
              
              // Sales Table - Responsive
              Expanded(
                child: Container(
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
                      // Table Header
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
                      
                      // Table Content
                      Expanded(
                        child: _filteredSalesData.isEmpty
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
                                      'Coba pilih periode waktu yang berbeda',
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
                                itemCount: _filteredSalesData.length,
                                itemBuilder: (context, index) {
                                  final sale = _filteredSalesData[index];
                                  return _buildSalesRow(sale, index, isVerySmallScreen);
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
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'Hari Ini':
        final now = DateTime.now();
        return 'Hari Ini, ${now.day}/${now.month}/${now.year}';
      case 'Minggu Ini':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return 'Minggu Ini, ${startOfWeek.day}/${startOfWeek.month} - ${now.day}/${now.month}';
      case 'Bulan Ini':
        final now = DateTime.now();
        return 'Bulan Ini, ${_getMonthName(now.month)} ${now.year}';
      case 'Custom':
        return 'Tanggal ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      default:
        return 'Semua Periode';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
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

  Widget _buildSalesRow(Map<String, dynamic> sale, int index, bool isVerySmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Transaction Details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale['orderId'],
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                Text(
                  sale['customerName'],
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 9 : 10,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  sale['date'],
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 8 : 9,
                    color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Time
          Expanded(
            child: Text(
              sale['time'],
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 9 : 10,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          
          // Items
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warmBeige.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${sale['items']} items',
                style: GoogleFonts.poppins(
                  fontSize: isVerySmallScreen ? 9 : 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Total
          Expanded(
            child: Text(
              'Rp ${sale['total']}',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 11 : 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
    
    // Add title
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
                _getPeriodLabel(),
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Summary
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
                          'Rp $_totalRevenue',
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
                          '$_totalOrders',
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
              
              // Table header
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
                        'Customer',
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
              
              // Table content
              pw.ListView.builder(
                itemCount: _filteredSalesData.length,
                itemBuilder: (context, index) {
                  final sale = _filteredSalesData[index];
                  final bgColor = index % 2 == 0 ? PdfColors.grey100 : PdfColors.white;
                  
                  return pw.Container(
                    color: bgColor,
                    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            sale['orderId'],
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            sale['customerName'],
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            sale['date'],
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            sale['time'],
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '${sale['items']}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Rp ${sale['total']}',
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
              
              // Footer
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
    
    // Save and download the PDF
    final bytes = await pdf.save();
    
    if (kIsWeb) {
      // For web platform using modern JS interop
      _downloadFileWeb(bytes, 'GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.pdf', 'application/pdf');
    } else {
      // For mobile platforms
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
    }
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];
    
    // Add title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('GRBK Coffee - Laporan Penjualan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue(_getPeriodLabel());
    
    // Add summary
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = TextCellValue('Total Pendapatan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = TextCellValue('Rp $_totalRevenue');
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3)).value = TextCellValue('Jumlah Pesanan');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3)).value = IntCellValue(_totalOrders);
    
    // Add headers
    final headers = ['Order ID', 'Customer', 'Date', 'Time', 'Items', 'Total'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5)).value = TextCellValue(headers[i]);
    }
    
    // Add data
    for (var i = 0; i < _filteredSalesData.length; i++) {
      final sale = _filteredSalesData[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 6)).value = TextCellValue(sale['orderId']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 6)).value = TextCellValue(sale['customerName']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6)).value = TextCellValue(sale['date']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6)).value = TextCellValue(sale['time']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 6)).value = IntCellValue(sale['items']);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 6)).value = TextCellValue('Rp ${sale['total']}');
    }
    
    // Save and download the Excel file
    final bytes = excel.encode();
    
    if (bytes != null) {
      if (kIsWeb) {
        // For web platform using modern JS interop
        _downloadFileWeb(Uint8List.fromList(bytes), 'GRBK_Coffee_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      } else {
        // For mobile platforms
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
