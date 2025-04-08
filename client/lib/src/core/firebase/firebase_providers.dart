import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

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

// // Current user provider with caching
// final currentUserProvider = FutureProvider<User?>((ref) {
//   final auth = ref.watch(firebaseAuthProvider);
  
//   // Listen to auth state changes to invalidate cache when needed
//   ref.listen(authStateChangesProvider, (_, __) {
//     ref.invalidateSelf();
//   });
  
//   return Future.value(auth.currentUser);
// });