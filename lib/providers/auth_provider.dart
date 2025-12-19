import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _userDataSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Initialize auth state listener
  void initializeAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      try {
        if (firebaseUser != null) {
          debugPrint('🔔 Auth state changed: User logged in (${firebaseUser.uid})');
          // User is logged in, fetch user data
          _currentUser = await _authService.getUserData(firebaseUser.uid);
          // If getUserData returns null, create a default user model
          if (_currentUser == null) {
            debugPrint('⚠️ getUserData returned null, creating default user model');
            _currentUser = UserModel(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              role: 'user',
              favorites: [],
            );
          } else {
            debugPrint('✅ User data loaded successfully: $_currentUser');
          }
          
          // Set up real-time user data listener to sync favorites and other data
          _setupUserDataListener(firebaseUser.uid);
          
          notifyListeners();
        } else {
          // User is logged out
          debugPrint('🔔 Auth state changed: User logged out');
          _cancelUserDataListener();
          _currentUser = null;
          notifyListeners();
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Error in auth state listener: $e');
        debugPrint('Stack trace: $stackTrace');
        _errorMessage = 'Auth error: ${e.toString()}';
        _currentUser = null;
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('❌ Auth state stream error: $error');
      _errorMessage = 'Auth stream error: ${error.toString()}';
      _currentUser = null;
      notifyListeners();
    });
  }

  /// Set up real-time listener for user data changes in Firestore
  void _setupUserDataListener(String uid) {
    // Cancel any existing listener
    _cancelUserDataListener();
    
    // Listen to user data changes
    _userDataSubscription = _authService.getUserDataStream(uid).listen(
      (UserModel? userData) {
        if (userData != null) {
          debugPrint('🔄 User data updated from Firestore: ${userData.favorites.length} favorites');
          _currentUser = userData;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('❌ Error in user data stream: $error');
      },
    );
  }

  /// Cancel user data listener
  void _cancelUserDataListener() {
    _userDataSubscription?.cancel();
    _userDataSubscription = null;
  }

  /// Get user data stream
  Stream<UserModel?> getUserStream(String uid) {
    return _authService.getUserDataStream(uid);
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      // Return true if we got a user, even if Firestore had issues
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      // Return true if we got a user, even if Firestore had issues
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _cancelUserDataListener();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_authService.currentUser != null) {
      final userData = await _authService.getUserData(
        _authService.currentUser!.uid,
      );
      if (userData != null) {
        _currentUser = userData;
      } else {
        // If getUserData returns null, create a default user model
        _currentUser = UserModel(
          uid: _authService.currentUser!.uid,
          email: _authService.currentUser!.email ?? '',
          role: 'user',
          favorites: [],
        );
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancelUserDataListener();
    super.dispose();
  }
}

