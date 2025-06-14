import 'package:flutter/foundation.dart';

class AppConfig {
  // PocketBase Configuration
  static const String pocketBaseUrl = 'http://127.0.0.1:8090';
  static const String productsCollection = 'products';
  static const String usersCollection = 'users';

  // API Endpoints
  static String get apiUrl => '$pocketBaseUrl/api';
  static String get collectionsUrl => '$apiUrl/collections';
  static String get productsUrl =>
      '$collectionsUrl/$productsCollection/records';
  static String get usersUrl => '$collectionsUrl/$usersCollection/records';

  // App Configuration
  static const String appName = 'BakeMate';
  static const String appVersion = '1.0.0';

  // Cache Configuration
  static const Duration cacheExpiration = Duration(minutes: 30);
  static const String cacheKeyProducts = 'cached_products';
  static const String cacheKeyLastUpdate = 'last_update';

  // Image Configuration
  static String getImageUrl(
      String collectionId, String recordId, String filename) {
    return '$pocketBaseUrl/api/files/$collectionId/$recordId/$filename';
  }

  // In your app_config.dart file, add this constant:
  static const String fileUrl = '$pocketBaseUrl/api/files/products/';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Development/Production flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;

  // Debug helper
  static void logDebug(String message) {
    if (enableLogging) {
      debugPrint('🔍 DEBUG: $message');
    }
  }

  static void logError(String message, [dynamic error]) {
    if (enableLogging) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Exception details: $error');
      }
    }
  }
}
