import 'package:flutter/foundation.dart';
import '../models/mosque.dart';
import '../services/firestore_service.dart';

/// Provider for managing user's favorite mosques
class FavoritesProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

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

  /// Add mosque to favorites
  Future<bool> addFavorite(String uid, String mosqueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addFavorite(uid, mosqueId);
      
      // Update local state
      _favoriteIds.add(mosqueId);
      
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

  /// Remove mosque from favorites
  Future<bool> removeFavorite(String uid, String mosqueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.removeFavorite(uid, mosqueId);
      
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

  /// Toggle favorite status
  Future<bool> toggleFavorite(String uid, String mosqueId) async {
    if (isFavorite(mosqueId)) {
      return await removeFavorite(uid, mosqueId);
    } else {
      return await addFavorite(uid, mosqueId);
    }
  }

  /// Clear all favorites from local state (doesn't remove from database)
  void clearLocalFavorites() {
    _favoriteMosques = [];
    _favoriteIds = [];
    notifyListeners();
  }

  /// Sync favorites with user data
  void syncFavorites(List<String> mosqueIds) {
    _favoriteIds = mosqueIds;
    loadFavorites(mosqueIds);
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

