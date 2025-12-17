import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Register a new user
  Future<UserModel?> register({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          role: 'user', // Default role
          favorites: [],
        );

        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());
        } catch (firestoreError) {
          // Log the error but don't fail registration
          // User is created in Firebase Auth, Firestore can be synced later
          print('Firestore error during registration: $firestoreError');
        }

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during registration: ${e.toString()}';
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          // Get user data from Firestore
          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data();
            print('✅ User document found: $data');
            
            if (data == null) {
              print('⚠️ User document exists but data is null, creating default user');
              final userModel = UserModel(
                uid: userCredential.user!.uid,
                email: email,
                role: 'user',
                favorites: [],
              );
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set(userModel.toJson());
              return userModel;
            }
            
            try {
              final userModel = UserModel.fromJson(data, userDoc.id);
              print('✅ UserModel parsed successfully: $userModel');
              return userModel;
            } catch (parseError) {
              print('❌ Error parsing UserModel: $parseError');
              print('📄 Raw data: $data');
              // Return a default user model if parsing fails
              return UserModel(
                uid: userCredential.user!.uid,
                email: email,
                role: data['role'] ?? 'user',
                favorites: [],
              );
            }
          } else {
            // User document doesn't exist, create it
            print('⚠️ User document not found, creating new one');
            final userModel = UserModel(
              uid: userCredential.user!.uid,
              email: email,
              role: 'user', // Default role
              favorites: [],
            );

            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(userModel.toJson());

            print('✅ New user document created');
            return userModel;
          }
        } catch (firestoreError) {
          // If Firestore fails, still return a user model
          // This ensures authentication works even if Firestore has issues
          print('❌ Firestore error: $firestoreError');
          return UserModel(
            uid: userCredential.user!.uid,
            email: email,
            role: 'user',
            favorites: [],
          );
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign in: ${e.toString()}';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'An error occurred during sign out';
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!, userDoc.id);
      } else {
        // Document doesn't exist, create a default one
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final userModel = UserModel(
            uid: uid,
            email: currentUser.email ?? '',
            role: 'user',
            favorites: [],
          );
          
          try {
            await _firestore.collection('users').doc(uid).set(userModel.toJson());
          } catch (e) {
            print('Error creating user document: $e');
          }
          
          return userModel;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      // Return null instead of throwing to prevent app crashes
      return null;
    }
  }

  /// Get user data stream
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email';
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address (e.g., user@example.com)';
      case 'weak-password':
        return 'Password must be at least 6 characters long';
      case 'user-disabled':
        return 'This account has been disabled. Contact support';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      default:
        return e.message ?? 'Authentication failed. Please try again';
    }
  }
}

