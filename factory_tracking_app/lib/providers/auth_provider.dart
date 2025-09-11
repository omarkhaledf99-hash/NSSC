import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/common.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserInfo? _currentUser;
  LoadingState _loginState = LoadingState.idle;
  LoadingState _registerState = LoadingState.idle;
  LoadingState _logoutState = LoadingState.idle;
  LoadingState _profileState = LoadingState.idle;
  
  String? _loginError;
  String? _registerError;
  String? _profileError;
  
  bool _isInitialized = false;
  
  // Getters
  UserInfo? get currentUser => _currentUser;
  LoadingState get loginState => _loginState;
  LoadingState get registerState => _registerState;
  LoadingState get logoutState => _logoutState;
  LoadingState get profileState => _profileState;
  
  String? get loginError => _loginError;
  String? get registerError => _registerError;
  String? get profileError => _profileError;
  
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'Admin' || _currentUser?.role == '1';
  bool get isNormalUser => _currentUser?.role == 'NormalUser' || _currentUser?.role == '0';
  bool get isInitialized => _isInitialized;
  
  bool get isLoading => 
      _loginState.isLoading || 
      _registerState.isLoading || 
      _logoutState.isLoading || 
      _profileState.isLoading;
  
  // Initialize auth state from stored token
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final token = await _apiService.getToken();
      if (token != null && token.isNotEmpty) {
        // Try to get user profile to validate token
        await _loadUserProfile();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      // Clear invalid token
      await _apiService.clearToken();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  // Login user
  Future<Result<UserInfo>> login(String email, String password, {String? deviceInfo}) async {
    _setLoginState(LoadingState.loading);
    _loginError = null;
    
    try {
      final loginRequest = LoginRequest(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      );
      
      final response = await _apiService.login(loginRequest);
      
      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        _setLoginState(LoadingState.success);
        
        // Save user info to preferences
        await _saveUserInfo(_currentUser!);
        
        return Result.success(_currentUser!);
      } else {
        _loginError = response.error ?? ErrorMessages.loginFailed;
        _setLoginState(LoadingState.error);
        return Result.error(_loginError!);
      }
    } catch (e) {
      _loginError = 'Login failed: $e';
      _setLoginState(LoadingState.error);
      return Result.error(_loginError!);
    }
  }
  
  // Register user
  Future<Result<UserInfo>> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    _setRegisterState(LoadingState.loading);
    _registerError = null;
    
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      
      final response = await _apiService.register(registerRequest);
      
      if (response.success && response.data != null) {
        _setRegisterState(LoadingState.success);
        return Result.success(response.data!.user);
      } else {
        _registerError = response.error ?? ErrorMessages.registrationFailed;
        _setRegisterState(LoadingState.error);
        return Result.error(_registerError!);
      }
    } catch (e) {
      _registerError = 'Registration failed: $e';
      _setRegisterState(LoadingState.error);
      return Result.error(_registerError!);
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _setLogoutState(LoadingState.loading);
    
    try {
      // Call logout API
      await _apiService.logout();
      
      // Clear local data
      await _clearUserData();
      
      _currentUser = null;
      _setLogoutState(LoadingState.success);
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if API call fails, clear local data
      await _clearUserData();
      _currentUser = null;
      _setLogoutState(LoadingState.error);
    }
  }
  
  // Load user profile
  Future<Result<UserInfo>> loadUserProfile() async {
    return await _loadUserProfile();
  }
  
  Future<Result<UserInfo>> _loadUserProfile() async {
    _setProfileState(LoadingState.loading);
    _profileError = null;
    
    try {
      final response = await _apiService.getUserProfile();
      
      if (response.success && response.data != null) {
        _currentUser = response.data;
        _setProfileState(LoadingState.success);
        
        // Update saved user info
        await _saveUserInfo(_currentUser!);
        
        return Result.success(_currentUser!);
      } else {
        _profileError = response.error ?? ErrorMessages.profileLoadFailed;
        _setProfileState(LoadingState.error);
        
        // If unauthorized, clear token
        if (response.error?.contains('401') == true || 
            response.error?.contains('Unauthorized') == true) {
          await logout();
        }
        
        return Result.error(_profileError!);
      }
    } catch (e) {
      _profileError = 'Failed to load profile: $e';
      _setProfileState(LoadingState.error);
      return Result.error(_profileError!);
    }
  }
  
  // Update user profile
  Future<Result<UserInfo>> updateProfile(UserInfo updatedUser) async {
    _setProfileState(LoadingState.loading);
    _profileError = null;
    
    try {
      // Note: This would need an API endpoint for updating profile
      // For now, just update local data
      _currentUser = updatedUser;
      await _saveUserInfo(_currentUser!);
      
      _setProfileState(LoadingState.success);
      return Result.success(_currentUser!);
    } catch (e) {
      _profileError = 'Failed to update profile: $e';
      _setProfileState(LoadingState.error);
      return Result.error(_profileError!);
    }
  }
  
  // Clear all errors
  void clearErrors() {
    _loginError = null;
    _registerError = null;
    _profileError = null;
    notifyListeners();
  }
  
  // Clear specific error
  void clearLoginError() {
    _loginError = null;
    notifyListeners();
  }
  
  void clearRegisterError() {
    _registerError = null;
    notifyListeners();
  }
  
  void clearProfileError() {
    _profileError = null;
    notifyListeners();
  }
  
  // Private helper methods
  void _setLoginState(LoadingState state) {
    _loginState = state;
    notifyListeners();
  }
  
  void _setRegisterState(LoadingState state) {
    _registerState = state;
    notifyListeners();
  }
  
  void _setLogoutState(LoadingState state) {
    _logoutState = state;
    notifyListeners();
  }
  
  void _setProfileState(LoadingState state) {
    _profileState = state;
    notifyListeners();
  }
  
  Future<void> _saveUserInfo(UserInfo user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userInfo, user.toJson().toString());
    } catch (e) {
      debugPrint('Failed to save user info: $e');
    }
  }
  
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.userInfo);
      await _apiService.clearToken();
    } catch (e) {
      debugPrint('Failed to clear user data: $e');
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}