import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage operations
class LocalStorageService {
  static const String _favoritesKey = 'favorite_mosques';
  static const String _locationPreferenceDivisionKey = 'location_preference_division';
  static const String _locationPreferenceDistrictKey = 'location_preference_district';
  static const String _locationPreferenceAreaKey = 'location_preference_area';

  /// Get favorite mosque IDs from local storage
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      return favorites;
    } catch (e) {
      debugPrint('Error loading favorites from local storage: $e');
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
      debugPrint('Error saving favorites to local storage: $e');
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
      debugPrint('Error adding favorite to local storage: $e');
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
      debugPrint('Error removing favorite from local storage: $e');
      return false;
    }
  }

  /// Check if a mosque is in favorites
  Future<bool> isFavorite(String mosqueId) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(mosqueId);
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
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
      debugPrint('Error clearing favorites: $e');
      return false;
    }
  }

  // ==================== LOCATION PREFERENCES ====================

  /// Save location preference to local storage
  Future<bool> saveLocationPreference({
    required String divisionName,
    required String districtId,
    required String areaId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationPreferenceDivisionKey, divisionName);
      await prefs.setString(_locationPreferenceDistrictKey, districtId);
      await prefs.setString(_locationPreferenceAreaKey, areaId);
      return true;
    } catch (e) {
      debugPrint('Error saving location preference: $e');
      return false;
    }
  }

  /// Get location preference from local storage
  /// Returns a Map with 'division', 'districtId', and 'areaId' keys
  /// Returns null if no preference is saved
  Future<Map<String, String>?> getLocationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final division = prefs.getString(_locationPreferenceDivisionKey);
      final districtId = prefs.getString(_locationPreferenceDistrictKey);
      final areaId = prefs.getString(_locationPreferenceAreaKey);

      // Only return if all values exist
      if (division != null && districtId != null && areaId != null) {
        return {
          'division': division,
          'districtId': districtId,
          'areaId': areaId,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting location preference: $e');
      return null;
    }
  }

  /// Clear location preference
  Future<bool> clearLocationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_locationPreferenceDivisionKey);
      await prefs.remove(_locationPreferenceDistrictKey);
      await prefs.remove(_locationPreferenceAreaKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing location preference: $e');
      return false;
    }
  }

  /// Check if location preference exists
  Future<bool> hasLocationPreference() async {
    final preference = await getLocationPreference();
    return preference != null;
  }
}

