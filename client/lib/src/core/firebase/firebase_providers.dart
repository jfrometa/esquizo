import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';

part 'firebase_providers.g.dart';

/// Centralized Firebase providers to maintain a single source of truth
/// for all Firebase instances throughout the application.

// Firestore provider
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  final firestore = FirebaseFirestore.instance;

  // Configure settings for better performance
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  return firestore;
}

// Auth provider
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

// Storage provider
@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) {
  return FirebaseStorage.instance;
}

// Realtime Database provider
@Riverpod(keepAlive: true)
FirebaseDatabase firebaseDatabase(Ref ref) {
  // Prefer an explicit instanceFor with databaseURL to ensure the
  // Realtime Database connects to the configured project, especially on web.
  final databaseUrl = DefaultFirebaseOptions.currentPlatform.databaseURL;

  FirebaseDatabase database;
  try {
    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
  } catch (e) {
    debugPrint('Error creating FirebaseDatabase instanceFor: $e');
    // Fallback to the default instance if instanceFor fails
    database = FirebaseDatabase.instance;
  }

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
}
