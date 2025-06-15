import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../utils/app_theme.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> with TickerProviderStateMixin {
  bool _isStarted = false;
  bool _isScanning = false;
  bool _orderFound = false;
  final TextEditingController _orderIdController = TextEditingController();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Sample order data
  final Map<String, dynamic> _sampleOrder = {
    'orderId': 'GRBK2024001',
    'customerName': 'Ahmad Rizki',
    'items': [
      {'name': 'GRBK Special Blend', 'quantity': 2, 'price': 35000},
      {'name': 'Artisan Croissant', 'quantity': 1, 'price': 18000},
    ],
    'total': 88000,
    'timestamp': '2024-12-16 14:30:00',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Kasir',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          Text(
            'Scan QR code atau input ID pesanan untuk konfirmasi pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.charcoalGray,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Main Content
          Expanded(
            child: _isStarted ? _buildCashierInterface() : _buildStartInterface(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartInterface() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Coffee Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_cafe_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Welcome Text
            Text(
              'Start #TeamGRBK',
              style: GoogleFonts.oswald(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Mulai melayani pelanggan dengan sistem kasir GRBK',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.charcoalGray,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isStarted = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mulai Kasir',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
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

  Widget _buildCashierInterface() {
    if (_orderFound) {
      return _buildOrderDetails();
    }
    
    return Column(
      children: [
        // Scan Section
        Expanded(
          child: _buildScanSection(),
        ),
        
        const SizedBox(height: 16),
        
        // Manual Input Section
        Expanded(
          child: _buildManualInputSection(),
        ),
      ],
    );
  }

  Widget _buildScanSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scan Icon with Animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isScanning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _isScanning 
                        ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                        : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: (_isScanning ? Colors.green : AppTheme.deepNavy).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isScanning ? Icons.qr_code_scanner_rounded : Icons.qr_code_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _isScanning ? 'Scanning...' : 'Tap to Scan',
            style: GoogleFonts.oswald(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isScanning ? Colors.green : AppTheme.deepNavy,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _isScanning 
                ? 'Menunggu QR code dari perangkat scanner'
                : 'Gunakan scanner QR code untuk memindai pesanan pelanggan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.charcoalGray,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Scan Button
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: _isScanning 
                  ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange])
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: _isScanning ? _stopScanning : _startScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isScanning ? 'Stop Scanning' : 'Start Scanning',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Manual Input Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepNavy.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Input Manual',
            style: GoogleFonts.oswald(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Masukkan ID pesanan secara manual jika QR code tidak dapat dipindai',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.charcoalGray,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Order ID Input
          TextField(
            controller: _orderIdController,
            style: GoogleFonts.poppins(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Order ID',
              hintText: 'Contoh: GRBK2024001',
              labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
              hintStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray.withValues(alpha: 0.7), fontSize: 12),
              prefixIcon: const Icon(Icons.receipt_long_rounded, color: AppTheme.charcoalGray, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.warmBeige),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.deepNavy, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.softWhite,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search Button
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: _searchOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Cari Pesanan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pesanan',
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                    Text(
                      'Order ID: ${_sampleOrder['orderId']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _orderFound = false;
                    _orderIdController.clear();
                  });
                },
                icon: const Icon(Icons.close_rounded, color: AppTheme.charcoalGray, size: 20),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Customer Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.lightGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.deepNavy,
                  child: Text(
                    _sampleOrder['customerName'][0],
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sampleOrder['customerName'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      Text(
                        _sampleOrder['timestamp'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Order Items
          Text(
            'Item Pesanan',
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              itemCount: _sampleOrder['items'].length,
              itemBuilder: (context, index) {
                final item = _sampleOrder['items'][index];
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                            Text(
                              'Qty: ${item['quantity']}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${item['price'] * item['quantity']}',
                        style: GoogleFonts.oswald(
                          fontSize: 12,
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
          
          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.oswald(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Rp ${_sampleOrder['total']}',
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Confirm Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Konfirmasi Pembayaran',
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _pulseController.repeat(reverse: true);
    
    // Simulate scan success after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (_isScanning) {
        _stopScanning();
        setState(() {
          _orderFound = true;
        });
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _pulseController.stop();
  }

  void _searchOrder() {
    if (_orderIdController.text.isNotEmpty) {
      setState(() {
        _orderFound = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masukkan Order ID terlebih dahulu',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _confirmPayment() {
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'Pembayaran Dikonfirmasi!',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pesanan ${_sampleOrder['orderId']} telah dikonfirmasi dan akan masuk ke laporan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _orderFound = false;
                    _orderIdController.clear();
                  });
                  _showSuccessSnackBar('Pembayaran berhasil dikonfirmasi!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Selesai',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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