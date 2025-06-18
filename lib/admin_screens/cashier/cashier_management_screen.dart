import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/payment_model.dart';

class CashierManagementScreen extends StatefulWidget {
  const CashierManagementScreen({super.key});

  @override
  State<CashierManagementScreen> createState() => _CashierManagementScreenState();
}

class _CashierManagementScreenState extends State<CashierManagementScreen>
    with TickerProviderStateMixin {
  bool _isStarted = false;
  bool _isScanning = false;
  bool _orderFound = false;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  final bool _isWebPlatform = kIsWeb;

  final TextEditingController _orderIdController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

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

    // Check camera permission
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orderIdController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    if (_isWebPlatform) {
      // For web, we'll handle permission during camera initialization
      setState(() {
        _isCameraPermissionGranted = true;
      });
    } else {
      // For mobile platforms
      final status = await Permission.camera.status;
      setState(() {
        _isCameraPermissionGranted = status.isGranted;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    if (_isWebPlatform) {
      // Web handles permissions automatically during camera access
      _initializeCamera();
    } else {
      final status = await Permission.camera.request();
      setState(() {
        _isCameraPermissionGranted = status.isGranted;
      });

      if (status.isGranted) {
        _initializeCamera();
      } else {
        _showPermissionDeniedDialog();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          _isWebPlatform ? ResolutionPreset.high : ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        if (_isWebPlatform && e.toString().contains('NotAllowedError')) {
          _showWebPermissionDeniedDialog();
        } else {
          _showErrorSnackBar('Gagal menginisialisasi kamera: ${e.toString()}');
        }
      }
    }
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

  void _showWebPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Akses Kamera Ditolak',
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        content: Text(
          'Browser Anda menolak akses kamera. Silakan:\n\n'
          '1. Klik ikon kamera di address bar\n'
          '2. Pilih "Allow" untuk mengizinkan akses kamera\n'
          '3. Refresh halaman dan coba lagi\n\n'
          'Atau gunakan input manual untuk memasukkan Order ID.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.charcoalGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: GoogleFonts.poppins(
                color: AppTheme.deepNavy,
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
                  // Header - Responsive
                  _buildResponsiveHeader(constraints),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Platform indicator for web
                  if (_isWebPlatform) _buildWebIndicator(),

                  // Main Content - Responsive with proper constraints
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
            // Coffee Icon
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

            // Welcome Text
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

            // Start Button
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
      // Mobile layout - Stack vertically with proper scrolling and fixed heights
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight - 100, // Account for header and padding
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Scan Section - Fixed height to prevent overflow
                SizedBox(
                  height: 320, // Fixed height
                  child: _buildScanSection(constraints),
                ),

                const SizedBox(height: 16),

                // Manual Input Section - Fixed height to prevent overflow
                SizedBox(
                  height: 320, // Fixed height
                  child: _buildManualInputSection(constraints),
                ),

                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      );
    } else {
      // Desktop layout - Side by side
      return Row(
        children: [
          // Scan Section
          Expanded(
            child: _buildScanSection(constraints),
          ),

          const SizedBox(width: 16),

          // Manual Input Section
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
          // QR Scan Icon - Same style as manual input
          Container(
            width: isVerySmallScreen ? 70 : 80,
            height: isVerySmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              gradient: _isScanning
                  ? const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen])
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (_isScanning ? Colors.green : AppTheme.deepNavy)
                      .withValues(alpha: 0.2),
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
                    _isScanning
                        ? Icons.camera_alt_rounded
                        : Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: isVerySmallScreen ? 35 : 40,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: isVerySmallScreen ? 12 : 16),

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

          // Camera Preview Area (when scanning)
          if (_isScanning && _isCameraInitialized && _cameraController != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: isVerySmallScreen ? 12 : 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _isWebPlatform
                      ? 16 / 9
                      : _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          // Scan Button - Same style as manual input
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
              onPressed: _isScanning ? _stopScanning : _startScanning,
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
            // Manual Input Icon
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
              'Masukkan ID pesanan secara manual jika QR code tidak dapat dipindai atau kamera tidak tersedia',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 11 : 12,
                color: AppTheme.charcoalGray,
                height: 1.4,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 16 : 20),

            // Order ID Input
            TextField(
              controller: _orderIdController,
              style: GoogleFonts.poppins(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
                fontSize: isVerySmallScreen ? 13 : 14,
              ),
              decoration: InputDecoration(
                labelText: 'Payment ID',
                hintText: 'Masukkan Payment ID',
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
                  borderSide: const BorderSide(color: AppTheme.deepNavy, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.softWhite,
                contentPadding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            // Search Button
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
            // Header
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

            // Customer Info
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

            // Order Items
            Text(
              'Item Pesanan',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 8 : 12),

            // Order Items List - Fixed height container to prevent overflow
            SizedBox(
              height: 120, // Fixed height
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

            // Total
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

            // Confirm Button
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
                    Text(
                      'Konfirmasi Pembayaran',
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

  void _startScanning() {
    if (!_isCameraPermissionGranted) {
      _requestCameraPermission();
      return;
    }

    setState(() {
      _isScanning = true;
    });

    if (_isCameraInitialized) {
      _pulseController.repeat(reverse: true);

      // Simulate scan success after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (_isScanning && mounted) {
          _stopScanning();
          // Simulate finding a payment (you would replace this with actual QR scanning logic)
          _simulatePaymentFound();
        }
      });
    } else {
      _initializeCamera().then((_) {
        if (_isCameraInitialized && mounted) {
          _pulseController.repeat(reverse: true);

          // Simulate scan success after 3 seconds
          Timer(const Duration(seconds: 3), () {
            if (_isScanning && mounted) {
              _stopScanning();
              _simulatePaymentFound();
            }
          });
        } else {
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            _showErrorSnackBar('Gagal menginisialisasi kamera');
          }
        }
      });
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _pulseController.stop();
  }

  void _searchOrder() async {
    if (_orderIdController.text.isNotEmpty) {
      final paymentProvider = context.read<PaymentProvider>();
      final payment = await paymentProvider.getPaymentById(_orderIdController.text.trim());
      
      if (payment != null) {
        setState(() {
          _currentPayment = payment;
          _orderFound = true;
        });
      } else {
        _showErrorSnackBar('Payment tidak ditemukan. Periksa kembali Payment ID.');
      }
    } else {
      _showErrorSnackBar('Masukkan Payment ID terlebih dahulu');
    }
  }

  void _simulatePaymentFound() {
    // This simulates finding a payment via QR scan
    // In real implementation, you would parse the QR code data to get the payment ID
    const String simulatedPaymentId = "sample_payment_id"; // Replace with actual scanned payment ID
    
    context.read<PaymentProvider>().getPaymentById(simulatedPaymentId).then((payment) {
      if (payment != null && mounted) {
        setState(() {
          _currentPayment = payment;
          _orderFound = true;
        });
      } else if (mounted) {
        _showErrorSnackBar('Payment tidak ditemukan dari QR code');
      }
    });
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
                        
                        // Update payment status to confirmed
                        final success = await context.read<PaymentProvider>()
                            .updatePaymentStatus(_currentPayment!.id, true);
                        
                        if (success) {
                          // Clear cart items for this payment
                          await context.read<CartProvider>().clearCartForPayment(_currentPayment!.userId);
                          
                          setState(() {
                            _orderFound = false;
                            _currentPayment = null;
                            _orderIdController.clear();
                          });
                          _showSuccessSnackBar('Pembayaran berhasil dikonfirmasi!');
                        } else {
                          _showErrorSnackBar('Gagal mengkonfirmasi pembayaran');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Konfirmasi',
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
