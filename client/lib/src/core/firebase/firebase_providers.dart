import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase providers to maintain a single source of truth
/// for all Firebase instances throughout the application.

// Firestore provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;

  // Configure settings for better performance
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  return firestore;
});

// Auth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Storage provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Realtime Database provider
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  final database = FirebaseDatabase.instance;

  // Enable persistence for offline capabilities only on non-web platforms
  // Web platforms don't support setPersistenceEnabled
  if (!kIsWeb) {
    try {
      database.setPersistenceEnabled(true);
    } catch (e) {
      debugPrint('Error setting persistence for Realtime Database: $e');
      // Continue even if setting persistence fails
    }
  }

  return database;
});

// // Current user provider with caching
// final currentUserProvider = FutureProvider<User?>((ref) {
//   final auth = ref.watch(firebaseAuthProvider);
  
//   // Listen to auth state changes to invalidate cache when needed
//   ref.listen(authStateChangesProvider, (_, __) {
//     ref.invalidateSelf();
//   });
  
//   return Future.value(auth.currentUser);
// });