import 'package:flutter/foundation.dart';
import '../models/area.dart';
import '../models/mosque.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

/// Provider for managing mosques and areas state
class MosqueProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  List<Area> _areas = [];
  List<Mosque> _mosques = [];
  List<Mosque> _filteredMosques = [];
  List<Mosque> _nearbyMosques = [];
  String? _selectedAreaId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Facility filters
  Map<String, bool> _facilityFilters = {
    'hasWomenPrayer': false,
    'hasCarParking': false,
    'hasBikeParking': false,
    'hasCycleParking': false,
    'hasWudu': false,
    'hasAC': false,
    'isWheelchairAccessible': false,
  };

  List<Area> get areas => _areas;
  List<Mosque> get mosques => _searchQuery.isEmpty ? _mosques : _filteredMosques;
  List<Mosque> get nearbyMosques => _nearbyMosques;
  String? get selectedAreaId => _selectedAreaId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, bool> get facilityFilters => _facilityFilters;

  /// Get areas stream
  Stream<List<Area>> get areasStream => _firestoreService.getAreasStream();

  /// Get all mosques stream
  Stream<List<Mosque>> get mosquesStream => _firestoreService.getMosquesStream();

  /// Get mosques by area stream
  Stream<List<Mosque>> getMosquesByAreaStream(String areaId) {
    return _firestoreService.getMosquesByAreaStream(areaId);
  }

  /// Load areas
  Future<void> loadAreas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _areas = await _firestoreService.getAreas();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load areas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load mosques by area
  Future<void> loadMosquesByArea(String areaId) async {
    _selectedAreaId = areaId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mosques = await _firestoreService.getMosquesByArea(areaId);
      _filteredMosques = _mosques;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load mosques: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all mosques
  Future<void> loadAllMosques() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load via stream and collect first result
      _mosques = await _firestoreService.getMosquesStream().first;
      _filteredMosques = _mosques;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load mosques: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search mosques
  void searchMosques(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Add area
  Future<bool> addArea(Area area) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addArea(area);
      await loadAreas();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add area: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update area
  Future<bool> updateArea(Area area) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateArea(area);
      await loadAreas();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update area: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete area
  Future<bool> deleteArea(String areaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteArea(areaId);
      await loadAreas();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete area: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add mosque
  Future<bool> addMosque(Mosque mosque) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addMosque(mosque);
      if (_selectedAreaId != null) {
        await loadMosquesByArea(_selectedAreaId!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add mosque: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update mosque
  Future<bool> updateMosque(Mosque mosque) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateMosque(mosque);
      if (_selectedAreaId != null) {
        await loadMosquesByArea(_selectedAreaId!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update mosque: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete mosque
  Future<bool> deleteMosque(String mosqueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteMosque(mosqueId);
      if (_selectedAreaId != null) {
        await loadMosquesByArea(_selectedAreaId!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete mosque: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get a single mosque
  Future<Mosque?> getMosque(String mosqueId) async {
    try {
      return await _firestoreService.getMosque(mosqueId);
    } catch (e) {
      _errorMessage = 'Failed to get mosque: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Select area
  void selectArea(String? areaId) {
    _selectedAreaId = areaId;
    notifyListeners();
  }

  /// Load nearby mosques
  Future<void> loadNearbyMosques({double radiusKm = 5.0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nearbyMosques = await _locationService.getMosquesWithinRadius(radiusKm);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load nearby mosques: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Find nearest mosque
  Future<Mosque?> findNearestMosque() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final mosque = await _locationService.findNearestMosque();
      _isLoading = false;
      notifyListeners();
      return mosque;
    } catch (e) {
      _errorMessage = 'Failed to find nearest mosque: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Toggle facility filter
  void toggleFacilityFilter(String facilityKey) {
    _facilityFilters[facilityKey] = !(_facilityFilters[facilityKey] ?? false);
    _applyFilters();
    notifyListeners();
  }

  /// Clear all facility filters
  void clearFacilityFilters() {
    _facilityFilters = {
      'hasWomenPrayer': false,
      'hasCarParking': false,
      'hasBikeParking': false,
      'hasCycleParking': false,
      'hasWudu': false,
      'hasAC': false,
      'isWheelchairAccessible': false,
    };
    _applyFilters();
    notifyListeners();
  }

  /// Check if any facility filter is active
  bool get hasActiveFacilityFilters {
    return _facilityFilters.values.any((isActive) => isActive);
  }

  /// Apply search and facility filters
  void _applyFilters() {
    var filtered = _mosques;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((mosque) =>
              mosque.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              mosque.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply facility filters
    if (hasActiveFacilityFilters) {
      filtered = filtered.where((mosque) {
        bool matches = true;
        
        if (_facilityFilters['hasWomenPrayer'] == true && !mosque.hasWomenPrayer) {
          matches = false;
        }
        if (_facilityFilters['hasCarParking'] == true && !mosque.hasCarParking) {
          matches = false;
        }
        if (_facilityFilters['hasBikeParking'] == true && !mosque.hasBikeParking) {
          matches = false;
        }
        if (_facilityFilters['hasCycleParking'] == true && !mosque.hasCycleParking) {
          matches = false;
        }
        if (_facilityFilters['hasWudu'] == true && !mosque.hasWudu) {
          matches = false;
        }
        if (_facilityFilters['hasAC'] == true && !mosque.hasAC) {
          matches = false;
        }
        if (_facilityFilters['isWheelchairAccessible'] == true && 
            !mosque.isWheelchairAccessible) {
          matches = false;
        }
        
        return matches;
      }).toList();
    }

    _filteredMosques = filtered;
  }
}


