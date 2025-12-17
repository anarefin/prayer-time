import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/district.dart';
import '../models/area.dart';
import '../models/mosque.dart';
import '../models/prayer_time.dart';
import '../models/user_model.dart';

/// Service for handling all Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== DISTRICTS ====================

  /// Get all districts as a stream
  Stream<List<District>> getDistrictsStream() {
    return _firestore
        .collection('districts')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => District.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get all districts (one-time fetch)
  Future<List<District>> getDistricts() async {
    final snapshot =
        await _firestore.collection('districts').orderBy('order').get();
    return snapshot.docs
        .map((doc) => District.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get districts by division
  Future<List<District>> getDistrictsByDivision(String divisionName) async {
    final snapshot = await _firestore
        .collection('districts')
        .where('divisionName', isEqualTo: divisionName)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => District.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get a single district by ID
  Future<District?> getDistrict(String districtId) async {
    final doc = await _firestore.collection('districts').doc(districtId).get();
    if (doc.exists) {
      return District.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Get a single district by ID (alias for consistency)
  Future<District?> getDistrictById(String districtId) async {
    return getDistrict(districtId);
  }

  /// Add a new district
  Future<String> addDistrict(District district) async {
    final docRef =
        await _firestore.collection('districts').add(district.toJson());
    return docRef.id;
  }

  /// Update a district
  Future<void> updateDistrict(District district) async {
    await _firestore
        .collection('districts')
        .doc(district.id)
        .update(district.toJson());
  }

  /// Delete a district
  Future<void> deleteDistrict(String districtId) async {
    // Check if any areas exist in this district
    final areasSnapshot = await _firestore
        .collection('areas')
        .where('districtId', isEqualTo: districtId)
        .limit(1)
        .get();

    if (areasSnapshot.docs.isNotEmpty) {
      throw 'Cannot delete district with existing areas';
    }

    await _firestore.collection('districts').doc(districtId).delete();
  }

  // ==================== AREAS ====================

  /// Get all areas as a stream
  Stream<List<Area>> getAreasStream() {
    return _firestore
        .collection('areas')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Area.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get all areas (one-time fetch)
  Future<List<Area>> getAreas() async {
    final snapshot =
        await _firestore.collection('areas').orderBy('order').get();
    return snapshot.docs
        .map((doc) => Area.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get areas by district ID
  Future<List<Area>> getAreasByDistrict(String districtId) async {
    final snapshot = await _firestore
        .collection('areas')
        .where('districtId', isEqualTo: districtId)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Area.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get areas by district ID as a stream
  Stream<List<Area>> getAreasByDistrictStream(String districtId) {
    return _firestore
        .collection('areas')
        .where('districtId', isEqualTo: districtId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Area.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get a single area by ID
  Future<Area?> getAreaById(String areaId) async {
    final doc = await _firestore.collection('areas').doc(areaId).get();
    if (doc.exists) {
      return Area.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Add a new area
  Future<String> addArea(Area area) async {
    final docRef = await _firestore.collection('areas').add(area.toJson());
    return docRef.id;
  }

  /// Update an area
  Future<void> updateArea(Area area) async {
    await _firestore.collection('areas').doc(area.id).update(area.toJson());
  }

  /// Delete an area
  Future<void> deleteArea(String areaId) async {
    // Check if any mosques exist in this area
    final mosquesSnapshot = await _firestore
        .collection('mosques')
        .where('areaId', isEqualTo: areaId)
        .limit(1)
        .get();

    if (mosquesSnapshot.docs.isNotEmpty) {
      throw 'Cannot delete area with existing mosques';
    }

    await _firestore.collection('areas').doc(areaId).delete();
  }

  // ==================== MOSQUES ====================

  /// Get all mosques as a stream
  Stream<List<Mosque>> getMosquesStream() {
    return _firestore
        .collection('mosques')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Mosque.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get mosques by area ID as a stream
  Stream<List<Mosque>> getMosquesByAreaStream(String areaId) {
    return _firestore
        .collection('mosques')
        .where('areaId', isEqualTo: areaId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Mosque.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get mosques by area ID (one-time fetch)
  Future<List<Mosque>> getMosquesByArea(String areaId) async {
    final snapshot = await _firestore
        .collection('mosques')
        .where('areaId', isEqualTo: areaId)
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((doc) => Mosque.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get a single mosque by ID
  Future<Mosque?> getMosque(String mosqueId) async {
    final doc = await _firestore.collection('mosques').doc(mosqueId).get();
    if (doc.exists) {
      return Mosque.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Add a new mosque
  Future<String> addMosque(Mosque mosque) async {
    final docRef = await _firestore.collection('mosques').add(mosque.toJson());
    return docRef.id;
  }

  /// Update a mosque
  Future<void> updateMosque(Mosque mosque) async {
    await _firestore
        .collection('mosques')
        .doc(mosque.id)
        .update(mosque.toJson());
  }

  /// Delete a mosque
  Future<void> deleteMosque(String mosqueId) async {
    // Delete associated prayer times
    final prayerTimesSnapshot = await _firestore
        .collection('prayer_times')
        .where('mosqueId', isEqualTo: mosqueId)
        .get();

    final batch = _firestore.batch();
    for (var doc in prayerTimesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the mosque
    batch.delete(_firestore.collection('mosques').doc(mosqueId));

    await batch.commit();
  }

  /// Search mosques by name
  Future<List<Mosque>> searchMosques(String query) async {
    final snapshot = await _firestore
        .collection('mosques')
        .orderBy('name')
        .get();
    
    // Filter in memory (Firestore doesn't support text search)
    return snapshot.docs
        .map((doc) => Mosque.fromJson(doc.data(), doc.id))
        .where((mosque) =>
            mosque.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get nearby mosques within a radius (in kilometers)
  /// Note: This requires client-side filtering as Firestore doesn't support geo-queries natively
  /// For production, consider using GeoFlutterFire or similar packages
  Future<List<Mosque>> getMosquesNearby(
    double userLat,
    double userLng,
    double radiusKm,
  ) async {
    // Get all mosques (in production, limit this with bounding box)
    final snapshot = await _firestore.collection('mosques').get();
    
    final mosques = snapshot.docs
        .map((doc) => Mosque.fromJson(doc.data(), doc.id))
        .toList();

    // Filter by distance
    final nearbyMosques = <Mosque>[];
    for (final mosque in mosques) {
      final distance = _calculateDistance(
        userLat,
        userLng,
        mosque.latitude,
        mosque.longitude,
      );
      if (distance <= radiusKm) {
        nearbyMosques.add(mosque);
      }
    }

    // Sort by distance
    nearbyMosques.sort((a, b) {
      final distA = _calculateDistance(userLat, userLng, a.latitude, a.longitude);
      final distB = _calculateDistance(userLat, userLng, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });

    return nearbyMosques;
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  // ==================== PRAYER TIMES ====================

  /// Get prayer times for a specific mosque and date
  Future<PrayerTime?> getPrayerTime(String mosqueId, DateTime date) async {
    final id = PrayerTime.generateId(mosqueId, date);
    final doc = await _firestore.collection('prayer_times').doc(id).get();

    if (doc.exists) {
      return PrayerTime.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Get prayer times stream for a specific mosque and date
  Stream<PrayerTime?> getPrayerTimeStream(String mosqueId, DateTime date) {
    final id = PrayerTime.generateId(mosqueId, date);
    return _firestore.collection('prayer_times').doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return PrayerTime.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Get prayer times for a mosque in a date range
  Future<List<PrayerTime>> getPrayerTimesRange(
    String mosqueId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('prayer_times')
        .where('mosqueId', isEqualTo: mosqueId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0])
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0])
        .get();

    return snapshot.docs
        .map((doc) => PrayerTime.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Add or update prayer time
  Future<void> setPrayerTime(PrayerTime prayerTime) async {
    await _firestore
        .collection('prayer_times')
        .doc(prayerTime.id)
        .set(prayerTime.toJson());
  }

  /// Set prayer times for a date range
  Future<void> setPrayerTimeRange(
    String mosqueId,
    DateTime startDate,
    DateTime endDate,
    DateTime fajr,
    DateTime dhuhr,
    DateTime asr,
    DateTime maghrib,
    DateTime isha,
    DateTime? jummah,
  ) async {
    final batch = _firestore.batch();
    int batchCount = 0;

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final prayerTime = PrayerTime(
        id: PrayerTime.generateId(mosqueId, currentDate),
        mosqueId: mosqueId,
        date: currentDate,
        fajr: DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          fajr.hour,
          fajr.minute,
        ),
        dhuhr: DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          dhuhr.hour,
          dhuhr.minute,
        ),
        asr: DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          asr.hour,
          asr.minute,
        ),
        maghrib: DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          maghrib.hour,
          maghrib.minute,
        ),
        isha: DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          isha.hour,
          isha.minute,
        ),
        jummah: jummah != null
            ? DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                jummah.hour,
                jummah.minute,
              )
            : null,
      );

      final docRef = _firestore.collection('prayer_times').doc(prayerTime.id);
      batch.set(docRef, prayerTime.toJson());

      batchCount++;

      // Firestore batch limit is 500 operations
      if (batchCount >= 500) {
        await batch.commit();
        batchCount = 0;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Commit remaining operations
    if (batchCount > 0) {
      await batch.commit();
    }
  }

  /// Delete prayer time
  Future<void> deletePrayerTime(String mosqueId, DateTime date) async {
    final id = PrayerTime.generateId(mosqueId, date);
    await _firestore.collection('prayer_times').doc(id).delete();
  }

  // ==================== USERS ====================

  /// Get user data
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  /// Get user data stream
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  /// Add mosque to user favorites
  Future<void> addFavorite(String uid, String mosqueId) async {
    await _firestore.collection('users').doc(uid).update({
      'favorites': FieldValue.arrayUnion([mosqueId]),
    });
  }

  /// Remove mosque from user favorites
  Future<void> removeFavorite(String uid, String mosqueId) async {
    await _firestore.collection('users').doc(uid).update({
      'favorites': FieldValue.arrayRemove([mosqueId]),
    });
  }

  /// Get user's favorite mosques
  Future<List<Mosque>> getFavoriteMosques(List<String> mosqueIds) async {
    if (mosqueIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('mosques')
        .where(FieldPath.documentId, whereIn: mosqueIds)
        .get();

    return snapshot.docs
        .map((doc) => Mosque.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get user's favorite mosques stream
  Stream<List<Mosque>> getFavoriteMosquesStream(List<String> mosqueIds) {
    if (mosqueIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('mosques')
        .where(FieldPath.documentId, whereIn: mosqueIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Mosque.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}

