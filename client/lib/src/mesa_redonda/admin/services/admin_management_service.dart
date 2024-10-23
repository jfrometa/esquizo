import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      return adminDoc.exists;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Add new admin
  Future<String> addAdmin(String email) async {
    try {
      // Verify current user is admin
      if (!await isCurrentUserAdmin()) {
        throw Exception('Unauthorized: Only admins can add other admins');
      }

      String? uid;
      // Get user by email directly
      final users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
          
      if (users.docs.isNotEmpty) {
        uid = users.docs.first.id;
      }

      if (uid == null) {
        throw Exception('Could not determine user ID');
      }

      // Add to admins collection
      await _firestore.collection('admins').doc(uid).set({
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      return 'Successfully added $email as admin';
    } catch (e) {
      throw Exception('Failed to add admin: $e');
    }
  }

  // Remove admin
  Future<String> removeAdmin(String email) async {
    try {
      // Verify current user is admin
      if (!await isCurrentUserAdmin()) {
        throw Exception('Unauthorized: Only admins can remove other admins');
      }

      // Find admin document by email
      final querySnapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Admin not found');
      }

      // Remove admin document
      await _firestore
          .collection('admins')
          .doc(querySnapshot.docs.first.id)
          .delete();

      return 'Successfully removed admin privileges from $email';
    } catch (e) {
      throw Exception('Failed to remove admin: $e');
    }
  }

  // Get all admins
  Stream<List<AdminUser>> getAdmins() {
    return _firestore
        .collection('admins')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminUser.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get specific admin
  Future<AdminUser?> getAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        return AdminUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting admin: $e');
      return null;
    }
  }
}

// Admin user model
class AdminUser {
  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? createdBy;

  AdminUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.createdBy,
  });

  factory AdminUser.fromMap(String uid, Map<String, dynamic> map) {
    return AdminUser(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'admin',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}

// Providers
final adminManagementServiceProvider = Provider<AdminManagementService>(
  (ref) => AdminManagementService(),
);

final adminsStreamProvider = StreamProvider<List<AdminUser>>((ref) {
  final adminService = ref.watch(adminManagementServiceProvider);
  return adminService.getAdmins();
});

final isAdminProvider = FutureProvider<bool>((ref) {
  final adminService = ref.watch(adminManagementServiceProvider);
  return adminService.isCurrentUserAdmin();
});
