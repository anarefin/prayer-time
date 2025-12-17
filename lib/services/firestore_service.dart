import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/area.dart';
import '../models/mosque.dart';
import '../models/prayer_time.dart';
import '../models/user_model.dart';

/// Service for handling all Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

