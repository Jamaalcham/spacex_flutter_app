import 'dart:async';
import 'dart:io';

// Manages network connectivity status for offline functionality

// Provides methods to check internet connectivity and listen for

// connectivity changes to enable offline data caching fallbacks
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Timer? _connectivityTimer;
  bool _isConnected = true;

  // Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Current connectivity status
  bool get isConnected => _isConnected;

  // Starts monitoring connectivity
  void startMonitoring() {
    // Check connectivity every 10 seconds
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnectivity();
    });
    
    // Initial check
    _checkConnectivity();
  }

  // Stops monitoring connectivity
  void stopMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
  }

  // Checks current internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectivity(isConnected);
      return isConnected;
    } catch (e) {
      _updateConnectivity(false);
      return false;
    }
  }

  // Private method to check connectivity
  Future<void> _checkConnectivity() async {
    await checkConnectivity();
  }

  // Updates connectivity status and notifies listeners
  void _updateConnectivity(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  // Disposes resources
  void dispose() {
    stopMonitoring();
    _connectivityController.close();
  }
}

// Extension to add connectivity checking to any class
extension ConnectivityCheck on Object {
  // Quick connectivity check
  Future<bool> get hasInternetConnection => ConnectivityManager().checkConnectivity();
}
