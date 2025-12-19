import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

/// Provider for managing connectivity state
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool _wasDisconnected = false;
  DateTime? _lastDisconnectTime;
  DateTime? _lastConnectTime;

  /// Whether device is connected to internet
  bool get isConnected => _isConnected;

  /// Whether device was previously disconnected (for showing reconnection message)
  bool get wasDisconnected => _wasDisconnected;

  /// Last time device disconnected
  DateTime? get lastDisconnectTime => _lastDisconnectTime;

  /// Last time device reconnected
  DateTime? get lastConnectTime => _lastConnectTime;

  ConnectivityProvider() {
    _initialize();
  }

  /// Initialize connectivity monitoring
  Future<void> _initialize() async {
    await _connectivityService.initialize();
    _isConnected = _connectivityService.isConnected;
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        _handleConnectivityChange(isConnected);
      },
    );
    
    notifyListeners();
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(bool isConnected) {
    final previousState = _isConnected;
    _isConnected = isConnected;

    if (previousState && !isConnected) {
      // Just disconnected
      _lastDisconnectTime = DateTime.now();
      _wasDisconnected = true;
      debugPrint('📡 Device went offline');
    } else if (!previousState && isConnected) {
      // Just reconnected
      _lastConnectTime = DateTime.now();
      debugPrint('📡 Device came back online');
      
      // Clear reconnection flag after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_isConnected) {
          _wasDisconnected = false;
          notifyListeners();
        }
      });
    }

    notifyListeners();
  }

  /// Manually check connectivity
  Future<bool> checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (_isConnected != isConnected) {
      _handleConnectivityChange(isConnected);
    }
    return isConnected;
  }

  /// Clear reconnection flag manually
  void clearReconnectionFlag() {
    _wasDisconnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

