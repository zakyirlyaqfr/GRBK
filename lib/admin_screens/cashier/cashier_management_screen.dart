import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart'; // PACKAGE BARU
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/payment_model.dart';
import '../../services/debug_service.dart';

class CashierManagementScreen extends StatefulWidget {
  const CashierManagementScreen({super.key});

  @override
  State<CashierManagementScreen> createState() =>
      _CashierManagementScreenState();
}

class _CashierManagementScreenState extends State<CashierManagementScreen>
    with TickerProviderStateMixin {
  bool _isStarted = false;
  bool _isScanning = false;
  bool _orderFound = false;
  final bool _isWebPlatform = kIsWeb;

  final TextEditingController _orderIdController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // PERBAIKAN: Menggunakan MobileScannerController agar bisa membaca QR
  late MobileScannerController _scannerController;

  PaymentModel? _currentPayment;

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

    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orderIdController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    if (!_isWebPlatform) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showPermissionDeniedDialog();
        return;
      }
    }
    _startScanning();
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Izin Kamera Diperlukan',
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        content: Text(
          'Untuk memindai QR code, aplikasi memerlukan izin untuk mengakses kamera. Silakan berikan izin di pengaturan perangkat Anda.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.charcoalGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (!_isWebPlatform) {
                openAppSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepNavy,
            ),
            child: Text(
              _isWebPlatform ? 'OK' : 'Buka Pengaturan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  _buildResponsiveHeader(constraints),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  if (_isWebPlatform) _buildWebIndicator(),
                  Expanded(
                    child: _isStarted
                        ? _buildCashierInterface(constraints)
                        : _buildStartInterface(constraints),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.web, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            'Web Version - Camera Ready',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeader(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kasir',
          style: GoogleFonts.oswald(
            fontSize: isVerySmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isWebPlatform
              ? 'Scan QR code menggunakan kamera web atau input ID pesanan untuk konfirmasi pembayaran'
              : 'Scan QR code atau input ID pesanan untuk konfirmasi pembayaran',
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 11 : 12,
            color: AppTheme.charcoalGray,
          ),
        ),
      ],
    );
  }

  Widget _buildStartInterface(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isVerySmallScreen ? 300 : 350),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isVerySmallScreen ? 80 : 100,
              height: isVerySmallScreen ? 80 : 100,
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
              child: Icon(
                Icons.local_cafe_rounded,
                color: Colors.white,
                size: isVerySmallScreen ? 40 : 50,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 20 : 24),

            Text(
              'Start #TeamGRBK',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 10 : 12),

            Text(
              _isWebPlatform
                  ? 'Mulai melayani pelanggan dengan sistem kasir GRBK di web browser'
                  : 'Mulai melayani pelanggan dengan sistem kasir GRBK',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 12 : 14,
                color: AppTheme.charcoalGray,
                height: 1.5,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 24 : 32),

            Container(
              width: double.infinity,
              height: isVerySmallScreen ? 44 : 48,
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
                        fontSize: isVerySmallScreen ? 14 : 16,
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

  Widget _buildCashierInterface(BoxConstraints constraints) {
    if (_orderFound && _currentPayment != null) {
      return _buildOrderDetails(constraints);
    }

    final isSmallScreen = constraints.maxWidth < 600;

    if (isSmallScreen) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - 100,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                SizedBox(
                  height: _isScanning ? 440 : 320, 
                  child: _buildScanSection(constraints),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 320,
                  child: _buildManualInputSection(constraints),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildScanSection(constraints),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildManualInputSection(constraints),
          ),
        ],
      );
    }
  }

  Widget _buildScanSection(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
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
          if (!_isScanning) ...[
            Container(
              width: isVerySmallScreen ? 70 : 80,
              height: isVerySmallScreen ? 70 : 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isScanning ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: isVerySmallScreen ? 35 : 40,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 12 : 16),
          ],

          Text(
            'Scan QR Code',
            style: GoogleFonts.oswald(
              fontSize: isVerySmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: _isScanning ? Colors.green : AppTheme.deepNavy,
            ),
          ),

          SizedBox(height: isVerySmallScreen ? 6 : 8),

          Text(
            _isScanning
                ? (_isWebPlatform
                    ? 'Arahkan kamera web ke QR code pesanan'
                    : 'Arahkan kamera ke QR code pesanan')
                : (_isWebPlatform
                    ? 'Gunakan kamera web untuk memindai QR code pesanan pelanggan'
                    : 'Gunakan kamera untuk memindai QR code pesanan pelanggan'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 11 : 12,
              color: AppTheme.charcoalGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: isVerySmallScreen ? 16 : 20),

          // Tampilan Kamera Aktif
          if (_isScanning)
            Container(
              height: 240, 
              width: double.infinity,
              margin: EdgeInsets.only(bottom: isVerySmallScreen ? 12 : 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            final String code = barcode.rawValue!;
                            // Langsung proses pencarian otomatis
                            setState(() {
                              _orderIdController.text = code;
                            });
                            _stopScanning();
                            _searchOrder();
                            break; 
                          }
                        }
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_ios_rounded, 
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => _scannerController.switchCamera(),
                          tooltip: 'Ganti Kamera',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Container(
            width: double.infinity,
            height: isVerySmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              gradient: _isScanning
                  ? const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange])
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: _isScanning ? _stopScanning : _requestCameraPermission,
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
                  Icon(
                      _isScanning
                          ? Icons.stop_rounded
                          : Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: isVerySmallScreen ? 16 : 18),
                  SizedBox(width: isVerySmallScreen ? 4 : 6),
                  Text(
                    _isScanning ? 'Stop Scanning' : 'Mulai Scan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isVerySmallScreen ? 12 : 14,
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

  Widget _buildManualInputSection(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isVerySmallScreen ? 70 : 80,
              height: isVerySmallScreen ? 70 : 80,
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
              child: Icon(
                Icons.keyboard_rounded,
                color: Colors.white,
                size: isVerySmallScreen ? 35 : 40,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Text(
              'Input Manual',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 6 : 8),

            Text(
              'Masukkan ID pesanan secara manual jika QR code tidak dapat dipindai',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 11 : 12,
                color: AppTheme.charcoalGray,
                height: 1.4,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 16 : 20),

            TextField(
              controller: _orderIdController,
              style: GoogleFonts.poppins(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
                fontSize: isVerySmallScreen ? 13 : 14,
              ),
              decoration: InputDecoration(
                labelText: 'Payment ID',
                hintText: '#60o11zq6a992qmo',
                labelStyle: GoogleFonts.poppins(
                    color: AppTheme.charcoalGray,
                    fontSize: isVerySmallScreen ? 11 : 12),
                hintStyle: GoogleFonts.poppins(
                    color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                    fontSize: isVerySmallScreen ? 11 : 12),
                prefixIcon: const Icon(Icons.receipt_long_rounded,
                    color: AppTheme.charcoalGray, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.warmBeige),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppTheme.deepNavy, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.softWhite,
                contentPadding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Container(
              width: double.infinity,
              height: isVerySmallScreen ? 36 : 40,
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
                    Icon(Icons.search_rounded,
                        color: Colors.white, size: isVerySmallScreen ? 16 : 18),
                    SizedBox(width: isVerySmallScreen ? 4 : 6),
                    Text(
                      'Cari Pesanan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isVerySmallScreen ? 12 : 14,
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

  Widget _buildOrderDetails(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: isVerySmallScreen ? 40 : 50,
                  height: isVerySmallScreen ? 40 : 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: isVerySmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Pesanan',
                        style: GoogleFonts.oswald(
                          fontSize: isVerySmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      Text(
                        'Payment ID: ${_currentPayment!.id}',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 11 : 12,
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
                      _currentPayment = null;
                      _orderIdController.clear();
                    });
                  },
                  icon: Icon(Icons.close_rounded,
                      color: AppTheme.charcoalGray,
                      size: isVerySmallScreen ? 18 : 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isVerySmallScreen ? 16 : 20,
                    backgroundColor: AppTheme.deepNavy,
                    child: Text(
                      _currentPayment!.userName.isNotEmpty
                          ? _currentPayment!.userName[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: isVerySmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPayment!.userName.isNotEmpty
                              ? _currentPayment!.userName
                              : 'Unknown Customer',
                          style: GoogleFonts.poppins(
                            fontSize: isVerySmallScreen ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                        Text(
                          '${_currentPayment!.created.day}/${_currentPayment!.created.month}/${_currentPayment!.created.year} ${_currentPayment!.created.hour}:${_currentPayment!.created.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            fontSize: isVerySmallScreen ? 9 : 10,
                            color: AppTheme.charcoalGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Text(
              'Item Pesanan',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 8 : 12),

            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _currentPayment!.items.length,
                itemBuilder: (context, index) {
                  final item = _currentPayment!.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.softWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.warmBeige.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 9 : 10,
                                  color: AppTheme.charcoalGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${item.totalPrice}',
                          style: GoogleFonts.oswald(
                            fontSize: isVerySmallScreen ? 11 : 12,
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

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
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
                      fontSize: isVerySmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Rp ${_currentPayment!.totalPrice}',
                    style: GoogleFonts.oswald(
                      fontSize: isVerySmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            Container(
              width: double.infinity,
              height: isVerySmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen]),
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
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: isVerySmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: isVerySmallScreen ? 8 : 10),
                    Flexible(
                      child: Text(
                        'Konfirmasi Pembayaran',
                        style: GoogleFonts.oswald(
                          fontSize: isVerySmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _scannerController.start();
    _pulseController.repeat(reverse: true);
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scannerController.stop();
    _pulseController.stop();
  }

  // PERBAIKAN: Fungsi Auto-Cleaner untuk Input Manual
  void _searchOrder() async {
    String rawInput = _orderIdController.text.trim();

    // Membersihkan teks dari karakter '#', spasi, dan tulisan yang tidak perlu
    String cleanId = rawInput.replaceAll('#', '').trim();
    cleanId = cleanId.replaceAll(RegExp(r'Order\s*#?GRBK', caseSensitive: false), '');
    cleanId = cleanId.replaceAll(RegExp(r'Order\s*#?', caseSensitive: false), '').trim();

    if (cleanId.isEmpty) {
      _showErrorSnackBar('Masukkan Payment ID terlebih dahulu');
      return;
    }

    // Memastikan ID PocketBase berisikan tepat 15 karakter
    if (cleanId.length != 15) {
      _showErrorSnackBar('ID PocketBase harus 15 karakter. Anda memasukkan ${cleanId.length} karakter.');
      return;
    }

    final paymentProvider = context.read<PaymentProvider>();
    final payment = await paymentProvider.getPaymentById(cleanId);

    if (!mounted) return;

    if (payment != null && payment.status == false) {
      setState(() {
        _currentPayment = payment;
        _orderFound = true;
      });
    } else {
      _showErrorSnackBar(
          'Payment tidak ditemukan atau sudah dikonfirmasi. Periksa kembali Payment ID.');
    }
  }

  void _confirmPayment() {
    if (_currentPayment == null) return;

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
                  gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'Konfirmasi Pembayaran',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Apakah Anda yakin ingin mengkonfirmasi pembayaran untuk pesanan ini?',
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
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        final paymentToProcess = _currentPayment!;

                        final paymentProvider = context.read<PaymentProvider>();
                        final orderProvider = context.read<OrderProvider>();
                        final cartProvider = context.read<CartProvider>();

                        DebugService.logPaymentToOrderFlow(
                          step: 'CASHIER_CONFIRMATION_START',
                          data: {
                            'payment_id': paymentToProcess.id,
                            'user_id': paymentToProcess.userId,
                            'total_price': paymentToProcess.totalPrice,
                            'total_items': paymentToProcess.totalItems,
                            'items_count': paymentToProcess.items.length,
                          },
                        );

                        setState(() {
                          _orderFound = false;
                          _currentPayment = null;
                          _orderIdController.clear();
                        });

                        try {
                          final success = await paymentProvider
                              .updatePaymentStatus(paymentToProcess.id, true);

                          if (success) {
                            DebugService.logPaymentToOrderFlow(
                              step: 'PAYMENT_STATUS_UPDATED',
                              data: {
                                'payment_id': paymentToProcess.id,
                                'new_status': true,
                              },
                            );

                            final orderItems = {
                              'items': paymentToProcess.items
                                  .map((item) => item.toJson())
                                  .toList(),
                              'total_price': paymentToProcess.totalPrice,
                              'total_items': paymentToProcess.totalItems,
                            };

                            DebugService.logPaymentToOrderFlow(
                              step: 'CREATING_ORDER',
                              data: {
                                'payment_id': paymentToProcess.id,
                                'user_id': paymentToProcess.userId,
                                'order_items': orderItems,
                              },
                            );

                            final order = await orderProvider.createOrder(
                              usersId: paymentToProcess.userId,
                              paymentId: paymentToProcess.id,
                              items: orderItems,
                            );

                            if (order != null) {
                              DebugService.logSuccess(
                                operation: 'ORDER_CREATION',
                                result: {
                                  'order_id': order.id,
                                  'payment_id': order.paymentId,
                                  'user_id': order.usersId,
                                },
                              );

                              await cartProvider.clearCartForPayment(
                                  paymentToProcess.userId);

                              if (mounted) {
                                _showSuccessSnackBar(
                                    'Pembayaran berhasil dikonfirmasi dan order telah dibuat!');
                              }
                            } else {
                              throw Exception('Order creation returned null');
                            }
                          } else {
                            throw Exception('Failed to update payment status');
                          }
                        } catch (e) {
                          DebugService.logError(
                            context: 'CASHIER_PAYMENT_CONFIRMATION',
                            error: e,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        // PERBAIKAN: Padding dikurangi agar tidak makan ruang
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      // PERBAIKAN: Dibungkus dengan FittedBox agar huruf mengecil otomatis jika ruang sempit
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Konfirmasi',
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
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}