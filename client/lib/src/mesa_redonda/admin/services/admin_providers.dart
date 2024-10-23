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
}

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final isAdminProvider = FutureProvider<bool>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return adminService.isUserAdmin();
});

// Optional: Provider to cache the admin status
final cachedAdminStatusProvider = StateProvider<bool>((ref) => false);
