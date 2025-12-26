import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../models/mosque.dart';
import 'firestore_service.dart';
import 'connectivity_service.dart';

/// Service for handling location and Qibla direction calculations
class LocationService {
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Check if device is connected to internet (for map operations)
  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      throw 'No internet connection. Please check your network to open maps.';
    }
  }

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
    final x =
        math.cos(lat1) * math.sin(lat2) -
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
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Open app settings (for permission management)
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Find the nearest mosque to user's current location
  Future<Mosque?> findNearestMosque() async {
    try {
      final position = await getCurrentPosition();
      final nearbyMosques = await _firestoreService.getMosquesNearby(
        position.latitude,
        position.longitude,
        50, // Search within 50km radius
      );

      if (nearbyMosques.isEmpty) return null;

      return nearbyMosques.first; // Already sorted by distance
    } catch (e) {
      throw 'Failed to find nearest mosque: $e';
    }
  }

  /// Get mosques within a specific radius (in kilometers)
  Future<List<Mosque>> getMosquesWithinRadius(double radiusKm) async {
    try {
      final position = await getCurrentPosition();
      final mosques = await _firestoreService.getMosquesNearby(
        position.latitude,
        position.longitude,
        radiusKm,
      );

      // Limit to 10 mosques
      if (mosques.length > 10) {
        return mosques.take(10).toList();
      }

      return mosques;
    } catch (e) {
      throw 'Failed to get nearby mosques: $e';
    }
  }

  /// Get Google Maps directions URL for a mosque
  String getDirectionsUrl(double destinationLat, double destinationLng) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving';
  }

  /// Open Google Maps navigation to a mosque
  Future<void> openNavigation(
    double destinationLat,
    double destinationLng,
  ) async {
    // Check connectivity first
    await _checkConnectivity();

    // Try native Google Maps app first (better UX)
    final nativeUrl =
        'comgooglemaps://?daddr=$destinationLat,$destinationLng&directionsmode=driving';
    final nativeUri = Uri.parse(nativeUrl);

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to Apple Maps on iOS or generic geo intent on Android
    final geoUrl =
        'geo:$destinationLat,$destinationLng?q=$destinationLat,$destinationLng';
    final geoUri = Uri.parse(geoUrl);

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Final fallback to web-based Google Maps
    final webUrl = getDirectionsUrl(destinationLat, destinationLng);
    final webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open navigation. Please ensure you have Google Maps or a maps app installed.';
    }
  }

  /// Open Google Maps with multiple mosque locations
  Future<void> openMultipleMosquesInMap(
    List<Mosque> mosques,
    double userLat,
    double userLng,
  ) async {
    if (mosques.isEmpty) return;

    // Check connectivity first
    await _checkConnectivity();

    // Try native Google Maps app first
    final nativeUrl =
        'comgooglemaps://?center=$userLat,$userLng&q=mosque&zoom=15';
    final nativeUri = Uri.parse(nativeUrl);

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to geo search
    final geoUrl = 'geo:$userLat,$userLng?q=mosque&z=15';
    final geoUri = Uri.parse(geoUrl);

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Final fallback to web-based Google Maps
    final webUrl =
        'https://www.google.com/maps/search/mosque/@$userLat,$userLng,15z';
    final webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open map. Please ensure you have Google Maps or a maps app installed.';
    }
  }

  /// Get distance to a mosque from current location
  Future<double> getDistanceToMosque(Mosque mosque) async {
    try {
      final position = await getCurrentPosition();
      return calculateDistance(
        position.latitude,
        position.longitude,
        mosque.latitude,
        mosque.longitude,
      );
    } catch (e) {
      throw 'Failed to calculate distance: $e';
    }
  }

  /// Get formatted distance to a mosque from current location
  Future<String> getFormattedDistanceToMosque(Mosque mosque) async {
    try {
      final position = await getCurrentPosition();
      return getFormattedDistance(
        position.latitude,
        position.longitude,
        mosque.latitude,
        mosque.longitude,
      );
    } catch (e) {
      throw 'Failed to calculate distance: $e';
    }
  }
}
