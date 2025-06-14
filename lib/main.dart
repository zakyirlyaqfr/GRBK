import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart' as cart_screen;
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'providers/cart_provider.dart';
import 'services/pocketbase_service.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize PocketBase service
  try {
    final pocketBaseService = PocketBaseService();
    await pocketBaseService.initialize();

    if (AppConfig.isDevelopment) {
      final isConnected = await pocketBaseService.testConnection();
      debugPrint('PocketBase connection: ${isConnected ? 'Connected' : 'Failed - Using dummy data'}');
    }
  } catch (e) {
    debugPrint('PocketBase initialization failed: $e - Using dummy data');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CartProvider(
      child: MaterialApp(
        title: 'BakeMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/product-detail': (context) => const ProductDetailScreen(),
          '/cart': (context) => const cart_screen.CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-history': (context) => const OrderHistoryScreen(),
        },
      ),
    );
  }
}
