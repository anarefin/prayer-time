/// Model representing a mosque with location data
class Mosque {
  final String id;
  final String name;
  final String address;
  final String areaId;
  final double latitude;
  final double longitude;

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.areaId,
    required this.latitude,
    required this.longitude,
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
  }) {
    return Mosque(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      areaId: areaId ?? this.areaId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
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

