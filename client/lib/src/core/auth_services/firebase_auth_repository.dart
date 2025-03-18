import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> forceRefreshAuthState() async {
    try {
      // Refreshes the current user, forcing a re-evaluation of auth state
      await _auth.currentUser?.reload();
      // Access currentUser again to trigger the auth state change
      debugPrint("User state refreshed: ${_auth.currentUser?.uid}");
    } on FirebaseAuthException catch (e) {
      debugPrint('Error refreshing auth state: ${e.code} - ${e.message}');
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      debugPrint('Signed in anonymously as ${_auth.currentUser!.uid}');
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to sign in anonymously: ${e.code} - ${e.message}');
    }
  }



  // Initialize authentication
  Future<void> initialize() async {
    // If the user is not signed in, sign in anonymously
    if (_auth.currentUser == null) {
      await signInAnonymously();
    } else if (_auth.currentUser!.isAnonymous) {
      // User is signed in anonymously
      debugPrint('User is signed in anonymously: ${_auth.currentUser!.uid}');
    } else {
      // User is signed in with a non-anonymous account
      debugPrint('User is signed in: ${_auth.currentUser!.uid}');
    }
  }
}

// final authStateChangesProvider = StreamProvider<User?>((ref) {
//   final firebaseAuth = ref.watch(firebaseAuthProvider);
//   return firebaseAuth.authStateChanges();
// });

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}
