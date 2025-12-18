import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring internet connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  bool _isConnected = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Get stream of connectivity changes
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Check if device is currently connected to internet
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        await _handleConnectivityChange(result);
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = await _hasInternetConnection(result);
      _updateConnectivity(hasConnection);
      return hasConnection;
    } catch (e) {
      print('Error checking connectivity: $e');
      _updateConnectivity(false);
      return false;
    }
  }

  /// Handle connectivity changes
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    final hasConnection = await _hasInternetConnection(result);
    _updateConnectivity(hasConnection);
  }

  /// Check if device has actual internet connection (not just WiFi/mobile connection)
  Future<bool> _hasInternetConnection(ConnectivityResult result) async {
    // If no connectivity result, return false
    if (result == ConnectivityResult.none) {
      return false;
    }

    // Try to ping a reliable server to verify actual internet access
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      print('Error verifying internet connection: $e');
      return false;
    }
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivity(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController?.add(_isConnected);
      print('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}

