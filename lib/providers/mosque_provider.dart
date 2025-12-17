import 'package:flutter/foundation.dart';
import '../models/area.dart';
import '../models/mosque.dart';
import '../services/firestore_service.dart';

/// Provider for managing mosques and areas state
class MosqueProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Area> _areas = [];
  List<Mosque> _mosques = [];
  List<Mosque> _filteredMosques = [];
  String? _selectedAreaId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Area> get areas => _areas;
  List<Mosque> get mosques => _searchQuery.isEmpty ? _mosques : _filteredMosques;
  String? get selectedAreaId => _selectedAreaId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    if (query.isEmpty) {
      _filteredMosques = _mosques;
    } else {
      _filteredMosques = _mosques
          .where((mosque) =>
              mosque.name.toLowerCase().contains(query.toLowerCase()) ||
              mosque.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredMosques = _mosques;
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
}

