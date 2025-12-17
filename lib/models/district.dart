/// Model representing a district in Bangladesh
class District {
  final String id;
  final String name;
  final String divisionName;
  final int order; // For sorting districts in display order

  District({
    required this.id,
    required this.name,
    required this.divisionName,
    required this.order,
  });

  /// Create District from Firestore document
  factory District.fromJson(Map<String, dynamic> json, String id) {
    return District(
      id: id,
      name: json['name'] as String? ?? '',
      divisionName: json['divisionName'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  /// Convert District to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'divisionName': divisionName,
      'order': order,
    };
  }

  /// Create a copy with updated fields
  District copyWith({
    String? id,
    String? name,
    String? divisionName,
    int? order,
  }) {
    return District(
      id: id ?? this.id,
      name: name ?? this.name,
      divisionName: divisionName ?? this.divisionName,
      order: order ?? this.order,
    );
  }

  @override
  String toString() =>
      'District(id: $id, name: $name, divisionName: $divisionName, order: $order)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

