import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Remove Provider import since you're using InheritedWidget
import '../models/product.dart';
import '../widgets/modern_product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../services/pocketbase_service.dart';

// Added StatefulWidget class
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Renamed to _HomeScreenState
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // State variables
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Bread',
    'Pastry',
    'Sweets',
    'Cakes'
  ];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _badgeAnimationController;
  late Animation<double> _badgeAnimation;

  // PocketBase service
  final PocketBaseService _pocketBaseService = PocketBaseService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProducts();
  }

  /// Initialize all animations
  void _initializeAnimations() {
    // Header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutQuint,
    );
    _headerAnimationController.forward();

    // FAB pulse animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Cart badge animation
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _badgeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeAnimationController,
        curve: Curves.bounceOut,
      ),
    );
  }

  /// Load products from PocketBase
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _pocketBaseService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
      _debugProductData(); // Add this line to call the debug method
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  /// Refresh products
  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _badgeAnimationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = CartProvider.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.surfaceColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(cartNotifier),
              _buildCategoryChips(),
              if (_isLoading) _buildLoadingIndicator(),
              if (_errorMessage != null) _buildErrorState(),
              if (!_isLoading &&
                  _errorMessage == null &&
                  _selectedCategory == 'All')
                _buildPopularSection(screenWidth),
              if (!_isLoading && _errorMessage == null)
                _buildAllProductsSection(),
              // Removed the separate _buildProductsGrid since it's now integrated in _buildAllProductsSection
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build custom app bar
  SliverToBoxAdapter _buildAppBar(CartNotifier cartNotifier) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - _headerAnimation.value)),
            child: Opacity(
              opacity: _headerAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBarHeader(cartNotifier),
                    const SizedBox(height: 32),
                    const SearchBarWidget(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build app bar header with title and actions
  Widget _buildAppBarHeader(CartNotifier cartNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'BakeMate',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 36,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            _buildCartButton(cartNotifier),
            const SizedBox(width: 16),
            _buildProfileMenu(),
          ],
        ),
      ],
    );
  }

  /// Build cart button with badge
  Widget _buildCartButton(CartNotifier cartNotifier) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Material(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.12),
          child: IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            color: AppTheme.primaryColor,
            iconSize: 30,
          ),
        ),
        if (cartNotifier.itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _badgeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _badgeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 26, minHeight: 26),
                    child: Text(
                      '${cartNotifier.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Build profile menu
  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      icon: Material(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.12),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.person_outline,
              color: AppTheme.primaryColor, size: 30),
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          final authProvider = AuthProvider();
          await authProvider.logout();
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: AppTheme.errorColor),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontFamily: 'Lora',
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build category chips
  SliverToBoxAdapter _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: SizedBox(
          height: 45, // Fixed height for the row
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: _categories
                .map((category) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Build loading indicator
  SliverToBoxAdapter _buildLoadingIndicator() {
    return const SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: SpinKitFadingCube(color: AppTheme.primaryColor, size: 50),
        ),
      ),
    );
  }

  /// Build error state
  SliverToBoxAdapter _buildErrorState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline,
                  size: 84, color: AppTheme.errorColor),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.errorColor,
                      fontFamily: 'Lora',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  'Retry',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: 'Lora',
                        fontSize: 16,
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

// In your HomeScreen class, update these methods:

  /// Build popular section
  SliverToBoxAdapter _buildPopularSection(double screenWidth) {
    return SliverToBoxAdapter(
      child: Padding(
        // Reduced horizontal padding from 24px to 12px
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // Keep the title with a bit more padding
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Popular Today',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Playfair Display',
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: screenWidth * 0.58,
              child: ListView.builder(
                // Reduced padding to 4px to allow cards to be closer to the edge
                padding: const EdgeInsets.symmetric(horizontal: 4),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _products.where((p) => p.isPopular).length,
                itemBuilder: (context, index) {
                  final popularProducts =
                      _products.where((p) => p.isPopular).toList();
                  if (popularProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No popular products available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Lora',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    );
                  }
                  return Container(
                    width: screenWidth * 0.45,
                    // Reduced right margin from 18px to 12px
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: popularProducts[index],
                      ),
                      child: ModernProductCard(
                        product: popularProducts[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: popularProducts[index],
                        ),
                      ),
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

  /// Build all products section with grid
  SliverToBoxAdapter _buildAllProductsSection() {
    final filteredProducts = _selectedCategory == 'All'
        ? _products
        : _products
            .where((product) => product.category == _selectedCategory)
            .toList();

    return SliverToBoxAdapter(
      child: Padding(
        // Reduced horizontal padding from 28px to 12px
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title with a bit more padding
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                _selectedCategory == 'All' ? 'All Products' : _selectedCategory,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Playfair Display',
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid layout
            filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 84,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No products available in the selected category',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'Helvetica',
                                      fontSize: 18,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      // Reduced spacing between columns from 24px to 12px
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: filteredProducts[index],
                      ),
                      child: ModernProductCard(
                        product: filteredProducts[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: filteredProducts[index],
                        ),
                      ),
                    ),
                  ),

            // Add bottom padding to avoid FAB overlap
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  colorBoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                  colorBoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/order-history'),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.history, size: 32),
              ),
            ),
          );
        });
  }

  // Added missing colorBoxShadow method
  BoxShadow colorBoxShadow({
    required Color color,
    double blurRadius = 10.0,
    double spreadRadius = 0.0,
    Offset offset = Offset.zero,
  }) {
    return BoxShadow(
      color: color,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: offset,
    );
  }

  // Add this after fetching products in your HomeScreen
  void _debugProductData() {
    if (_products.isNotEmpty) {
      final product = _products.first;
      debugPrint('=== PRODUCT DEBUG INFO ===');
      debugPrint('Product ID: ${product.id}');
      debugPrint('Product Name: ${product.name}');
      debugPrint('Image URL: ${product.imageUrl}');
    }
  }
}