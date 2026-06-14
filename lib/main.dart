import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'user_screens/auth/splash_screen.dart';
import 'utils/app_theme.dart';

// 1. TAMBAHKAN IMPORT INI
// Sesuaikan nama file dan foldernya jika berbeda di proyek Anda
import 'user_screens/auth/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'GRBK Coffee Shop',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        
        // 2. TAMBAHKAN PROPERTI ROUTES INI
        routes: {
          // Daftarkan rute login di sini. 
          // Pastikan 'LoginScreen' sesuai dengan nama class di file login Anda
          '/login': (context) => const LoginScreen(), 
        },
      ),
    );
  }
}