import 'package:intl/intl.dart';

/// Model representing prayer times for a specific mosque and date
class PrayerTime {
  final String id; // Format: mosqueId_date (e.g., mosque123_2024-01-15)
  final String mosqueId;
  final DateTime date;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? jummah; // Jummah prayer time (for Fridays)

  PrayerTime({
    required this.id,
    required this.mosqueId,
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.jummah,
  });

  /// Create PrayerTime from Firestore document
  factory PrayerTime.fromJson(Map<String, dynamic> json, String id) {
    final dateStr = json['date'] as String;
    final date = DateTime.parse(dateStr);

    return PrayerTime(
      id: id,
      mosqueId: json['mosqueId'] as String? ?? '',
      date: date,
      fajr: _parseTime(json['fajr'] as String, date),
      dhuhr: _parseTime(json['dhuhr'] as String, date),
      asr: _parseTime(json['asr'] as String, date),
      maghrib: _parseTime(json['maghrib'] as String, date),
      isha: _parseTime(json['isha'] as String, date),
      jummah: json['jummah'] != null
          ? _parseTime(json['jummah'] as String, date)
          : null,
    );
  }

  /// Convert PrayerTime to Firestore document
  Map<String, dynamic> toJson() {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final json = {
      'mosqueId': mosqueId,
      'date': dateStr,
      'fajr': DateFormat('HH:mm').format(fajr),
      'dhuhr': DateFormat('HH:mm').format(dhuhr),
      'asr': DateFormat('HH:mm').format(asr),
      'maghrib': DateFormat('HH:mm').format(maghrib),
      'isha': DateFormat('HH:mm').format(isha),
    };
    if (jummah != null) {
      json['jummah'] = DateFormat('HH:mm').format(jummah!);
    }
    return json;
  }

  /// Parse time string (HH:mm) and combine with date
  static DateTime _parseTime(String timeStr, DateTime date) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return date;
    }
  }

  /// Generate document ID from mosque ID and date
  static String generateId(String mosqueId, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '${mosqueId}_$dateStr';
  }

  /// Get the next upcoming prayer
  String? getNextPrayer() {
    final now = DateTime.now();
    
    if (now.isBefore(fajr)) return 'Fajr';
    if (now.isBefore(dhuhr)) return 'Dhuhr';
    if (now.isBefore(asr)) return 'Asr';
    if (now.isBefore(maghrib)) return 'Maghrib';
    if (now.isBefore(isha)) return 'Isha';
    
    return null; // All prayers have passed
  }

  /// Get the time of a specific prayer by name
  DateTime? getPrayerTime(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'dhuhr':
        return dhuhr;
      case 'jummah':
        return jummah;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }

  /// Format time for display (h:mm a)
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Get all prayer times as a map
  Map<String, DateTime> getAllPrayers() {
    final prayers = {
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
    
    // Add Jummah if it's Friday and jummah time is set
    if (isFriday() && jummah != null) {
      prayers['Jummah'] = jummah!;
    }
    
    return prayers;
  }

  /// Check if the date is a Friday
  bool isFriday() {
    return date.weekday == DateTime.friday;
  }

  /// Get prayer times for display (includes Jummah on Fridays)
  Map<String, DateTime> getPrayersForDisplay() {
    if (isFriday() && jummah != null) {
      return {
        'Fajr': fajr,
        'Dhuhr': dhuhr,
        'Jummah': jummah!,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      };
    }
    return getAllPrayers();
  }

  @override
  String toString() =>
      'PrayerTime(id: $id, mosqueId: $mosqueId, date: ${DateFormat('yyyy-MM-dd').format(date)})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerTime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

