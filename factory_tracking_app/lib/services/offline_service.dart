import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;
  final List<VoidCallback> _listeners = [];

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialize the offline service
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        await _checkConnectivity();
      },
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      bool wasOnline = _isOnline;
      
      if (result == ConnectivityResult.none) {
        _isOnline = false;
      } else {
        // Additional check by trying to reach a reliable server
        _isOnline = await _hasInternetConnection();
      }
      
      // Notify listeners if status changed
      if (wasOnline != _isOnline) {
        _notifyListeners();
      }
    } catch (e) {
      _isOnline = false;
      _notifyListeners();
    }
  }

  /// Test actual internet connectivity by pinging a reliable server
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add a listener for connectivity changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of connectivity changes
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Show offline banner in the given context
  static void showOfflineBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You are offline. Data will be saved locally and synced when connection is restored.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show online banner in the given context
  static void showOnlineBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'Connection restored. Syncing data...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Check if operation should proceed or show offline message
  static bool checkConnectivityAndNotify(BuildContext context) {
    final offlineService = OfflineService();
    if (offlineService.isOffline) {
      showOfflineBanner(context);
      return false;
    }
    return true;
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _listeners.clear();
  }
}

/// Widget that shows connectivity status
class ConnectivityIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;

  const ConnectivityIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  final OfflineService _offlineService = OfflineService();
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _offlineService.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _offlineService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (mounted && widget.showBanner) {
      if (_offlineService.isOffline && !_wasOffline) {
        // Just went offline
        OfflineService.showOfflineBanner(context);
        _wasOffline = true;
      } else if (_offlineService.isOnline && _wasOffline) {
        // Just came back online
        OfflineService.showOnlineBanner(context);
        _wasOffline = false;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_offlineService.isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Offline Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}