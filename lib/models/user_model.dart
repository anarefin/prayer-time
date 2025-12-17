/// Model representing a user with role-based access
class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin' or 'user'
  final List<String> favorites; // List of favorite mosque IDs

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.favorites = const [],
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    // Safely parse favorites list
    List<String> parsedFavorites = [];
    try {
      final favoritesData = json['favorites'];
      if (favoritesData != null) {
        if (favoritesData is List) {
          parsedFavorites = favoritesData
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      print('Warning: Could not parse favorites list: $e');
      parsedFavorites = [];
    }

    return UserModel(
      uid: uid,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      favorites: parsedFavorites,
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'favorites': favorites,
    };
  }

  /// Check if user is an admin
  bool get isAdmin => role == 'admin';

  /// Check if a mosque is in favorites
  bool isFavorite(String mosqueId) {
    return favorites.contains(mosqueId);
  }

  /// Add a mosque to favorites
  UserModel addFavorite(String mosqueId) {
    if (favorites.contains(mosqueId)) return this;
    final newFavorites = List<String>.from(favorites)..add(mosqueId);
    return copyWith(favorites: newFavorites);
  }

  /// Remove a mosque from favorites
  UserModel removeFavorite(String mosqueId) {
    if (!favorites.contains(mosqueId)) return this;
    final newFavorites = List<String>.from(favorites)..remove(mosqueId);
    return copyWith(favorites: newFavorites);
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    List<String>? favorites,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, role: $role, favorites: ${favorites.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

