import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();
  
  // Check internet connectivity
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  // Check if a specific host is reachable
  static Future<bool> isHostReachable(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  // Ping a URL to check if it's accessible
  static Future<bool> pingUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
  
  // Get network connection type (simplified)
  static Future<NetworkConnectionType> getConnectionType() async {
    try {
      final isConnected = await NetworkHelper.isConnected();
      if (!isConnected) {
        return NetworkConnectionType.none;
      }
      
      // This is a simplified check - in a real app you might want to use
      // connectivity_plus package for more detailed network information
      return NetworkConnectionType.unknown;
    } catch (_) {
      return NetworkConnectionType.none;
    }
  }
  
  // Check network speed (basic implementation)
  static Future<NetworkSpeed> checkNetworkSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Download a small file to test speed
      final response = await http.get(
        Uri.parse('https://httpbin.org/bytes/1024'), // 1KB test
      ).timeout(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final milliseconds = stopwatch.elapsedMilliseconds;
        
        if (milliseconds < 1000) {
          return NetworkSpeed.fast;
        } else if (milliseconds < 3000) {
          return NetworkSpeed.medium;
        } else {
          return NetworkSpeed.slow;
        }
      }
      
      return NetworkSpeed.unknown;
    } catch (_) {
      return NetworkSpeed.unknown;
    }
  }
}

// Network connection types
enum NetworkConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  unknown,
}

// Network speed categories
enum NetworkSpeed {
  fast,
  medium,
  slow,
  unknown,
}

// Network status class
class NetworkStatus {
  final bool isConnected;
  final NetworkConnectionType connectionType;
  final NetworkSpeed speed;
  final DateTime lastChecked;
  
  NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    required this.speed,
    required this.lastChecked,
  });
  
  factory NetworkStatus.disconnected() {
    return NetworkStatus(
      isConnected: false,
      connectionType: NetworkConnectionType.none,
      speed: NetworkSpeed.unknown,
      lastChecked: DateTime.now(),
    );
  }
  
  @override
  String toString() {
    return 'NetworkStatus(isConnected: $isConnected, type: $connectionType, speed: $speed)';
  }
}