import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../cart/cart_screen.dart';
import '../../utils/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  String _selectedTemperature = 'Hot';
  String _selectedSweetness = 'Normal';
  final TextEditingController _specialNotesController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _temperatures = ['Hot', 'Iced'];
  final List<String> _sweetness = ['Less Sweet', 'Normal', 'Extra Sweet'];

  bool get _isAvailable => widget.product.stock;

  int get _totalPrice {
    int basePrice = widget.product.price;
    return basePrice * _quantity;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _specialNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.richBlack.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppTheme.deepNavy,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.richBlack.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                    // Cart badge
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        if (cartProvider.totalItems > 0) {
                          return Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartProvider.totalItems}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContentSection(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildEnhancedBottomBar(),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Hero(
              tag: widget.product.name,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.richBlack.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: widget.product.image != null &&
                            widget.product.image!.isNotEmpty
                        ? Image.network(
                            context
                                .read<ProductProvider>()
                                .getImageUrl(widget.product),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.coffee_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.coffee_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (!_isAvailable)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'NOT AVAILABLE',
                                style: GoogleFonts.oswald(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildContentSection() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            const SizedBox(height: 20),
            _buildDescriptionSection(),
            const SizedBox(height: 16), // Reduced from 20
            _buildTemperatureSection(),
            const SizedBox(height: 18),
            _buildSweetnessSection(),
            const SizedBox(height: 18),
            _buildSpecialNotesSection(),
            const SizedBox(height: 16), // Reduced from 20
            _buildQuantitySection(),
            const SizedBox(height: 24), // Reduced from 80
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${widget.product.price}',
                style: GoogleFonts.oswald(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: _isAvailable
                ? AppTheme.accentGradient
                : LinearGradient(
                    colors: [
                      AppTheme.charcoalGray.withValues(alpha: 0.6),
                      AppTheme.charcoalGray.withValues(alpha: 0.4),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isAvailable
                ? [
                    BoxShadow(
                      color: AppTheme.deepNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.product.category,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.oswald(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isAvailable ? Colors.white : AppTheme.softWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isAvailable
                ? [
                    BoxShadow(
                      color: AppTheme.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.product.description,
            style: GoogleFonts.poppins(
              color: _isAvailable
                  ? AppTheme.charcoalGray
                  : AppTheme.charcoalGray.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return _buildSelectionSection(
      'Temperature',
      Icons.thermostat_rounded,
      _temperatures,
      _selectedTemperature,
      (value) =>
          _isAvailable ? setState(() => _selectedTemperature = value) : null,
    );
  }

  Widget _buildSweetnessSection() {
    return _buildSelectionSection(
      'Sweetness Level',
      Icons.favorite_rounded,
      _sweetness,
      _selectedSweetness,
      (value) =>
          _isAvailable ? setState(() => _selectedSweetness = value) : null,
    );
  }

  Widget _buildSelectionSection(
    String title,
    IconData icon,
    List<String> options,
    String selected,
    Function(String)? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: _isAvailable
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.charcoalGray.withValues(alpha: 0.5),
                          AppTheme.charcoalGray.withValues(alpha: 0.3),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: onChanged != null ? () => onChanged(option) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected && _isAvailable
                      ? AppTheme.primaryGradient
                      : null,
                  color: isSelected && _isAvailable
                      ? null
                      : (_isAvailable ? Colors.white : AppTheme.softWhite),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected && _isAvailable
                        ? Colors.transparent
                        : (_isAvailable
                            ? AppTheme.warmBeige
                            : AppTheme.charcoalGray.withValues(alpha: 0.3)),
                    width: 2,
                  ),
                  boxShadow: isSelected && _isAvailable
                      ? [
                          BoxShadow(
                            color: AppTheme.deepNavy.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    color: isSelected && _isAvailable
                        ? Colors.white
                        : (_isAvailable
                            ? AppTheme.deepNavy
                            : AppTheme.charcoalGray.withValues(alpha: 0.7)),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpecialNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: _isAvailable
                    ? AppTheme.accentGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.charcoalGray.withValues(alpha: 0.5),
                          AppTheme.charcoalGray.withValues(alpha: 0.3),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Special Notes',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _isAvailable ? Colors.white : AppTheme.softWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isAvailable
                ? [
                    BoxShadow(
                      color: AppTheme.deepNavy.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: _specialNotesController,
            enabled: _isAvailable,
            maxLines: 3,
            style: GoogleFonts.poppins(
              color: _isAvailable
                  ? AppTheme.deepNavy
                  : AppTheme.charcoalGray.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: _isAvailable
                  ? 'Add any special instructions for your order...'
                  : 'Product not available for customization',
              hintStyle: GoogleFonts.poppins(
                color: _isAvailable
                    ? AppTheme.charcoalGray.withValues(alpha: 0.7)
                    : AppTheme.charcoalGray.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _isAvailable ? Colors.white : AppTheme.softWhite,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _isAvailable
            ? AppTheme.lightGradient
            : LinearGradient(
                colors: [
                  AppTheme.softWhite,
                  AppTheme.softWhite.withValues(alpha: 0.7),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: _isAvailable
            ? [
                BoxShadow(
                  color: AppTheme.deepNavy.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuantityButton(
                    Icons.remove_rounded,
                    _isAvailable && _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isAvailable ? Colors.white : AppTheme.softWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isAvailable
                            ? AppTheme.deepNavy
                            : AppTheme.charcoalGray,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add_rounded,
                    _isAvailable ? () => setState(() => _quantity++) : null,
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _isAvailable
                      ? AppTheme.charcoalGray
                      : AppTheme.charcoalGray.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp $_totalPrice',
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      _isAvailable ? AppTheme.deepNavy : AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    AppTheme.charcoalGray.withValues(alpha: 0.3),
                    AppTheme.charcoalGray.withValues(alpha: 0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppTheme.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
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
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: _isAvailable
                      ? AppTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            AppTheme.charcoalGray.withValues(alpha: 0.6),
                            AppTheme.charcoalGray.withValues(alpha: 0.4),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isAvailable
                      ? [
                          BoxShadow(
                            color: AppTheme.deepNavy.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return ElevatedButton(
                      onPressed: _isAvailable && !cartProvider.isLoading 
                          ? _addToCart 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                                Icon(
                                  _isAvailable
                                      ? Icons.shopping_cart_rounded
                                      : Icons.block_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isAvailable ? 'Add to Cart' : 'Not Available',
                                  style: GoogleFonts.oswald(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() async {
    if (!_isAvailable) return;

    final cartProvider = context.read<CartProvider>();
  
    try {
      await cartProvider.addToCart(
        productId: widget.product.id,
        quantity: _quantity,
        temperature: _selectedTemperature,
        sweetness: _selectedSweetness,
        specialNotes: _specialNotesController.text.trim(),
      );

      if (mounted) {
        if (cartProvider.error != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error: ${cartProvider.error}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else {
          // Show success notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Item added to cart',
                          style: GoogleFonts.oswald(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.product.name} (${_quantity}x)',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to add item to cart',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
