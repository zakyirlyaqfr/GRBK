import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/user_model.dart';

class PocketBaseService {
  static const String baseUrl = 'http://127.0.0.1:8090';
  static const String apiUrl = '$baseUrl/api';
  
  String? _authToken;
  UserModel? _currentUser;

  // Singleton pattern
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  // Getters
  String? get authToken => _authToken;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  // Initialize service and create admin if not exists
  Future<void> initialize() async {
    await _loadAuthData();
    await _ensureAdminExists();
  }

  // Ensure admin user exists
  Future<void> _ensureAdminExists() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/collections/users/records?filter=(email="admin@gmail.com")'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        if (items.isEmpty) {
          await _createAdminUser();
        }
      }
    } catch (e) {
      print('Error checking admin existence: $e');
    }
  }

  // Create admin user
  Future<bool> _createAdminUser() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/collections/users/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Admin GRBK',
          'email': 'admin@gmail.com',
          'password': 'admin123',
          'passwordConfirm': 'admin123',
          'admin': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Admin user created successfully');
        return true;
      } else {
        print('Failed to create admin user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating admin user: $e');
      return false;
    }
  }

  // Load auth data from SharedPreferences
  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');
    
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error loading user data: $e');
        await _clearAuthData();
      }
    }
  }

  // Save auth data to SharedPreferences
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_authToken != null) {
      await prefs.setString('auth_token', _authToken!);
    }
    if (_currentUser != null) {
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    }
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    _authToken = null;
    _currentUser = null;
  }

  // Login with role-based routing
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/collections/users/auth-with-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        
        final userData = data['record'];
        _currentUser = UserModel.fromJson(userData);
        
        await _saveAuthData();
        
        return {
          'success': true,
          'user': _currentUser,
          'message': 'Login successful'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/collections/users/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'admin': false,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registration successful'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Update user profile with avatar support
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    File? avatarFile,
    String? webAvatarData,
  }) async {
    if (_currentUser == null || _authToken == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$apiUrl/collections/users/records/${_currentUser!.id}'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $_authToken';

      // Add text fields if provided
      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;

      // Handle avatar upload
      if (avatarFile != null && !kIsWeb) {
        // Mobile/Desktop platform
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
        debugPrint('Mobile avatar file added: ${avatarFile.path}');
      } else if (webAvatarData != null && webAvatarData.isNotEmpty && kIsWeb) {
        // Web platform
        try {
          final RegExp regex = RegExp(r'data:image/([^;]+);base64,');
          final match = regex.firstMatch(webAvatarData);
          
          if (match != null) {
            final String imageType = match.group(1) ?? 'png';
            final String base64Str = webAvatarData.replaceAll(regex, '');
            final bytes = base64Decode(base64Str);
            
            final multipartFile = http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.$imageType',
              contentType: MediaType('image', imageType),
            );
            request.files.add(multipartFile);
            debugPrint('Web avatar added successfully - Size: ${bytes.length} bytes');
          }
        } catch (e) {
          debugPrint('Error processing web avatar: $e');
        }
      }

      debugPrint('Updating profile for user: ${_currentUser!.id}');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update profile response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data);
        await _saveAuthData();
        
        return {
          'success': true,
          'user': _currentUser,
          'message': 'Profile updated successfully'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Update failed'
        };
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get all users (excluding admin for user list)
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/collections/users/records?filter=(admin=false)&sort=-created'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => UserModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/collections/users/records?filter=(admin=false)'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final totalItems = data['totalItems'] ?? 0;
        return {
          'total': totalItems,
          'active': totalItems,
        };
      }
      return {'total': 0, 'active': 0};
    } catch (e) {
      print('Error fetching user stats: $e');
      return {'total': 0, 'active': 0};
    }
  }

  // Update admin profile
  Future<Map<String, dynamic>> updateAdminProfile(String name, String email) async {
    if (_currentUser == null || _authToken == null || !_currentUser!.admin) {
      return {'success': false, 'message': 'Not authenticated as admin'};
    }

    try {
      print('Updating admin profile: name=$name, email=$email');
      
      final response = await http.patch(
        Uri.parse('$apiUrl/collections/users/records/${_currentUser!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data);
        await _saveAuthData();
        
        return {
          'success': true,
          'user': _currentUser,
          'message': 'Admin profile updated successfully'
        };
      } else {
        final error = jsonDecode(response.body);
        print('Update error: $error');
        return {
          'success': false,
          'message': error['message'] ?? 'Update failed'
        };
      }
    } catch (e) {
      print('Update exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null || _authToken == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/collections/users/records/${_currentUser!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'oldPassword': currentPassword,
          'password': newPassword,
          'passwordConfirm': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully'
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Password change failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearAuthData();
  }

  // Check if current user is admin
  bool get isAdmin => _currentUser?.admin == true;
  
  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('Auth token set: ${token.substring(0, 10)}...');
  }
  
  void clearAuthToken() {
    _authToken = null;
    debugPrint('Auth token cleared');
  }
  
  // Test if PocketBase is running
  static Future<bool> isServerRunning() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('PocketBase server check: $baseUrl');
      return true;
    } catch (e) {
      debugPrint('PocketBase server not running: $e');
      return false;
    }
  }

  // Add this field to expose the PocketBase SDK client
  final PocketBase pb = PocketBase(baseUrl);
}

extension PocketBaseTestUser on PocketBaseService {
  Future<String?> getOrCreateTestUser() async {
    const testEmail = 'testuser@grbk.com';
    const testPassword = 'test1234';
    const testName = 'Test User';

    final findResponse = await http.get(
      Uri.parse('${PocketBaseService.apiUrl}/collections/users/records?filter=(email="$testEmail")'),
      headers: {'Content-Type': 'application/json'},
    );

    if (findResponse.statusCode == 200) {
      final data = jsonDecode(findResponse.body);
      final items = data['items'] as List<dynamic>? ?? [];
      if (items.isNotEmpty) {
        return items.first['id'] as String;
      }
    }

    final createResponse = await http.post(
      Uri.parse('${PocketBaseService.apiUrl}/collections/users/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': testName,
        'email': testEmail,
        'password': testPassword,
        'passwordConfirm': testPassword,
        'admin': false,
      }),
    );

    if (createResponse.statusCode == 200) {
      final data = jsonDecode(createResponse.body);
      return data['id'] as String;
    }

    return null;
  }
}
