import 'package:flutter/foundation.dart';

import '../models/prayer_time.dart';
import '../services/firestore_service.dart';

/// Provider for managing prayer times state
class PrayerTimeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  PrayerTime? _currentPrayerTime;
  String? _selectedMosqueId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  PrayerTime? get currentPrayerTime => _currentPrayerTime;
  String? get selectedMosqueId => _selectedMosqueId;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get nextPrayer => _currentPrayerTime?.getNextPrayer();

  /// Get prayer time stream for selected mosque and date
  Stream<PrayerTime?> getPrayerTimeStream(String mosqueId, DateTime date) {
    return _firestoreService.getPrayerTimeStream(mosqueId, date);
  }

  /// Load prayer time for specific mosque and date
  Future<void> loadPrayerTime(String mosqueId, DateTime date) async {
    _selectedMosqueId = mosqueId;
    _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPrayerTime = await _firestoreService.getPrayerTime(
        mosqueId,
        date,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load prayer times: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload current prayer time
  Future<void> reloadCurrentPrayerTime() async {
    if (_selectedMosqueId != null) {
      await loadPrayerTime(_selectedMosqueId!, _selectedDate);
    }
  }

  /// Change selected date
  void selectDate(DateTime date) {
    _selectedDate = date;
    if (_selectedMosqueId != null) {
      loadPrayerTime(_selectedMosqueId!, date);
    }
    notifyListeners();
  }

  /// Set prayer time (admin only)
  Future<bool> setPrayerTime(PrayerTime prayerTime) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.setPrayerTime(prayerTime);

      // Reload if it's the currently selected prayer time
      if (_selectedMosqueId == prayerTime.mosqueId &&
          _isSameDay(_selectedDate, prayerTime.date)) {
        _currentPrayerTime = prayerTime;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to set prayer time: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete prayer time (admin only)
  Future<bool> deletePrayerTime(String mosqueId, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deletePrayerTime(mosqueId, date);

      // Clear current prayer time if it was deleted
      if (_selectedMosqueId == mosqueId && _isSameDay(_selectedDate, date)) {
        _currentPrayerTime = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete prayer time: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get prayer times for a date range
  Future<List<PrayerTime>> getPrayerTimesRange(
    String mosqueId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _firestoreService.getPrayerTimesRange(
        mosqueId,
        startDate,
        endDate,
      );
    } catch (e) {
      _errorMessage = 'Failed to load prayer times: $e';
      notifyListeners();
      return [];
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _currentPrayerTime = null;
    _selectedMosqueId = null;
    _selectedDate = DateTime.now();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
