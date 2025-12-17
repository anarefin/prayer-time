/// Model representing a mosque with location data and facilities
class Mosque {
  final String id;
  final String name;
  final String address;
  final String areaId;
  final double latitude;
  final double longitude;
  final bool hasWomenPrayer;
  final bool hasCarParking;
  final bool hasBikeParking;
  final bool hasCycleParking;
  final bool hasWudu;
  final bool hasAC;
  final bool isWheelchairAccessible;
  final String? description;

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.areaId,
    required this.latitude,
    required this.longitude,
    this.hasWomenPrayer = false,
    this.hasCarParking = false,
    this.hasBikeParking = false,
    this.hasCycleParking = false,
    this.hasWudu = true,
    this.hasAC = false,
    this.isWheelchairAccessible = false,
    this.description,
  });

  /// Create Mosque from Firestore document
  factory Mosque.fromJson(Map<String, dynamic> json, String id) {
    return Mosque(
      id: id,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      areaId: json['areaId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      hasWomenPrayer: json['hasWomenPrayer'] as bool? ?? false,
      hasCarParking: json['hasCarParking'] as bool? ?? false,
      hasBikeParking: json['hasBikeParking'] as bool? ?? false,
      hasCycleParking: json['hasCycleParking'] as bool? ?? false,
      hasWudu: json['hasWudu'] as bool? ?? true,
      hasAC: json['hasAC'] as bool? ?? false,
      isWheelchairAccessible: json['isWheelchairAccessible'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  /// Convert Mosque to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'areaId': areaId,
      'latitude': latitude,
      'longitude': longitude,
      'hasWomenPrayer': hasWomenPrayer,
      'hasCarParking': hasCarParking,
      'hasBikeParking': hasBikeParking,
      'hasCycleParking': hasCycleParking,
      'hasWudu': hasWudu,
      'hasAC': hasAC,
      'isWheelchairAccessible': isWheelchairAccessible,
      'description': description,
    };
  }

  /// Create a copy with updated fields
  Mosque copyWith({
    String? id,
    String? name,
    String? address,
    String? areaId,
    double? latitude,
    double? longitude,
    bool? hasWomenPrayer,
    bool? hasCarParking,
    bool? hasBikeParking,
    bool? hasCycleParking,
    bool? hasWudu,
    bool? hasAC,
    bool? isWheelchairAccessible,
    String? description,
  }) {
    return Mosque(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      areaId: areaId ?? this.areaId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasWomenPrayer: hasWomenPrayer ?? this.hasWomenPrayer,
      hasCarParking: hasCarParking ?? this.hasCarParking,
      hasBikeParking: hasBikeParking ?? this.hasBikeParking,
      hasCycleParking: hasCycleParking ?? this.hasCycleParking,
      hasWudu: hasWudu ?? this.hasWudu,
      hasAC: hasAC ?? this.hasAC,
      isWheelchairAccessible:
          isWheelchairAccessible ?? this.isWheelchairAccessible,
      description: description ?? this.description,
    );
  }

  /// Get list of available facilities
  List<String> getAvailableFacilities() {
    final facilities = <String>[];
    if (hasWomenPrayer) facilities.add('Women Prayer Place');
    if (hasCarParking) facilities.add('Car Parking');
    if (hasBikeParking) facilities.add('Bike Parking');
    if (hasCycleParking) facilities.add('Cycle Parking');
    if (hasWudu) facilities.add('Wudu Facilities');
    if (hasAC) facilities.add('Air Conditioning');
    if (isWheelchairAccessible) facilities.add('Wheelchair Accessible');
    return facilities;
  }

  @override
  String toString() =>
      'Mosque(id: $id, name: $name, address: $address, areaId: $areaId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mosque && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

