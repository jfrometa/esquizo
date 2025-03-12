import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/admin_user.dart';

class AdminManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user is admin with caching
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Use get() with source option for better caching
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get(const GetOptions(source: Source.serverAndCache));

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

      // Validate email format
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }

      String? uid;
      // Get user by email directly
      final users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // Limit for performance
          .get();
          
      if (users.docs.isNotEmpty) {
        uid = users.docs.first.id;
      }

      if (uid == null) {
        throw Exception('Usuario no encontrado. Debe registrarse primero.');
      }

      // Check if already admin
      final existingAdmin = await _firestore
          .collection('admins')
          .doc(uid)
          .get();
          
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
      throw Exception('Error al agregar administrador: $e');
    }
  }

  // Remove admin
  Future<String> removeAdmin(String email) async {
    try {
      // Verify current user is admin
      if (!await isCurrentUserAdmin()) {
        throw Exception('Unauthorized: Only admins can remove other admins');
      }

      // Prevent removing yourself
      if (_auth.currentUser?.email == email) {
        throw Exception('No puedes eliminar tus propios privilegios de administrador');
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
          _firestore.collection('admins').doc(querySnapshot.docs.first.id)
        );
      });

      return 'Se eliminaron los privilegios de administrador de $email';
    } catch (e) {
      throw Exception('Error al eliminar administrador: $e');
    }
  }

  // Get all admins with error handling
  Stream<List<AdminUser>> getAdmins() {
    return _firestore
        .collection('admins')
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) {
                  try {
                    return AdminUser.fromMap(doc.id, doc.data());
                  } catch (e) {
                    print('Error parsing admin document: $e');
                    return null;
                  }
                })
                .where((admin) => admin != null)
                .cast<AdminUser>()
                .toList();
          } catch (e) {
            print('Error processing admin snapshot: $e');
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
      print('Error getting admin: $e');
      return null;
    }
  }
}

// Providers with caching
final adminManagementServiceProvider = Provider<AdminManagementService>(
  (ref) => AdminManagementService(),
);

// Stream provider with error handling
final adminsStreamProvider = StreamProvider<List<AdminUser>>((ref) {
  final adminService = ref.watch(adminManagementServiceProvider);
  return adminService.getAdmins();
});

// Admin status provider with caching
final isAdminProvider = FutureProvider<bool>((ref) async {
  // Check cached value first
  final cachedStatus = ref.read(cachedAdminStatusProvider);
  if (cachedStatus) return true;
  
  // If not cached, check from service
  final adminService = ref.watch(adminManagementServiceProvider);
  final isAdmin = await adminService.isCurrentUserAdmin();
  
  // Update cache if admin
  if (isAdmin) {
    ref.read(cachedAdminStatusProvider.notifier).state = true;
  }
  
  return isAdmin;
});

// Cache provider
final cachedAdminStatusProvider = StateProvider<bool>((ref) => false);
