import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

/// Service for handling location and Qibla direction calculations
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.location.status;
  }

  /// Request location permission
  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them in settings.';
    }

    // Check and request permission
    var permission = await checkLocationPermission();
    
    if (permission == PermissionStatus.denied) {
      permission = await requestLocationPermission();
    }

    if (permission == PermissionStatus.denied) {
      throw 'Location permission denied';
    }

    if (permission == PermissionStatus.permanentlyDenied) {
      throw 'Location permission permanently denied. Please enable it in settings.';
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw 'Failed to get current location: $e';
    }
  }

  /// Calculate Qibla direction (bearing) from current position
  /// Returns bearing in degrees (0-360)
  Future<double> getQiblaDirection() async {
    final position = await getCurrentPosition();
    return calculateBearing(
      position.latitude,
      position.longitude,
      MeccaCoordinates.latitude,
      MeccaCoordinates.longitude,
    );
  }

  /// Calculate Qibla direction from specific coordinates
  double getQiblaDirectionFromCoordinates(double latitude, double longitude) {
    return calculateBearing(
      latitude,
      longitude,
      MeccaCoordinates.latitude,
      MeccaCoordinates.longitude,
    );
  }

  /// Calculate bearing between two geographic points
  /// Returns bearing in degrees (0-360)
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Convert degrees to radians
    final lat1 = _degreesToRadians(startLat);
    final lat2 = _degreesToRadians(endLat);
    final lng1 = _degreesToRadians(startLng);
    final lng2 = _degreesToRadians(endLng);

    final dLng = lng2 - lng1;

    // Calculate bearing
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    var bearing = math.atan2(y, x);

    // Convert to degrees
    bearing = _radiansToDegrees(bearing);

    // Normalize to 0-360
    return (bearing + 360) % 360;
  }

  /// Calculate distance between two geographic points (in kilometers)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }

  /// Get formatted distance string
  String getFormattedDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distance = calculateDistance(startLat, startLng, endLat, endLng);
    
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Convert radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Get cardinal direction from bearing (N, NE, E, SE, S, SW, W, NW)
  String getCardinalDirection(double bearing) {
    const directions = [
      'N',
      'NE',
      'E',
      'SE',
      'S',
      'SW',
      'W',
      'NW',
      'N'
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Open app settings (for permission management)
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

