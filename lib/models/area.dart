/// Model representing a geographical area/location
class Area {
  final String id;
  final String name;
  final int order; // For sorting areas in display order

  Area({
    required this.id,
    required this.name,
    required this.order,
  });

  /// Create Area from Firestore document
  factory Area.fromJson(Map<String, dynamic> json, String id) {
    return Area(
      id: id,
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  /// Convert Area to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
    };
  }

  /// Create a copy with updated fields
  Area copyWith({
    String? id,
    String? name,
    int? order,
  }) {
    return Area(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  @override
  String toString() => 'Area(id: $id, name: $name, order: $order)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Area && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

