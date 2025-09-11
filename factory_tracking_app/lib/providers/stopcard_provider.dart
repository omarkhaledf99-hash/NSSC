import 'package:flutter/foundation.dart';
import '../models/stopcard.dart';
import '../models/common.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class StopCardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<StopCard> _stopCards = [];
  List<AdminStopCardDto> _adminStopCards = [];
  
  LoadingState _stopCardsState = LoadingState.idle;
  LoadingState _createState = LoadingState.idle;
  LoadingState _updateState = LoadingState.idle;
  LoadingState _deleteState = LoadingState.idle;
  LoadingState _adminStopCardsState = LoadingState.idle;
  
  String? _stopCardsError;
  String? _createError;
  String? _updateError;
  String? _deleteError;
  String? _adminStopCardsError;
  
  StopCard? _selectedStopCard;
  
  // Pagination for admin stop cards
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasNextPage = false;
  
  // Filters
  StopCardStatus? _statusFilter;
  StopCardPriority? _priorityFilter;
  String? _searchQuery;
  
  // Getters
  List<StopCard> get stopCards => List.unmodifiable(_stopCards);
  List<AdminStopCardDto> get adminStopCards => List.unmodifiable(_adminStopCards);
  
  LoadingState get stopCardsState => _stopCardsState;
  LoadingState get createState => _createState;
  LoadingState get updateState => _updateState;
  LoadingState get deleteState => _deleteState;
  LoadingState get adminStopCardsState => _adminStopCardsState;
  
  String? get stopCardsError => _stopCardsError;
  String? get createError => _createError;
  String? get updateError => _updateError;
  String? get deleteError => _deleteError;
  String? get adminStopCardsError => _adminStopCardsError;
  
  StopCard? get selectedStopCard => _selectedStopCard;
  
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _currentPage > 1;
  
  StopCardStatus? get statusFilter => _statusFilter;
  StopCardPriority? get priorityFilter => _priorityFilter;
  String? get searchQuery => _searchQuery;
  
  bool get isLoading => 
      _stopCardsState.isLoading || 
      _createState.isLoading || 
      _updateState.isLoading || 
      _deleteState.isLoading || 
      _adminStopCardsState.isLoading;
  
  // Filtered stop cards
  List<StopCard> get filteredStopCards {
    var filtered = _stopCards.where((card) {
      bool matchesStatus = _statusFilter == null || card.status == _statusFilter;
      bool matchesPriority = _priorityFilter == null || card.priority == _priorityFilter;
      bool matchesSearch = _searchQuery == null || 
          _searchQuery!.isEmpty || 
          card.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          card.description.toLowerCase().contains(_searchQuery!.toLowerCase());
      
      return matchesStatus && matchesPriority && matchesSearch;
    }).toList();
    
    // Sort by priority (critical first) and then by creation date
    filtered.sort((a, b) {
      int priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered;
  }
  
  // Active stop cards (open or in progress)
  List<StopCard> get activeStopCards => 
      _stopCards.where((card) => card.status.isActive).toList();
  
  // Critical stop cards
  List<StopCard> get criticalStopCards => 
      _stopCards.where((card) => card.priority.isCritical).toList();
  
  // Recent stop cards (last 10)
  List<StopCard> get recentStopCards => 
      _stopCards.take(10).toList();
  
  // Load user's stop cards
  Future<Result<List<StopCard>>> loadStopCards({bool forceRefresh = false}) async {
    if (!forceRefresh && _stopCards.isNotEmpty && _stopCardsState.isSuccess) {
      return Result.success(_stopCards);
    }
    
    _setStopCardsState(LoadingState.loading);
    _stopCardsError = null;
    
    try {
      final response = await _apiService.getStopCards();
      
      if (response.success && response.data != null) {
        _stopCards = response.data!;
        _setStopCardsState(LoadingState.success);
        return Result.success(_stopCards);
      } else {
        _stopCardsError = response.error ?? ErrorMessages.dataLoadFailed;
        _setStopCardsState(LoadingState.error);
        return Result.error(_stopCardsError!);
      }
    } catch (e) {
      _stopCardsError = 'Failed to load stop cards: $e';
      _setStopCardsState(LoadingState.error);
      return Result.error(_stopCardsError!);
    }
  }
  
  // Load admin stop cards with pagination
  Future<Result<AdminStopCardsResponse>> loadAdminStopCards({
    int page = 1,
    int pageSize = 20,
    bool append = false,
  }) async {
    _setAdminStopCardsState(LoadingState.loading);
    _adminStopCardsError = null;
    
    try {
      final response = await _apiService.getAdminStopCards(
        page: page,
        pageSize: pageSize,
      );
      
      if (response.success && response.data != null) {
        final stopCardsResponse = response.data!;
        
        if (append && page > 1) {
          _adminStopCards.addAll(stopCardsResponse.stopCards);
        } else {
          _adminStopCards = stopCardsResponse.stopCards;
        }
        
        _currentPage = stopCardsResponse.page;
        _totalPages = stopCardsResponse.totalPages;
        _totalCount = stopCardsResponse.totalCount;
        _hasNextPage = page < stopCardsResponse.totalPages;
        
        _setAdminStopCardsState(LoadingState.success);
        return Result.success(stopCardsResponse);
      } else {
        _adminStopCardsError = response.error ?? ErrorMessages.dataLoadFailed;
        _setAdminStopCardsState(LoadingState.error);
        return Result.error(_adminStopCardsError!);
      }
    } catch (e) {
      _adminStopCardsError = 'Failed to load admin stop cards: $e';
      _setAdminStopCardsState(LoadingState.error);
      return Result.error(_adminStopCardsError!);
    }
  }
  
  // Create new stop card
  Future<Result<StopCard>> createStopCard({
    required String title,
    required String description,
    required StopCardPriority priority,
    List<String>? imageUrls,
  }) async {
    _setCreateState(LoadingState.loading);
    _createError = null;
    
    try {
      final createRequest = CreateStopCardRequest(
        title: title,
        description: description,
        priority: priority,
        imageUrls: imageUrls,
      );
      
      final response = await _apiService.createStopCard(createRequest);
      
      if (response.success && response.data != null) {
        final newStopCard = response.data!;
        _stopCards.insert(0, newStopCard); // Add to beginning of list
        _setCreateState(LoadingState.success);
        return Result.success(newStopCard);
      } else {
        _createError = response.error ?? ErrorMessages.createFailed;
        _setCreateState(LoadingState.error);
        return Result.error(_createError!);
      }
    } catch (e) {
      _createError = 'Failed to create stop card: $e';
      _setCreateState(LoadingState.error);
      return Result.error(_createError!);
    }
  }
  
  // Get stop card by ID
  Future<Result<StopCard>> getStopCardById(String id) async {
    try {
      final response = await _apiService.getStopCardById(id);
      
      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.error ?? ErrorMessages.dataLoadFailed);
      }
    } catch (e) {
      return Result.error('Failed to get stop card: $e');
    }
  }
  
  // Update stop card status (admin function)
  Future<Result<StopCard>> updateStopCardStatus(
    String id,
    StopCardStatus newStatus,
  ) async {
    _setUpdateState(LoadingState.loading);
    _updateError = null;
    
    try {
      // Note: This would need an API endpoint for updating status
      // For now, update local data
      final index = _stopCards.indexWhere((card) => card.id == id);
      if (index != -1) {
        final updatedCard = _stopCards[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _stopCards[index] = updatedCard;
        _setUpdateState(LoadingState.success);
        return Result.success(updatedCard);
      } else {
        _updateError = 'Stop card not found';
        _setUpdateState(LoadingState.error);
        return Result.error(_updateError!);
      }
    } catch (e) {
      _updateError = 'Failed to update stop card: $e';
      _setUpdateState(LoadingState.error);
      return Result.error(_updateError!);
    }
  }
  
  // Delete stop card
  Future<Result<void>> deleteStopCard(String id) async {
    _setDeleteState(LoadingState.loading);
    _deleteError = null;
    
    try {
      // Note: This would need an API endpoint for deleting
      // For now, remove from local data
      _stopCards.removeWhere((card) => card.id == id);
      _setDeleteState(LoadingState.success);
      return Result.success(null);
    } catch (e) {
      _deleteError = 'Failed to delete stop card: $e';
      _setDeleteState(LoadingState.error);
      return Result.error(_deleteError!);
    }
  }
  
  // Set selected stop card
  void setSelectedStopCard(StopCard? stopCard) {
    _selectedStopCard = stopCard;
    notifyListeners();
  }
  
  // Set filters
  void setStatusFilter(StopCardStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }
  
  void setPriorityFilter(StopCardPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }
  
  void setSearchQuery(String? query) {
    _searchQuery = query?.trim();
    notifyListeners();
  }
  
  // Clear filters
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = null;
    notifyListeners();
  }
  
  // Get stop cards by status
  List<StopCard> getStopCardsByStatus(StopCardStatus status) {
    return _stopCards.where((card) => card.status == status).toList();
  }
  
  // Get stop cards by priority
  List<StopCard> getStopCardsByPriority(StopCardPriority priority) {
    return _stopCards.where((card) => card.priority == priority).toList();
  }
  
  // Get statistics
  Map<String, int> getStatusStatistics() {
    final stats = <String, int>{};
    for (final status in StopCardStatus.values) {
      stats[status.displayName] = _stopCards.where((card) => card.status == status).length;
    }
    return stats;
  }
  
  Map<String, int> getPriorityStatistics() {
    final stats = <String, int>{};
    for (final priority in StopCardPriority.values) {
      stats[priority.displayName] = _stopCards.where((card) => card.priority == priority).length;
    }
    return stats;
  }
  
  // Load next page of admin stop cards
  Future<Result<AdminStopCardsResponse>> loadNextPage() async {
    if (!_hasNextPage) {
      return Result.error('No more pages available');
    }
    
    return await loadAdminStopCards(
      page: _currentPage + 1,
      append: true,
    );
  }
  
  // Refresh all data
  Future<void> refreshAll() async {
    await loadStopCards(forceRefresh: true);
  }
  
  // Clear all errors
  void clearErrors() {
    _stopCardsError = null;
    _createError = null;
    _updateError = null;
    _deleteError = null;
    _adminStopCardsError = null;
    notifyListeners();
  }
  
  // Clear specific errors
  void clearStopCardsError() {
    _stopCardsError = null;
    notifyListeners();
  }
  
  void clearCreateError() {
    _createError = null;
    notifyListeners();
  }
  
  void clearUpdateError() {
    _updateError = null;
    notifyListeners();
  }
  
  void clearDeleteError() {
    _deleteError = null;
    notifyListeners();
  }
  
  void clearAdminStopCardsError() {
    _adminStopCardsError = null;
    notifyListeners();
  }
  
  // Private helper methods
  void _setStopCardsState(LoadingState state) {
    _stopCardsState = state;
    notifyListeners();
  }
  
  void _setCreateState(LoadingState state) {
    _createState = state;
    notifyListeners();
  }
  
  void _setUpdateState(LoadingState state) {
    _updateState = state;
    notifyListeners();
  }
  
  void _setDeleteState(LoadingState state) {
    _deleteState = state;
    notifyListeners();
  }
  
  void _setAdminStopCardsState(LoadingState state) {
    _adminStopCardsState = state;
    notifyListeners();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}