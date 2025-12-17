import 'package:flutter/foundation.dart';
import '../models/mosque.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

/// Provider for managing user's favorite mosques
class FavoritesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Mosque> _favoriteMosques = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Mosque> get favoriteMosques => _favoriteMosques;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get favoriteCount => _favoriteIds.length;

  /// Check if a mosque is in favorites
  bool isFavorite(String mosqueId) {
    return _favoriteIds.contains(mosqueId);
  }

  /// Get favorite mosques stream
  Stream<List<Mosque>> getFavoriteMosquesStream(List<String> mosqueIds) {
    return _firestoreService.getFavoriteMosquesStream(mosqueIds);
  }

  /// Initialize favorites from local storage
  Future<void> initializeFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load favorite IDs from local storage
      _favoriteIds = await _localStorageService.getFavorites();
      
      // Load mosque details from Firestore
      if (_favoriteIds.isNotEmpty) {
        _favoriteMosques = await _firestoreService.getFavoriteMosques(_favoriteIds);
      } else {
        _favoriteMosques = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load favorites: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load favorite mosques
  Future<void> loadFavorites(List<String> mosqueIds) async {
    _favoriteIds = mosqueIds;
    
    if (mosqueIds.isEmpty) {
      _favoriteMosques = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favoriteMosques = await _firestoreService.getFavoriteMosques(mosqueIds);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load favorite mosques: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add mosque to favorites (now uses local storage)
  Future<bool> addFavorite(String mosqueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add to local storage
      await _localStorageService.addFavorite(mosqueId);
      
      // Update local state
      if (!_favoriteIds.contains(mosqueId)) {
        _favoriteIds.add(mosqueId);
      }
      
      // Reload favorites to get the mosque details
      await loadFavorites(_favoriteIds);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add favorite: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove mosque from favorites (now uses local storage)
  Future<bool> removeFavorite(String mosqueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Remove from local storage
      await _localStorageService.removeFavorite(mosqueId);
      
      // Update local state
      _favoriteIds.remove(mosqueId);
      _favoriteMosques.removeWhere((mosque) => mosque.id == mosqueId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite status (updated to not require uid)
  Future<bool> toggleFavorite(String mosqueId) async {
    if (isFavorite(mosqueId)) {
      return await removeFavorite(mosqueId);
    } else {
      return await addFavorite(mosqueId);
    }
  }

  /// Clear all favorites from local storage
  Future<void> clearAllFavorites() async {
    try {
      await _localStorageService.clearFavorites();
      _favoriteMosques = [];
      _favoriteIds = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear favorites: $e';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get favorite mosque by ID
  Mosque? getFavoriteMosque(String mosqueId) {
    try {
      return _favoriteMosques.firstWhere((mosque) => mosque.id == mosqueId);
    } catch (e) {
      return null;
    }
  }
}

