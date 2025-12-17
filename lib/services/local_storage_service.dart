import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage operations
class LocalStorageService {
  static const String _favoritesKey = 'favorite_mosques';

  /// Get favorite mosque IDs from local storage
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      return favorites;
    } catch (e) {
      print('Error loading favorites from local storage: $e');
      return [];
    }
  }

  /// Save favorite mosque IDs to local storage
  Future<bool> saveFavorites(List<String> mosqueIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, mosqueIds);
      return true;
    } catch (e) {
      print('Error saving favorites to local storage: $e');
      return false;
    }
  }

  /// Add a mosque to favorites
  Future<bool> addFavorite(String mosqueId) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.contains(mosqueId)) {
        favorites.add(mosqueId);
        return await saveFavorites(favorites);
      }
      return true;
    } catch (e) {
      print('Error adding favorite to local storage: $e');
      return false;
    }
  }

  /// Remove a mosque from favorites
  Future<bool> removeFavorite(String mosqueId) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(mosqueId);
      return await saveFavorites(favorites);
    } catch (e) {
      print('Error removing favorite from local storage: $e');
      return false;
    }
  }

  /// Check if a mosque is in favorites
  Future<bool> isFavorite(String mosqueId) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(mosqueId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
}

