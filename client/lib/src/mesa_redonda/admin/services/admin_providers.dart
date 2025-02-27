import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null || user.isAnonymous) return false;

      // Check admin collection for user's ID
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      // Check admin claims in user's token
      final idTokenResult = await user.getIdTokenResult(true);
      final isAdminClaim = idTokenResult.claims?['admin'] == true;

      return adminDoc.exists || isAdminClaim;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
  
  // Add a method to clear admin status
  void clearAdminStatus() {}
}

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

// Update the isAdminProvider to listen to auth state changes
final isAdminProvider = FutureProvider<bool>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  final authStateChanges = FirebaseAuth.instance.authStateChanges();
  
  // Listen to auth state changes to update admin status
  ref.listen(authStateChangesProvider, (_, next) {
    if (next == null) {
      // User signed out, reset cached admin status
      ref.read(cachedAdminStatusProvider.notifier).state = false;
    }
  });
  
  return adminService.isUserAdmin();
});

// Auth state changes provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Optional: Provider to cache the admin status
final cachedAdminStatusProvider = StateProvider<bool>((ref) => false);
