import 'package:flutter/foundation.dart';

class DebugService {
  static void logPaymentToOrderFlow({
    required String step,
    required Map<String, dynamic> data,
  }) {
    if (kDebugMode) {
      debugPrint('🔄 PAYMENT-TO-ORDER FLOW - $step');
      debugPrint('📊 Data: $data');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('─' * 50);
    }
  }

  static void logError({
    required String context,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      debugPrint('❌ ERROR in $context');
      debugPrint('🚨 Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
      debugPrint('─' * 50);
    }
  }

  static void logSuccess({
    required String operation,
    required Map<String, dynamic> result,
  }) {
    if (kDebugMode) {
      debugPrint('✅ SUCCESS - $operation');
      debugPrint('🎉 Result: $result');
      debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('─' * 50);
    }
  }
}
