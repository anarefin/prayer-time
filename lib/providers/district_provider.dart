import 'package:flutter/foundation.dart';
import '../models/district.dart';
import '../models/area.dart';
import '../services/firestore_service.dart';

/// Provider for managing districts and area selection state
class DistrictProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<District> _districts = [];
  List<Area> _areasByDistrict = [];
  String? _selectedDistrictId;
  String? _selectedAreaId;
  bool _isLoading = false;
  String? _errorMessage;

  List<District> get districts => _districts;
  List<Area> get areasByDistrict => _areasByDistrict;
  String? get selectedDistrictId => _selectedDistrictId;
  String? get selectedAreaId => _selectedAreaId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get districts stream
  Stream<List<District>> get districtsStream =>
      _firestoreService.getDistrictsStream();

  /// Get areas by district stream
  Stream<List<Area>> getAreasByDistrictStream(String districtId) {
    return _firestoreService.getAreasByDistrictStream(districtId);
  }

  /// Load all districts
  Future<void> loadDistricts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _districts = await _firestoreService.getDistricts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load districts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load areas by selected district
  Future<void> loadAreasByDistrict(String districtId) async {
    _selectedDistrictId = districtId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _areasByDistrict = await _firestoreService.getAreasByDistrict(districtId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load areas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get districts grouped by division
  Map<String, List<District>> getDistrictsByDivision() {
    final Map<String, List<District>> grouped = {};
    for (final district in _districts) {
      if (!grouped.containsKey(district.divisionName)) {
        grouped[district.divisionName] = [];
      }
      grouped[district.divisionName]!.add(district);
    }
    return grouped;
  }

  /// Select district
  void selectDistrict(String? districtId) {
    _selectedDistrictId = districtId;
    _selectedAreaId = null; // Reset area selection
    _areasByDistrict = [];
    notifyListeners();

    if (districtId != null) {
      loadAreasByDistrict(districtId);
    }
  }

  /// Select area
  void selectArea(String? areaId) {
    _selectedAreaId = areaId;
    notifyListeners();
  }

  /// Get selected district
  District? getSelectedDistrict() {
    if (_selectedDistrictId == null) return null;
    try {
      return _districts.firstWhere((d) => d.id == _selectedDistrictId);
    } catch (e) {
      return null;
    }
  }

  /// Get selected area
  Area? getSelectedArea() {
    if (_selectedAreaId == null) return null;
    try {
      return _areasByDistrict.firstWhere((a) => a.id == _selectedAreaId);
    } catch (e) {
      return null;
    }
  }

  /// Add district (admin only)
  Future<bool> addDistrict(District district) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addDistrict(district);
      await loadDistricts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add district: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update district (admin only)
  Future<bool> updateDistrict(District district) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateDistrict(district);
      await loadDistricts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update district: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete district (admin only)
  Future<bool> deleteDistrict(String districtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteDistrict(districtId);
      await loadDistricts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete district: $e';
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

  /// Clear selection
  void clearSelection() {
    _selectedDistrictId = null;
    _selectedAreaId = null;
    _areasByDistrict = [];
    notifyListeners();
  }
}

