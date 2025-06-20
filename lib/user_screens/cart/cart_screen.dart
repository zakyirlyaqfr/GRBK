import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../utils/app_theme.dart';
import '../../user_screens/home/home_screen.dart';
import '../../providers/cart_provider.dart';
// import '../../providers/product_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/payment_model.dart';
import '../../utils/pocketbase_debug.dart';
import '../../services/payment_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // ignore: unused_field
  PaymentModel? _currentPayment;
  bool _isPaymentConfirmed = false;
  Timer? _paymentStatusTimer;
  bool _isCartClearing = false;
  bool _isOrderCreating = false;
  
  StateSetter? _dialogSetState;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCartItems();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _paymentStatusTimer?.cancel();
    super.dispose();
  }

  String _generatePaymentQRData(String paymentId) {
    return paymentId;
  }

  void _startPaymentStatusCheck(String paymentId) {
    debugPrint('🔄 Starting payment status check for: $paymentId');
    
    _paymentStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        debugPrint('⚠️ Widget unmounted, canceling timer');
        timer.cancel();
        return;
      }

      try {
        debugPrint('🔍 Checking payment status for: $paymentId');
        
        final paymentProvider = context.read<PaymentProvider>();
        final payment = await paymentProvider.getPaymentById(paymentId);
        
        if (payment == null) {
          debugPrint('⚠️ Payment not found: $paymentId');
          return;
        }

        debugPrint('📊 Payment status: ${payment.status} (confirmed: ${payment.isConfirmed})');
        
        if (payment.isConfirmed && payment.status == true) {
          debugPrint('✅ Payment confirmed! Creating order...');
          timer.cancel();
          
          if (mounted) {
            await _handlePaymentConfirmation(payment);
          }
        }
      } catch (e) {
        debugPrint('❌ Error checking payment status: $e');
      }
    });
  }

  Future<void> _handlePaymentConfirmation(PaymentModel payment) async {
    try {
      setState(() {
        _isOrderCreating = true;
      });
      
      if (_dialogSetState != null) {
        _dialogSetState!(() {
          _isOrderCreating = true;
        });
      }

      debugPrint('🔄 Handling payment confirmation for: ${payment.id}');
      debugPrint('👤 User ID: ${payment.userId}');
      debugPrint('💰 Total Price: ${payment.totalPrice}');
      debugPrint('📦 Total Items: ${payment.totalItems}');
      debugPrint('🛍️ Items: ${payment.items.length}');

      // Validate payment data
      if (payment.userId.isEmpty) {
        throw Exception('Payment missing user ID');
      }
      if (payment.items.isEmpty) {
        throw Exception('Payment has no items');
      }

      // Prepare order items data
      final orderItems = {
        'items': payment.items.map((item) {
          final itemJson = item.toJson();
          debugPrint('📝 Item data: $itemJson');
          return itemJson;
        }).toList(),
        'total_price': payment.totalPrice,
        'total_items': payment.totalItems,
      };

      debugPrint('📋 Order items prepared: $orderItems');

      // Create order
      final orderProvider = context.read<OrderProvider>();
      final order = await orderProvider.createOrder(
        usersId: payment.userId,
        paymentId: payment.id,
        items: orderItems,
      );

      if (order != null) {
        debugPrint('✅ Order created successfully: ${order.id}');
        
        // Clear cart from database
        await _clearCartFromDatabase(payment.userId);
        
        setState(() {
          _isPaymentConfirmed = true;
          _currentPayment = payment;
          _isOrderCreating = false;
        });
      
        if (_dialogSetState != null) {
          _dialogSetState!(() {
            _isPaymentConfirmed = true;
            _currentPayment = payment;
            _isOrderCreating = false;
          });
        }
      
        _showPaymentConfirmedAnimation();
      } else {
        throw Exception('Failed to create order - orderProvider returned null');
      }

    } catch (e) {
      debugPrint('❌ Error handling payment confirmation: $e');
      
      setState(() {
        _isOrderCreating = false;
      });
      
      if (_dialogSetState != null) {
        _dialogSetState!(() {
          _isOrderCreating = false;
        });
      }
      
      if (mounted) {
        _showErrorSnackBar('Failed to create order: ${e.toString()}');
      }
    }
  }

  Future<void> _clearCartFromDatabase(String userId) async {
    try {
      setState(() {
        _isCartClearing = true;
      });
    
      if (_dialogSetState != null) {
        _dialogSetState!(() {
          _isCartClearing = true;
        });
      }

      final cartProvider = context.read<CartProvider>();
      
      debugPrint('🧹 Clearing cart from database for user: $userId');
      
      await cartProvider.clearCartForPayment(userId);
      
      debugPrint('✅ Cart cleared successfully from database');
      
    } catch (e) {
      debugPrint('❌ Error clearing cart from database: $e');
      if (mounted) {
        _showErrorSnackBar('Cart cleared locally but may need manual cleanup in database');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCartClearing = false;
        });
      
        if (_dialogSetState != null) {
          _dialogSetState!(() {
            _isCartClearing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildEnhancedHeader(),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (cartProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading cart',
                            style: GoogleFonts.oswald(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cartProvider.error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.charcoalGray,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => cartProvider.loadCartItems(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return cartProvider.cartItems.isEmpty 
                      ? _buildEmptyCart() 
                      : _buildCartContent();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return cartProvider.cartItems.isNotEmpty && !cartProvider.isLoading
              ? _buildEnhancedBottomBar()
              : const SizedBox.shrink();
        },
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
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Cart',
                      style: GoogleFonts.oswald(
                        color: AppTheme.lightCream,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        if (cartProvider.cartItems.isNotEmpty) {
                          return Text(
                            '${cartProvider.totalItems} items • Rp ${cartProvider.totalCartValue}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.warmBeige,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.cartItems.isNotEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _showClearCartDialog,
                        icon: const Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepNavy.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'Your cart is empty',
                    style: GoogleFonts.oswald(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Discover our amazing coffee collection\nand add your favorites to get started!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.charcoalGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepNavy.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_cafe_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Start Shopping',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
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
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartProvider.cartItems[index];
              return _buildEnhancedCartItem(item, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCartItem(item, int index) {
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.neutralGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepNavy.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: item.productImage != null && item.productImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              item.productImageUrl ?? 'url_default_placeholder',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.coffee_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.coffee_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? 'Unknown Product',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        if (item.temperature.isNotEmpty && item.temperature != '-')
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildInfoChip(item.temperature, Icons.thermostat_rounded),
                              if (item.sweetness.isNotEmpty && item.sweetness != '-')
                                _buildInfoChip(item.sweetness, Icons.favorite_rounded),
                            ],
                          ),
                        
                        const SizedBox(height: 8),
                        
                        if (item.specialNotes.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.softWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.note_rounded,
                                  size: 14,
                                  color: AppTheme.charcoalGray,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.specialNotes,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.charcoalGray,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Rp ${item.productPrice ?? 0}',
                          style: GoogleFonts.oswald(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.lightGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          Icons.remove_rounded,
                          () {
                            context.read<CartProvider>().updateCartItemQuantity(
                              item.id, 
                              item.quantity - 1
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add_rounded,
                          () {
                            context.read<CartProvider>().updateCartItemQuantity(
                              item.id, 
                              item.quantity + 1
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                          Text(
                            'Rp ${item.totalPrice}',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _removeItem(item.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${cartProvider.totalItems})',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                          Text(
                            'Rp ${cartProvider.totalCartValue}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.warmBeige.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                          Text(
                            'Rp ${cartProvider.totalCartValue}',
                            style: GoogleFonts.oswald(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepNavy.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: cartProvider.isLoading ? null : _showPayAtCashierDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: cartProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pay at Cashier',
                                style: GoogleFonts.oswald(
                                  fontSize: 18,
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
            );
          },
        ),
      ),
    );
  }

  void _removeItem(String cartId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Remove Item',
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Are you sure you want to remove this item from your cart?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.charcoalGray),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: AppTheme.charcoalGray,
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
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<CartProvider>().removeFromCart(cartId);
                          _showSuccessSnackBar('Item removed from cart');
                        },
                        child: Text(
                          'Remove',
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

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppTheme.lightGradient,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Clear Cart',
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Are you sure you want to remove all items from your cart?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.deepNavy, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
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
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<CartProvider>().clearCart();
                          _showSuccessSnackBar('Cart cleared successfully');
                        },
                        child: Text(
                          'Clear All',
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

  void _showPayAtCashierDialog() async {
    if (kDebugMode) {
      await PocketBaseDebug.debugPocketBase();
    }

    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    
    final paymentService = PaymentService();
    final connectionTest = await paymentService.testConnection();
    
    if (!connectionTest) {
      _showErrorSnackBar('Cannot connect to server. Please check if PocketBase is running on http://127.0.0.1:8090');
      return;
    }
    
    if (kDebugMode) {
      await paymentService.listCollections();
    }
    
    debugPrint('🔄 Creating payment from cart items');
    debugPrint('📦 Cart items count: ${cartProvider.cartItems.length}');
    
    if (cartProvider.cartItems.isEmpty) {
      _showErrorSnackBar('Cart is empty');
      return;
    }
    
    final userIds = cartProvider.cartItems.map((item) => item.usersId).toSet();
    debugPrint('👥 User IDs in cart: $userIds');
    
    if (userIds.isEmpty || userIds.contains('') || userIds.contains(null)) {
      _showErrorSnackBar('Cart items are missing user information. Please refresh and try again.');
      return;
    }
    
    if (userIds.length > 1) {
      _showErrorSnackBar('Cart contains items from multiple users. Please contact support.');
      return;
    }
    
    // Create payment but don't create order yet - order will be created when payment is confirmed
    debugPrint('💳 Creating payment...');
    final payment = await paymentProvider.createPaymentFromCart(
      cartItems: cartProvider.cartItems,
    );
    
    if (payment == null) {
      final error = paymentProvider.error ?? 'Failed to create payment. Please check the console for details.';
      _showErrorSnackBar(error);
      return;
    }
    
    debugPrint('✅ Payment created: ${payment.id}');
    debugPrint('👤 Payment user ID: ${payment.userId}');
    debugPrint('💰 Payment total: ${payment.totalPrice}');
    debugPrint('📦 Payment items: ${payment.items.length}');
    
    setState(() {
      _currentPayment = payment;
      _isPaymentConfirmed = false;
    });
    
    _startPaymentStatusCheck(payment.id);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          _dialogSetState = setDialogState;
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: AppTheme.lightGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: _isPaymentConfirmed 
                          ? const LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                            )
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: (_isPaymentConfirmed ? Colors.green : AppTheme.deepNavy)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: (_isCartClearing || _isOrderCreating)
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            _isPaymentConfirmed ? Icons.check_circle_rounded : Icons.qr_code_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ShaderMask(
                    shaderCallback: (bounds) => (_isPaymentConfirmed 
                        ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                        : AppTheme.primaryGradient).createShader(bounds),
                    child: Text(
                      _isOrderCreating 
                          ? 'Creating Order...'
                          : _isCartClearing 
                              ? 'Clearing Cart...'
                              : _isPaymentConfirmed 
                                  ? 'Order Created!' 
                                  : 'Payment QR Code',
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Order #GRBK${payment.id.substring(0, 4).toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (!_isPaymentConfirmed) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.deepNavy.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _generatePaymentQRData(payment.id),
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.deepNavy,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppTheme.deepNavy,
                        ),
                        gapless: false,
                        errorStateBuilder: (cxt, err) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppTheme.softWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: AppTheme.charcoalGray,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'QR Code Error',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.charcoalGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Order Created!',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Successfully saved to database',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: _isPaymentConfirmed 
                                    ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                                    : AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _isPaymentConfirmed 
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPaymentConfirmed ? 'Order Status' : 'Payment Instructions',
                              style: GoogleFonts.oswald(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isPaymentConfirmed 
                              ? 'Payment confirmed by cashier.\nOrder has been created and saved to database.\nCart has been cleared.\nYou can now continue shopping.'
                              : '1. Show this QR code to the cashier\n2. Complete payment at the counter\n3. Wait for cashier confirmation\n4. Order will be automatically created',
                          style: GoogleFonts.poppins(
                            color: AppTheme.charcoalGray,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepNavy.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Items',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                            Text(
                              '${payment.totalItems} items',
                              style: GoogleFonts.oswald(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                            Text(
                              'Rp ${payment.totalPrice}',
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _isPaymentConfirmed 
                          ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                          : LinearGradient(
                              colors: [
                                AppTheme.charcoalGray.withValues(alpha: 0.5),
                                AppTheme.charcoalGray.withValues(alpha: 0.3),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isPaymentConfirmed ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ] : [],
                    ),
                    child: ElevatedButton(
                      onPressed: (_isPaymentConfirmed && !_isCartClearing && !_isOrderCreating) ? () {
                        _paymentStatusTimer?.cancel();
                        Navigator.of(context).pop();
                        
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCartClearing || _isOrderCreating) ...[
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              _isPaymentConfirmed 
                                  ? Icons.receipt_long_rounded 
                                  : Icons.hourglass_empty_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                          const SizedBox(width: 12),
                          Text(
                            _isOrderCreating 
                                ? 'Creating Order...'
                                : _isCartClearing 
                                    ? 'Clearing Cart...'
                                    : _isPaymentConfirmed 
                                        ? 'Continue' 
                                        : 'Waiting for Confirmation...',
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
        },
      ),
    ).then((_) {
      _paymentStatusTimer?.cancel();
      _dialogSetState = null;
    });
  }

  void _showPaymentConfirmedAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Payment confirmed! Order created and saved to database.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 4),
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
        backgroundColor: AppTheme.deepNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
