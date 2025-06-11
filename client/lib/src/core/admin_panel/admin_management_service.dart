import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/admin_user.dart';

/// Unified admin service that handles all admin-related operations.
/// Consolidates functionality from both AdminManagementService and AdminService.
class UnifiedAdminService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Private constructor for dependency injection
  UnifiedAdminService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Check if current user is admin with optimized caching
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Cache option for better performance
      const cacheOption = GetOptions(source: Source.serverAndCache);

      // Check admin document in Firestore
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get(cacheOption);

      // Check admin claims in user's token as fallback
      bool isAdminClaim = false;
      try {
        final idTokenResult = await user.getIdTokenResult(true);
        isAdminClaim = idTokenResult.claims?['admin'] == true;
      } catch (tokenError) {
        debugPrint('Error getting token claims: $tokenError');
      }

      // Check if user is a business owner
      bool isBusinessOwner = false;
      try {
        final ownershipQuery = await _firestore
            .collection('business_relationships')
            .where('userId', isEqualTo: user.uid)
            .where('role', isEqualTo: 'owner')
            .limit(1)
            .get(cacheOption);

        isBusinessOwner = ownershipQuery.docs.isNotEmpty;

        if (isBusinessOwner) {
          debugPrint('🔐 User ${user.uid} has business owner privileges');
        }
      } catch (businessError) {
        debugPrint('Error checking business ownership: $businessError');
      }

      return adminDoc.exists || isAdminClaim || isBusinessOwner;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Add new admin with transaction and validation
  Future<String> addAdmin(String email) async {
    try {
      // Verify current user is admin
      if (!await isCurrentUserAdmin()) {
        throw Exception('Unauthorized: Only admins can add other admins');
      }

      // Validate email format
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }

      // Find user by email
      final users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // Limit for performance
          .get();

      if (users.docs.isEmpty) {
        throw Exception('Usuario no encontrado. Debe registrarse primero.');
      }

      final uid = users.docs.first.id;

      // Check if already admin
      final existingAdmin =
          await _firestore.collection('admins').doc(uid).get();

      if (existingAdmin.exists) {
        return '$email ya es administrador';
      }

      // Add to admins collection with transaction for atomicity
      await _firestore.runTransaction((transaction) async {
        transaction.set(_firestore.collection('admins').doc(uid), {
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid,
        });
      });

      return 'Se agregó $email como administrador exitosamente';
    } catch (e) {
      debugPrint('Error al agregar administrador: $e');
      throw Exception('Error al agregar administrador: $e');
    }
  }

  // Remove admin with transaction and validation
  Future<String> removeAdmin(String email) async {
    try {
      // Verify current user is admin
      if (!await isCurrentUserAdmin()) {
        throw Exception('Unauthorized: Only admins can remove other admins');
      }

      // Prevent removing yourself
      if (_auth.currentUser?.email == email) {
        throw Exception(
            'No puedes eliminar tus propios privilegios de administrador');
      }

      // Find admin document by email
      final querySnapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1) // Limit for performance
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Administrador no encontrado');
      }

      // Remove admin document with transaction
      await _firestore.runTransaction((transaction) async {
        transaction.delete(
            _firestore.collection('admins').doc(querySnapshot.docs.first.id));
      });

      return 'Se eliminaron los privilegios de administrador de $email';
    } catch (e) {
      debugPrint('Error al eliminar administrador: $e');
      throw Exception('Error al eliminar administrador: $e');
    }
  }

  // Get all admins with error handling
  Stream<List<AdminUser>> getAdmins() {
    return _firestore.collection('admins').snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) {
              try {
                return AdminUser.fromMap(doc.id, doc.data());
              } catch (e) {
                debugPrint('Error parsing admin document: $e');
                return null;
              }
            })
            .where((admin) => admin != null)
            .cast<AdminUser>()
            .toList();
      } catch (e) {
        debugPrint('Error processing admin snapshot: $e');
        return <AdminUser>[];
      }
    });
  }

  // Get specific admin
  Future<AdminUser?> getAdmin(String uid) async {
    try {
      final doc = await _firestore
          .collection('admins')
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));

      if (doc.exists && doc.data() != null) {
        return AdminUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin: $e');
      return null;
    }
  }

  // Clear admin cache on logout
  void clearAdminStatus() {
    // Method to be called on logout to clear caches
  }
}

// Optimized providers with proper caching and dependency management
final unifiedAdminServiceProvider = Provider<UnifiedAdminService>((ref) {
  // Get Firestore instance from central Firebase provider
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UnifiedAdminService(firestore: firestore);
});

// Stream provider with error handling
final adminsStreamProvider = StreamProvider<List<AdminUser>>((ref) {
  final adminService = ref.watch(unifiedAdminServiceProvider);
  return adminService.getAdmins();
});

// Admin status provider with proper caching
final isAdminProvider = FutureProvider<bool>((ref) async {
  // Listen to auth state changes for cache invalidation
  ref.listen(authStateChangesProvider, (_, next) {
    // Clear cache when auth state changes
    ref.read(cachedAdminStatusProvider.notifier).state = false;
    // Invalidate this provider to re-check admin status
    ref.invalidateSelf();
  });

  final authState = ref.watch(authStateChangesProvider);

  // If user is not authenticated, they can't be admin
  if (authState.value == null) {
    ref.read(cachedAdminStatusProvider.notifier).state = false;
    return false;
  }

  // Check cached value first for performance
  final cachedStatus = ref.read(cachedAdminStatusProvider);
  if (cachedStatus) return true;

  // If not cached, check from service
  final adminService = ref.watch(unifiedAdminServiceProvider);
  final isAdmin = await adminService.isCurrentUserAdmin();

  // Update cache with the result
  ref.read(cachedAdminStatusProvider.notifier).state = isAdmin;

  return isAdmin;
});

// Single, centralized cache provider
final cachedAdminStatusProvider = StateProvider<bool>((ref) {
  // Listen to auth state changes to clear cache
  ref.listen(authStateChangesProvider, (_, next) {
    // Clear admin status when auth state changes
    if (next.value == null) {
      // User logged out, clear admin status
      // Note: We can't modify state in this callback, it will be handled
      // by the isAdminProvider instead
    }
  });

  return false;
});

// Provider that automatically checks admin status when user logs in
final autoCheckAdminStatusProvider = Provider<void>((ref) {
  ref.listen(authStateChangesProvider, (previous, next) async {
    // When user logs in (from null to authenticated)
    if (previous?.value == null && next.value != null) {
      // Force check admin status
      try {
        await ref.read(isAdminProvider.future);
      } catch (e) {
        debugPrint('Error checking admin status after login: $e');
      }
    }
  });
});
