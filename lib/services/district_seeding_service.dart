import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/district.dart';

/// Service for seeding Bangladesh districts data into Firestore
class DistrictSeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if districts have already been seeded
  Future<bool> isDistrictsSeeded() async {
    try {
      final snapshot = await _firestore.collection('districts').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking districts seeded status: $e');
      return false;
    }
  }

  /// Seed districts from JSON file into Firestore
  Future<void> seedDistricts() async {
    try {
      // Check if already seeded
      final alreadySeeded = await isDistrictsSeeded();
      if (alreadySeeded) {
        debugPrint('Districts already seeded, skipping...');
        return;
      }

      debugPrint('Loading Bangladesh districts data...');

      // Load JSON file
      final String jsonString =
          await rootBundle.loadString('assets/data/bangladesh_districts.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<dynamic> divisions = data['divisions'] as List<dynamic>;

      debugPrint('Seeding ${divisions.length} divisions...');

      // Use batch write for better performance
      WriteBatch batch = _firestore.batch();
      int batchCount = 0;
      int totalDistricts = 0;

      for (var division in divisions) {
        final String divisionName = division['name'] as String;
        final List<dynamic> districts = division['districts'] as List<dynamic>;

        for (var districtData in districts) {
          final district = District(
            id: '', // Will be auto-generated
            name: districtData['name'] as String,
            divisionName: divisionName,
            order: districtData['order'] as int,
          );

          // Create a new document reference
          final docRef = _firestore.collection('districts').doc();
          batch.set(docRef, district.toJson());

          batchCount++;
          totalDistricts++;

          // Firestore batch limit is 500 operations
          if (batchCount >= 500) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
            debugPrint('Committed batch, $totalDistricts districts seeded so far...');
          }
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
      }

      debugPrint(
          'Successfully seeded $totalDistricts districts from ${divisions.length} divisions!');
    } catch (e) {
      debugPrint('Error seeding districts: $e');
      rethrow;
    }
  }

  /// Force re-seed (delete all existing districts and re-seed)
  Future<void> forceReseed() async {
    try {
      debugPrint('Force re-seeding districts...');

      // Delete all existing districts
      final snapshot = await _firestore.collection('districts').get();
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;
        if (count >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      debugPrint('Deleted existing districts, now seeding...');

      // Re-seed
      await seedDistricts();
    } catch (e) {
      debugPrint('Error force re-seeding districts: $e');
      rethrow;
    }
  }
}

