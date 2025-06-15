import 'package:flutter/material.dart';
// import 'user_screens/auth/splash_screen.dart';
import 'admin_screens/dashboard/admin_dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRBK Coffee Shop',
      theme: AppTheme.lightTheme,
      home: const AdminDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}