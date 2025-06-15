import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette from the provided image
  static const Color lightCream = Color(0xFFF1EFEC);      // Top band - light cream
  static const Color warmBeige = Color(0xFFD4C9BE);       // Second band - warm beige
  static const Color deepNavy = Color(0xFF123458);        // Third band - deep navy blue
  static const Color richBlack = Color(0xFF030303);       // Bottom band - rich black
  
  // Additional complementary colors for UI elements
  static const Color softWhite = Color(0xFFFAF9F7);       // Even lighter than cream
  static const Color mediumBeige = Color(0xFFC4B5A0);     // Darker beige variant
  static const Color navyAccent = Color(0xFF1E4A72);      // Lighter navy for accents
  static const Color charcoalGray = Color(0xFF2C2C2C);    // Softer than black
  
  // Status and accent colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Gradient combinations using the palette
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, navyAccent],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyAccent, deepNavy],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softWhite, lightCream],
  );
  
  static const LinearGradient neutralGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightCream, warmBeige],
  );
  
  static ThemeData lightTheme = ThemeData(
    primarySwatch: _createMaterialColor(deepNavy),
    scaffoldBackgroundColor: softWhite,
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    // AppBar Theme with navy gradient
    appBarTheme: AppBarTheme(
      backgroundColor: deepNavy,
      foregroundColor: lightCream,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightCream,
      ),
      iconTheme: const IconThemeData(color: lightCream),
    ),
    
    // Bottom Navigation with navy theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: deepNavy,
      selectedItemColor: lightCream,
      unselectedItemColor: warmBeige,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
    
    // Enhanced Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepNavy,
        foregroundColor: lightCream,
        elevation: 6,
        shadowColor: deepNavy.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Enhanced Card Theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 8,
      shadowColor: deepNavy.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    
    // Enhanced Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: warmBeige, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: warmBeige, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: deepNavy, width: 3),
      ),
      labelStyle: GoogleFonts.poppins(
        color: charcoalGray,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(
        color: charcoalGray.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    ),
    
    // Enhanced Text Theme
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: deepNavy,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: deepNavy,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: richBlack,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: charcoalGray,
      ),
    ),
    
    // Enhanced Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: deepNavy,
      foregroundColor: lightCream,
      elevation: 12,
    ),
    
    // Additional theme configurations
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: deepNavy,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: deepNavy,
        side: const BorderSide(color: deepNavy, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: lightCream,
      selectedColor: deepNavy,
      labelStyle: GoogleFonts.poppins(
        color: charcoalGray,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
  
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}