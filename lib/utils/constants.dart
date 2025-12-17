import 'package:flutter/material.dart';

/// Application constants
class AppConstants {
  AppConstants._();

  // Prayer names
  static const String fajr = 'Fajr';
  static const String dhuhr = 'Dhuhr';
  static const String asr = 'Asr';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isha';
  static const String jummah = 'Jummah';

  // Bangladesh divisions
  static const List<String> bangladeshDivisions = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  // Facility types
  static const Map<String, String> facilityTypes = {
    'hasWomenPrayer': 'Women Prayer Place',
    'hasCarParking': 'Car Parking',
    'hasBikeParking': 'Motor Bike Parking',
    'hasCycleParking': 'Cycle Parking',
    'hasWudu': 'Wudu Facilities',
    'hasAC': 'Air Conditioning',
    'isWheelchairAccessible': 'Wheelchair Accessible',
  };
}

/// Mecca coordinates for Qibla calculation
class MeccaCoordinates {
  MeccaCoordinates._();

  static const double latitude = 21.4225;
  static const double longitude = 39.8262;
}

/// App theme colors
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF43A047);
  static const Color accent = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
}
