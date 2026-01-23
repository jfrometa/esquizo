import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

part 'auth_providers.g.dart';

/// Unified Authentication Repository that consolidates all auth-related functionality.
/// This combines the features from AuthRepository and also integrates with Firebase UI Auth.
class UnifiedAuthRepository {
  final FirebaseAuth _auth;

  UnifiedAuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // Basic auth state methods
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Force refresh the auth state - useful for updating claims
  Future<void> forceRefreshAuthState() async {
    try {
      await _auth.currentUser?.reload();
      debugPrint("User state refreshed: ${_auth.currentUser?.uid}");
    } on FirebaseAuthException catch (e) {
      debugPrint('Error refreshing auth state: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Anonymous sign-in with error handling
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      await _auth.setPersistence(Persistence.SESSION);
      debugPrint('Signed in anonymously as ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to sign in anonymously: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Initialize authentication and handle existing sessions
  Future<User?> initialize() async {
    // Stop auto-anonymous login. Return current user (null if not logged in)
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint(
          'User is signed in: ${user.uid} (Anonymous: ${user.isAnonymous})');
    } else {
      debugPrint('User is not signed in (Guest mode)');
    }
    return user;
  }

  // Sign out with proper error handling
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out');
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing out: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Get user token with claims
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } on FirebaseAuthException catch (e) {
      debugPrint('Error getting token: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Check if user has specific claim
  Future<bool> hasUserClaim(String claim) async {
    try {
      final idTokenResult = await _auth.currentUser?.getIdTokenResult(true);
      return idTokenResult?.claims?[claim] == true;
    } catch (e) {
      debugPrint('Error checking user claim: $e');
      return false;
    }
  }
}

// Provider for auth providers (used by Firebase UI Auth)
@riverpod
List<firebase_ui.AuthProvider<firebase_ui.AuthListener, AuthCredential>>
    authProviders(Ref ref) {
  return [
    firebase_ui.EmailAuthProvider(),
  ];
}

// Auth repository provider
@Riverpod(keepAlive: true)
UnifiedAuthRepository authRepository(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return UnifiedAuthRepository(auth: auth);
}

// Auth state changes provider - cached and properly disposed
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
}

// Is anonymous provider with caching
@riverpod
bool isAnonymous(Ref ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  return user?.isAnonymous ?? true;
}

// Provider for auth service
@riverpod
UnifiedAuthService authService(Ref ref) {
  return UnifiedAuthService();
}

// Provider for current Firebase user
@riverpod
Stream<User?> firebaseUser(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

// Provider for current user ID
@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(firebaseUserProvider).value?.uid;
}

@riverpod
Future<bool> isCurrentUser(Ref ref, String email) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  return currentUser?.email == email;
}

// Provider for current app user data
@riverpod
Stream<AppUser?> currentUser(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  return authService.streamUserData(userId);
}

// Provider to check if user has a specific role
@riverpod
bool hasRole(Ref ref, String role) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.hasRole(role) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

// Provider for authentication state
@riverpod
AuthState authState(Ref ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return AuthState.unauthenticated;
      }
      if (!user.isActive) {
        return AuthState.disabled;
      }
      return AuthState.authenticated;
    },
    loading: () => AuthState.loading,
    error: (_, __) => AuthState.error,
  );
}

// Authentication state enum
enum AuthState {
  loading,
  authenticated,
  unauthenticated,
  disabled,
  error,
}
