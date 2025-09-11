import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/network_helper.dart';

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
                .timeout(Duration(seconds: _timeoutSeconds));
            break;
          case 'POST':
            response = await _client.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(Duration(seconds: _timeoutSeconds));
            break;
          case 'PUT':
            response = await _client.put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(Duration(seconds: _timeoutSeconds));
            break;
          case 'DELETE':
            response = await _client.delete(url, headers: headers)
                .timeout(Duration(seconds: _timeoutSeconds));
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
    
    return ApiResponse.error('${ErrorMessages.unknownError} (${_maxRetries} attempts)');
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
        String errorMessage = _getErrorMessageForStatusCode(statusCode);
        
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
  String _getErrorMessageForStatusCode(int statusCode) {
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
  
  Future<ApiResponse<CheckPointScanResponse>> submitCheckPointScan(
    int checkPointId,
    String qrCode,
  ) async {
    final response = await _makeRequest<CheckPointScanResponse>(
      'POST',
      '/CheckPoints/$checkPointId/scan',
      body: {
        'qrCode': qrCode,
        'scannedAt': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => CheckPointScanResponse.fromJson(json),
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
      
      final uri = Uri.parse('$_baseUrl/Image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      final streamedResponse = await request.send()
           .timeout(Duration(seconds: ApiConstants.uploadTimeoutSeconds));
      
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
  Future<ApiResponse<UserProfile>> getUserProfile() async {
    final response = await _makeRequest<UserProfile>(
      'GET',
      '/Users/profile',
      fromJson: (json) => UserProfile.fromJson(json),
    );
    
    return response;
  }
}

// Data Models
class LoginResponse {
  final String token;
  final UserInfo user;
  
  LoginResponse({required this.token, required this.user});
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: UserInfo.fromJson(json['user'] ?? {}),
    );
  }
}

class UserInfo {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  
  UserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class CheckPoint {
  final int id;
  final String name;
  final String location;
  final String qrCode;
  final String status;
  final DateTime createdAt;
  
  CheckPoint({
    required this.id,
    required this.name,
    required this.location,
    required this.qrCode,
    required this.status,
    required this.createdAt,
  });
  
  factory CheckPoint.fromJson(Map<String, dynamic> json) {
    return CheckPoint(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      qrCode: json['qrCode'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class CheckPointScanResponse {
  final bool success;
  final String message;
  final CheckPointLog? log;
  
  CheckPointScanResponse({
    required this.success,
    required this.message,
    this.log,
  });
  
  factory CheckPointScanResponse.fromJson(Map<String, dynamic> json) {
    return CheckPointScanResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      log: json['log'] != null ? CheckPointLog.fromJson(json['log']) : null,
    );
  }
}

class CheckPointLog {
  final int id;
  final int checkPointId;
  final int userId;
  final DateTime scannedAt;
  final String? imageUrls;
  
  CheckPointLog({
    required this.id,
    required this.checkPointId,
    required this.userId,
    required this.scannedAt,
    this.imageUrls,
  });
  
  factory CheckPointLog.fromJson(Map<String, dynamic> json) {
    return CheckPointLog(
      id: json['id'] ?? 0,
      checkPointId: json['checkPointId'] ?? 0,
      userId: json['userId'] ?? 0,
      scannedAt: DateTime.tryParse(json['scannedAt'] ?? '') ?? DateTime.now(),
      imageUrls: json['imageUrls'],
    );
  }
}

class StopCard {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final List<String> imageUrls;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  StopCard({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.imageUrls,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory StopCard.fromJson(Map<String, dynamic> json) {
    return StopCard(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdBy: json['createdBy'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }
}

class ImageUploadResponse {
  final String fileName;
  final String url;
  final int fileSize;
  
  ImageUploadResponse({
    required this.fileName,
    required this.url,
    required this.fileSize,
  });
  
  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
      fileSize: json['fileSize'] ?? 0,
    );
  }
}

class UserProfile {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;
  
  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}