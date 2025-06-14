import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late PocketBase pb;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Replace with your PocketBase URL
    pb = PocketBase('http://127.0.0.1:8090');
    
    // Load saved auth data
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');
    if (authData != null) {
      pb.authStore.save(authData, null);
    }
    
    _isInitialized = true;
  }

  bool get isLoggedIn => pb.authStore.isValid;
  
  RecordModel? get currentUser => pb.authStore.model;

  Future<RecordModel> login(String email, String password) async {
    try {
      final authData = await pb.collection('users').authWithPassword(email, password);
      
      // Save auth data to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_data', pb.authStore.token);
      
      return authData.record!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RecordModel> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    String? phone,
  }) async {
    try {
      final record = await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'name': name,
        'phone': phone ?? '',
        'emailVisibility': true,
      });

      // Send verification email
      await pb.collection('users').requestVerification(email);
      
      return record;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await pb.collection('users').requestPasswordReset(email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      
      await pb.collection('users').update(currentUser!.id, body: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is ClientException) {
      final response = error.response;
      if (response.containsKey('message')) {
        return response['message'];
      }
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map) {
          final firstError = data.values.first;
          if (firstError is Map && firstError.containsKey('message')) {
            return firstError['message'];
          }
        }
      }
    }
    return error.toString();
  }
}
