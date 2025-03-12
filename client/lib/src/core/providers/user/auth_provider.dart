import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../services/auth_service.dart';

// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for current Firebase user
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(firebaseUserProvider).value?.uid;
});


final isCurrentUserProvider = FutureProvider.family<bool, String>((ref, email) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  return currentUser?.email == email;
});


// Provider for current app user data
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value(null);
  }
  
  return authService.streamUserData(userId);
});


// Provider to check if user has a specific role
final hasRoleProvider = Provider.family<bool, String>((ref, role) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.hasRole(role) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider for authentication state
final authStateProvider = Provider<AuthState>((ref) {
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
});

// Authentication state enum
enum AuthState {
  loading,
  authenticated,
  unauthenticated,
  disabled,
  error,
}