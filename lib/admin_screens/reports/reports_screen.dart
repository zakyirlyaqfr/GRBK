import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

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
    },
    {
      'orderId': 'GRBK2024002',
      'customerName': 'Sari Dewi',
      'items': 2,
      'total': 53000,
      'time': '15:15',
      'paymentMethod': 'Kasir',
    },
    {
      'orderId': 'GRBK2024003',
      'customerName': 'Budi Santoso',
      'items': 1,
      'total': 35000,
      'time': '16:00',
      'paymentMethod': 'Kasir',
    },
    {
      'orderId': 'GRBK2024004',
      'customerName': 'Maya Putri',
      'items': 4,
      'total': 112000,
      'time': '16:45',
      'paymentMethod': 'Kasir',
    },
  ];

  int get _totalRevenue => _salesData.fold(0, (sum, sale) => sum + (sale['total'] as int));
  int get _totalOrders => _salesData.length;
  double get _averageOrder => _totalOrders > 0 ? _totalRevenue / _totalOrders : 0;

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
                      'Laporan Penjualan',
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                    Text(
                      'Analisis penjualan dan pendapatan GRBK Coffee',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildExportButton('PDF', Icons.picture_as_pdf_rounded, Colors.red),
                  const SizedBox(width: 8),
                  _buildExportButton('Excel', Icons.table_chart_rounded, Colors.green),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Period Filter
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
                    labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
                    prefixIcon: const Icon(Icons.date_range_rounded, color: AppTheme.charcoalGray, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _periods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_selectedPeriod == 'Custom') ...[
                const SizedBox(height: 12),
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
                      labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
                      hintText: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppTheme.charcoalGray, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                'Total Pendapatan',
                'Rp $_totalRevenue',
                Icons.attach_money_rounded,
                AppTheme.primaryGradient,
              ),
              _buildStatCard(
                'Jumlah Pesanan',
                '$_totalOrders',
                Icons.receipt_long_rounded,
                const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              ),
              _buildStatCard(
                'Rata-rata Order',
                'Rp ${_averageOrder.toInt()}',
                Icons.trending_up_rounded,
                const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Sales Table
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
                    padding: const EdgeInsets.all(16),
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Waktu',
                            style: GoogleFonts.oswald(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Items',
                            style: GoogleFonts.oswald(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Total',
                            style: GoogleFonts.oswald(
                              fontSize: 12,
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
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _salesData.length,
                      itemBuilder: (context, index) {
                        final sale = _salesData[index];
                        return _buildSalesRow(sale, index);
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

  Widget _buildStatCard(String title, String value, IconData icon, Gradient gradient) {
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
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 16,
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

  Widget _buildSalesRow(Map<String, dynamic> sale, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                Text(
                  sale['customerName'],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.charcoalGray,
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
                fontSize: 10,
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
                  fontSize: 10,
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
                fontSize: 12,
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
            colorScheme: ColorScheme.light(
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

  void _exportReport(String format) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppTheme.lightGradient,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  format == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ekspor Laporan',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Laporan akan diekspor dalam format $format',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.charcoalGray),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessSnackBar('Laporan berhasil diekspor ke $format!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepNavy,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Ekspor',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      ),
    );
  }
}