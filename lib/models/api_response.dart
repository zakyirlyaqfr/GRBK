class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse.success(this.data, {this.statusCode}) : success = true, message = null, errors = null;
  ApiResponse.error(this.message, {this.statusCode, this.errors}) : success = false, data = null;
  
  @override
  String toString() {
    if (success) {
      return 'ApiResponse(success: $success, data: $data, statusCode: $statusCode)';
    } else {
      return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, errors: $errors)';
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  static ApiException unknown(String message) => ApiException(message);
  
  @override
  String toString() => 'ApiException: $message';
}
