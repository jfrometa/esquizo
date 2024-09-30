import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      print('Signed in anonymously as ${_auth.currentUser!.uid}');
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in anonymously: ${e.code} - ${e.message}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Initialize authentication
  Future<void> initialize() async {
    // If the user is not signed in, sign in anonymously
    if (_auth.currentUser == null) {
      await signInAnonymously();
    } else if (_auth.currentUser!.isAnonymous) {
      // User is signed in anonymously
      print('User is signed in anonymously: ${_auth.currentUser!.uid}');
    } else {
      // User is signed in with a non-anonymous account
      print('User is signed in: ${_auth.currentUser!.uid}');
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
