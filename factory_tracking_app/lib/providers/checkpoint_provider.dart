import 'package:flutter/foundation.dart';
import '../models/checkpoint.dart';
import '../models/common.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CheckPointProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CheckPoint> _checkPoints = [];
  List<CheckPointLog> _checkPointLogs = [];
  List<AdminCheckPointLog> _adminLogs = [];
  
  LoadingState _checkPointsState = LoadingState.idle;
  LoadingState _logsState = LoadingState.idle;
  LoadingState _scanState = LoadingState.idle;
  LoadingState _adminLogsState = LoadingState.idle;
  
  String? _checkPointsError;
  String? _logsError;
  String? _scanError;
  String? _adminLogsError;
  
  CheckPoint? _selectedCheckPoint;
  
  // Pagination for admin logs
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasNextPage = false;
  
  // Getters
  List<CheckPoint> get checkPoints => List.unmodifiable(_checkPoints);
  List<CheckPointLog> get checkPointLogs => List.unmodifiable(_checkPointLogs);
  List<AdminCheckPointLog> get adminLogs => List.unmodifiable(_adminLogs);
  
  LoadingState get checkPointsState => _checkPointsState;
  LoadingState get logsState => _logsState;
  LoadingState get scanState => _scanState;
  LoadingState get adminLogsState => _adminLogsState;
  
  String? get checkPointsError => _checkPointsError;
  String? get logsError => _logsError;
  String? get scanError => _scanError;
  String? get adminLogsError => _adminLogsError;
  
  CheckPoint? get selectedCheckPoint => _selectedCheckPoint;
  
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _currentPage > 1;
  
  bool get isLoading => 
      _checkPointsState.isLoading || 
      _logsState.isLoading || 
      _scanState.isLoading || 
      _adminLogsState.isLoading;
  
  // Active checkpoints only
  List<CheckPoint> get activeCheckPoints => 
      _checkPoints.where((cp) => cp.isActive).toList();
  
  // Recent logs (last 10)
  List<CheckPointLog> get recentLogs => 
      _checkPointLogs.take(10).toList();
  
  // Load all checkpoints
  Future<Result<List<CheckPoint>>> loadCheckPoints({bool forceRefresh = false}) async {
    if (!forceRefresh && _checkPoints.isNotEmpty && _checkPointsState.isSuccess) {
      return Result.success(_checkPoints);
    }
    
    _setCheckPointsState(LoadingState.loading);
    _checkPointsError = null;
    
    try {
      final response = await _apiService.getCheckPoints();
      
      if (response.success && response.data != null) {
        _checkPoints = response.data!;
        _setCheckPointsState(LoadingState.success);
        return Result.success(_checkPoints);
      } else {
        _checkPointsError = response.error ?? ErrorMessages.dataLoadFailed;
        _setCheckPointsState(LoadingState.error);
        return Result.error(_checkPointsError!);
      }
    } catch (e) {
      _checkPointsError = 'Failed to load checkpoints: $e';
      _setCheckPointsState(LoadingState.error);
      return Result.error(_checkPointsError!);
    }
  }
  
  // Load user's checkpoint logs
  Future<Result<List<CheckPointLog>>> loadCheckPointLogs({bool forceRefresh = false}) async {
    if (!forceRefresh && _checkPointLogs.isNotEmpty && _logsState.isSuccess) {
      return Result.success(_checkPointLogs);
    }
    
    _setLogsState(LoadingState.loading);
    _logsError = null;
    
    try {
      final response = await _apiService.getCheckPointLogs();
      
      if (response.success && response.data != null) {
        _checkPointLogs = response.data!;
        _setLogsState(LoadingState.success);
        return Result.success(_checkPointLogs);
      } else {
        _logsError = response.error ?? ErrorMessages.dataLoadFailed;
        _setLogsState(LoadingState.error);
        return Result.error(_logsError!);
      }
    } catch (e) {
      _logsError = 'Failed to load checkpoint logs: $e';
      _setLogsState(LoadingState.error);
      return Result.error(_logsError!);
    }
  }
  
  // Load admin checkpoint logs with pagination
  Future<Result<AdminCheckPointLogsResponse>> loadAdminLogs({
    int page = 1,
    int pageSize = 20,
    bool append = false,
  }) async {
    _setAdminLogsState(LoadingState.loading);
    _adminLogsError = null;
    
    try {
      final response = await _apiService.getAdminCheckPointLogs(
        page: page,
        pageSize: pageSize,
      );
      
      if (response.success && response.data != null) {
        final logsResponse = response.data!;
        
        if (append && page > 1) {
          _adminLogs.addAll(logsResponse.logs);
        } else {
          _adminLogs = logsResponse.logs;
        }
        
        _currentPage = logsResponse.page;
        _totalPages = logsResponse.totalPages;
        _totalCount = logsResponse.totalCount;
        _hasNextPage = page < logsResponse.totalPages;
        
        _setAdminLogsState(LoadingState.success);
        return Result.success(logsResponse);
      } else {
        _adminLogsError = response.error ?? ErrorMessages.dataLoadFailed;
        _setAdminLogsState(LoadingState.error);
        return Result.error(_adminLogsError!);
      }
    } catch (e) {
      _adminLogsError = 'Failed to load admin logs: $e';
      _setAdminLogsState(LoadingState.error);
      return Result.error(_adminLogsError!);
    }
  }
  
  // Submit checkpoint scan
  Future<Result<void>> submitCheckPointScan(
    String checkPointId,
    CheckPointStatus status, {
    String? description,
    List<String>? imageUrls,
  }) async {
    _setScanState(LoadingState.loading);
    _scanError = null;
    
    try {
      final scanRequest = CheckPointScanRequest(
        status: status,
        description: description,
        imageUrls: imageUrls,
      );
      
      final response = await _apiService.submitCheckPointScan(checkPointId, scanRequest);
      
      if (response.success) {
        _setScanState(LoadingState.success);
        
        // Refresh logs to include the new scan
        await loadCheckPointLogs(forceRefresh: true);
        
        return Result.success(null);
      } else {
        _scanError = response.error ?? ErrorMessages.submitFailed;
        _setScanState(LoadingState.error);
        return Result.error(_scanError!);
      }
    } catch (e) {
      _scanError = 'Failed to submit scan: $e';
      _setScanState(LoadingState.error);
      return Result.error(_scanError!);
    }
  }
  
  // Find checkpoint by QR code
  CheckPoint? findCheckPointByQRCode(String qrCode) {
    try {
      return _checkPoints.firstWhere(
        (cp) => cp.qrCode == qrCode && cp.isActive,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Find checkpoint by ID
  CheckPoint? findCheckPointById(String id) {
    try {
      return _checkPoints.firstWhere((cp) => cp.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Set selected checkpoint
  void setSelectedCheckPoint(CheckPoint? checkPoint) {
    _selectedCheckPoint = checkPoint;
    notifyListeners();
  }
  
  // Get logs for specific checkpoint
  List<CheckPointLog> getLogsForCheckPoint(String checkPointId) {
    return _checkPointLogs
        .where((log) => log.checkPointName.contains(checkPointId))
        .toList();
  }
  
  // Get logs by status
  List<CheckPointLog> getLogsByStatus(CheckPointStatus status) {
    return _checkPointLogs
        .where((log) => log.status.toLowerCase() == status.displayName.toLowerCase())
        .toList();
  }
  
  // Get recent critical issues
  List<CheckPointLog> getCriticalIssues() {
    return _checkPointLogs
        .where((log) => log.status.toLowerCase().contains('critical'))
        .toList();
  }
  
  // Load next page of admin logs
  Future<Result<AdminCheckPointLogsResponse>> loadNextPage() async {
    if (!_hasNextPage) {
      return Result.error('No more pages available');
    }
    
    return await loadAdminLogs(
      page: _currentPage + 1,
      append: true,
    );
  }
  
  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadCheckPoints(forceRefresh: true),
      loadCheckPointLogs(forceRefresh: true),
    ]);
  }
  
  // Clear all errors
  void clearErrors() {
    _checkPointsError = null;
    _logsError = null;
    _scanError = null;
    _adminLogsError = null;
    notifyListeners();
  }
  
  // Clear specific errors
  void clearCheckPointsError() {
    _checkPointsError = null;
    notifyListeners();
  }
  
  void clearLogsError() {
    _logsError = null;
    notifyListeners();
  }
  
  void clearScanError() {
    _scanError = null;
    notifyListeners();
  }
  
  void clearAdminLogsError() {
    _adminLogsError = null;
    notifyListeners();
  }
  
  // Private helper methods
  void _setCheckPointsState(LoadingState state) {
    _checkPointsState = state;
    notifyListeners();
  }
  
  void _setLogsState(LoadingState state) {
    _logsState = state;
    notifyListeners();
  }
  
  void _setScanState(LoadingState state) {
    _scanState = state;
    notifyListeners();
  }
  
  void _setAdminLogsState(LoadingState state) {
    _adminLogsState = state;
    notifyListeners();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}