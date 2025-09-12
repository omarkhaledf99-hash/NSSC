import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/network_helper.dart';
import '../models/user.dart';
import '../models/checkpoint.dart';
import '../models/stopcard.dart';
import '../models/common.dart';

class ErrorMessages {
  static const String validationError = 'Invalid input data';
  static const String unauthorizedError = 'Authentication required';
  static const String forbiddenError = 'Access denied';
  static const String notFoundError = 'Resource not found';
  static const String serverError = 'Server error occurred';
  static const String networkError = 'Network connection failed';
  static const String unknownError = 'An unexpected error occurred';
  static const String timeoutError = 'Request timeout';
  static const String dataLoadFailed = 'Failed to load data';
  static const String submitFailed = 'Failed to submit data';
}

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _tokenKey = ApiConstants.tokenKey;
  static const int _timeoutSeconds = ApiConstants.timeoutSeconds;
  static const int _maxRetries = ApiConstants.maxRetries;
  
  final http.Client _client = http.Client();
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // JWT Token Management
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
  
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }
  
  Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error clearing token: $e');
      return false;
    }
  }
  
  // HTTP Headers
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Network connectivity check
  Future<bool> _isNetworkAvailable() async {
    return await NetworkHelper.isConnected();
  }
  
  // Generic HTTP request with retry logic
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    if (!await _isNetworkAvailable()) {
      return ApiResponse.error(ErrorMessages.networkError);
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client.get(url, headers: headers)
                .timeout(const Duration(seconds: _timeoutSeconds));
            break;
          case 'POST':
            response = await _client.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(const Duration(seconds: _timeoutSeconds));
            break;
          case 'PUT':
            response = await _client.put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(const Duration(seconds: _timeoutSeconds));
            break;
          case 'DELETE':
            response = await _client.delete(url, headers: headers)
                .timeout(const Duration(seconds: _timeoutSeconds));
            break;
          default:
            return ApiResponse.error('Unsupported HTTP method: $method');
        }
        
        return _handleResponse<T>(response, fromJson);
        
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          String errorMessage = ErrorMessages.unknownError;
          if (e.toString().contains('TimeoutException')) {
            errorMessage = ErrorMessages.timeoutError;
          } else if (e.toString().contains('SocketException')) {
            errorMessage = ErrorMessages.networkError;
          }
          return ApiResponse.error('$errorMessage: $e');
        }
        
        // Exponential backoff
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
    
    return ApiResponse.error('${ErrorMessages.unknownError} ($_maxRetries attempts)');
  }
  
  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;
      
      if (statusCode >= 200 && statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse.success(null);
        }
        
        final jsonData = jsonDecode(response.body);
        
        if (fromJson != null && jsonData is Map<String, dynamic>) {
          final data = fromJson(jsonData);
          return ApiResponse.success(data);
        }
        
        return ApiResponse.success(jsonData as T?);
      } else {
        String errorMessage = ApiService._getErrorMessageForStatusCode(statusCode);
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          errorData['title'] ?? 
                          errorMessage;
          }
        } catch (_) {
          // Use default error message if JSON parsing fails
        }
        
        return ApiResponse.error(errorMessage, statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
  
  // Get appropriate error message based on HTTP status code
  static String _getErrorMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ErrorMessages.validationError;
      case 401:
        return ErrorMessages.unauthorizedError;
      case 403:
        return ErrorMessages.forbiddenError;
      case 404:
        return ErrorMessages.notFoundError;
      case 500:
      case 502:
      case 503:
      case 504:
        return ErrorMessages.serverError;
      default:
        return '${ErrorMessages.unknownError} (Status: $statusCode)';
    }
  }
}

// API Response wrapper class
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;
  
  ApiResponse._({this.data, this.error, this.statusCode, required this.isSuccess});
  
  factory ApiResponse.success(T? data) {
    return ApiResponse._(data: data, isSuccess: true);
  }
  
  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse._(error: error, statusCode: statusCode, isSuccess: false);
  }
}

// API Service Methods Extension
extension ApiServiceMethods on ApiService {
  // Authentication
  Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    final response = await _makeRequest<LoginResponse>(
      'POST',
      '/Auth/login',
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
      fromJson: (json) => LoginResponse.fromJson(json),
    );
    
    // Save token if login successful
    if (response.isSuccess && response.data?.token != null) {
      await saveToken(response.data!.token);
    }
    
    return response;
  }
  
  Future<ApiResponse<void>> logout() async {
    await clearToken();
    return ApiResponse.success(null);
  }
  
  // CheckPoints
  Future<ApiResponse<List<CheckPoint>>> getCheckPoints() async {
    final response = await _makeRequest<List<CheckPoint>>(
      'GET',
      '/CheckPoints',
      fromJson: (json) {
        final List<dynamic> checkPointsJson = json['checkPoints'] ?? json;
        return checkPointsJson.map((item) => CheckPoint.fromJson(item)).toList();
      },
    );
    
    return response;
  }
  
  // Get checkpoint logs
  Future<ApiResponse<List<CheckPointLog>>> getCheckPointLogs() async {
    final response = await _makeRequest<List<CheckPointLog>>(
      'GET',
      '/CheckPoints/logs',
      fromJson: (json) {
        final List<dynamic> logsJson = json['logs'] ?? json;
        return logsJson.map((item) => CheckPointLog.fromJson(item)).toList();
      },
    );
    
    return response;
  }

  // Get admin checkpoint logs
  Future<ApiResponse<List<CheckPointLog>>> getAdminCheckPointLogs() async {
    final response = await _makeRequest<List<CheckPointLog>>(
      'GET',
      '/CheckPoints/admin/logs',
      fromJson: (json) {
        final List<dynamic> logsJson = json['logs'] ?? json;
        return logsJson.map((item) => CheckPointLog.fromJson(item)).toList();
      },
    );
    
    return response;
  }

  Future<ApiResponse<CheckPointLog>> submitCheckPointScan(
    String checkPointId,
    Map<String, dynamic> scanRequest,
  ) async {
    final response = await _makeRequest<CheckPointLog>(
      'POST',
      '/CheckPoints/$checkPointId/scan',
      body: scanRequest,
      fromJson: (json) => CheckPointLog.fromJson(json),
    );
    
    return response;
  }
  
  // Stop Cards
  Future<ApiResponse<List<StopCard>>> getStopCards() async {
    final response = await _makeRequest<List<StopCard>>(
      'GET',
      '/StopCards',
      fromJson: (json) {
        final List<dynamic> stopCardsJson = json['stopCards'] ?? json;
        return stopCardsJson.map((item) => StopCard.fromJson(item)).toList();
      },
    );
    
    return response;
  }
  
  Future<ApiResponse<StopCard>> createStopCard({
    required String title,
    required String description,
    required String priority,
    required String status,
    List<String>? imageUrls,
  }) async {
    final response = await _makeRequest<StopCard>(
      'POST',
      '/StopCards',
      body: {
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
        'imageUrls': imageUrls ?? [],
        'createdAt': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => StopCard.fromJson(json),
    );
    
    return response;
  }
  
  Future<ApiResponse<StopCard>> getStopCardById(int id) async {
    final response = await _makeRequest<StopCard>(
      'GET',
      '/StopCards/$id',
      fromJson: (json) => StopCard.fromJson(json),
    );
    
    return response;
  }
  
  // Image Upload
  Future<ApiResponse<ImageUploadResponse>> uploadImage(String filePath) async {
    try {
      final token = await getToken();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      final uri = Uri.parse('${ApiService._baseUrl}/Image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      final streamedResponse = await request.send()
           .timeout(const Duration(seconds: ApiConstants.uploadTimeoutSeconds));
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final uploadResponse = ImageUploadResponse.fromJson(jsonData);
        return ApiResponse.success(uploadResponse);
      } else {
        String errorMessage = 'Image upload failed with status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (_) {}
        
        return ApiResponse.error(errorMessage, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Image upload failed: $e');
    }
  }
  
  Future<ApiResponse<List<ImageUploadResponse>>> uploadMultipleImages(
    List<String> filePaths,
  ) async {
    final List<ImageUploadResponse> uploadedImages = [];
    
    for (final filePath in filePaths) {
      final response = await uploadImage(filePath);
      if (response.isSuccess && response.data != null) {
        uploadedImages.add(response.data!);
      } else {
        return ApiResponse.error(
          'Failed to upload image: ${response.error}',
          response.statusCode,
        );
      }
    }
    
    return ApiResponse.success(uploadedImages);
  }
  
  // User Profile
  Future<ApiResponse<User>> getUserProfile() async {
    final response = await _makeRequest<User>(
      'GET',
      '/Users/profile',
      fromJson: (json) => User.fromJson(json),
    );
    
    return response;
  }
}