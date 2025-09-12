import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _userRoleKey = 'user_role';
  static const String _rememberMeKey = 'remember_me';
  
  // Base URL for API - replace with your actual API endpoint
  static const String baseUrl = 'https://your-api-endpoint.com';

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    final rememberMe = await _storage.read(key: _rememberMeKey);
    
    if (token != null && rememberMe == 'true') {
      // Optionally validate token with server
      return await _validateToken(token);
    }
    
    return token != null;
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userRole = data['user']['role'];

        // Store token and user info securely
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userRoleKey, value: userRole);
        await _storage.write(key: _rememberMeKey, value: rememberMe.toString());

        return {
          'success': true,
          'token': token,
          'role': userRole,
          'user': data['user'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  /// Get stored JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  /// Logout user
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _rememberMeKey);
  }

  /// Validate token with server
  static Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get authorization headers for API calls
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}