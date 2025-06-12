import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Unified Authentication Service that consolidates all auth-related functionality.
/// This combines features from multiple auth services for a single source of truth.
class UnifiedAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UnifiedAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ===== AUTHENTICATION STATE =====

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Force refresh the auth state - useful for updating claims
  Future<void> forceRefreshAuthState() async {
    try {
      await _auth.currentUser?.reload();
      debugPrint("User state refreshed: ${_auth.currentUser?.uid}");
    } on FirebaseAuthException catch (e) {
      debugPrint('Error refreshing auth state: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // ===== SIGN IN METHODS =====

  /// Anonymous sign-in with error handling
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

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing in: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': null,
        'photoURL': null,
        'metadata': {},
        'roles': ['customer'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error creating user: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out');
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing out: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // ===== USER MANAGEMENT =====

  /// Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  /// Stream user data for real-time updates
  Stream<AppUser?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    try {
      // Update Auth profile
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update user metadata
  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'metadata': metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user metadata: $e');
      rethrow;
    }
  }

  // ===== ROLE MANAGEMENT =====

  /// Check if user has a specific role
  Future<bool> hasRole(String uid, String role) async {
    try {
      final appUser = await getUserData(uid);
      return appUser?.hasRole(role) ?? false;
    } catch (e) {
      debugPrint('Error checking role: $e');
      return false;
    }
  }

  /// Add role to user
  Future<void> addRole(String uid, String role) async {
    try {
      final appUser = await getUserData(uid);
      if (appUser == null) {
        throw Exception('User not found');
      }

      final roles = List<String>.from(appUser.roles);
      if (!roles.contains(role)) {
        roles.add(role);
        await _firestore.collection('users').doc(uid).update({
          'roles': roles,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error adding role: $e');
      rethrow;
    }
  }

  /// Remove role from user
  Future<void> removeRole(String uid, String role) async {
    try {
      final appUser = await getUserData(uid);
      if (appUser == null) {
        throw Exception('User not found');
      }

      final roles = List<String>.from(appUser.roles);
      if (roles.contains(role)) {
        roles.remove(role);
        await _firestore.collection('users').doc(uid).update({
          'roles': roles,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error removing role: $e');
      rethrow;
    }
  }

  // ===== ADMIN MANAGEMENT =====

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check admin document in Firestore
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();

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
            .get();

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

  /// Add new admin
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
          .limit(1)
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

      // Add to admins collection with transaction
      await _firestore.runTransaction((transaction) async {
        transaction.set(_firestore.collection('admins').doc(uid), {
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid,
        });
      });

      // Also add admin role to user document
      await addRole(uid, 'admin');

      return 'Se agregó $email como administrador exitosamente';
    } catch (e) {
      debugPrint('Error adding admin: $e');
      rethrow;
    }
  }

  /// Remove admin
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
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Administrador no encontrado');
      }

      final adminId = querySnapshot.docs.first.id;

      // Remove admin document with transaction
      await _firestore.runTransaction((transaction) async {
        transaction.delete(_firestore.collection('admins').doc(adminId));
      });

      // Also remove admin role from user document
      await removeRole(adminId, 'admin');

      return 'Se eliminaron los privilegios de administrador de $email';
    } catch (e) {
      debugPrint('Error removing admin: $e');
      rethrow;
    }
  }

  /// Get all admins
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

  // ===== STAFF MANAGEMENT =====

  /// Get staff by role
  Future<List<StaffMember>> getStaffByRole(StaffRole role) async {
    try {
      final roleStr = role.toString().split('.').last;
      final snapshot = await _firestore
          .collection('staff')
          .where('role', isEqualTo: roleStr)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => StaffMember.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching staff by role: $e');
      return [];
    }
  }

  /// Get current staff member
  Stream<StaffMember?> getCurrentStaffStream() {
    // In a real app, you would get the current user ID from Firebase Auth
    // For this example, we'll use a mock ID
    const currentStaffId = 'current_staff_id';

    return _firestore
        .collection('staff')
        .doc(currentStaffId)
        .snapshots()
        .map((doc) => doc.exists ? StaffMember.fromFirestore(doc) : null);
  }

  // ===== TOKEN MANAGEMENT =====

  /// Get user token with claims
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } on FirebaseAuthException catch (e) {
      debugPrint('Error getting token: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Check if user has specific claim
  Future<bool> hasUserClaim(String claim) async {
    try {
      final idTokenResult = await _auth.currentUser?.getIdTokenResult(true);
      return idTokenResult?.claims?[claim] == true;
    } catch (e) {
      debugPrint('Error checking user claim: $e');
      return false;
    }
  }

  // ===== INITIALIZATION =====

  /// Initialize authentication and handle existing sessions
  Future<User?> initialize() async {
    if (_auth.currentUser == null) {
      return await signInAnonymously();
    } else if (_auth.currentUser!.isAnonymous) {
      debugPrint('User is signed in anonymously: ${_auth.currentUser!.uid}');
      return _auth.currentUser;
    } else {
      debugPrint('User is signed in: ${_auth.currentUser!.uid}');
      return _auth.currentUser;
    }
  }
}

/// Model class for app user
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final Map<String, dynamic> metadata;
  final List<String> roles;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.metadata = const {},
    this.roles = const [],
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;

  @override
  String toString() => 'AppUser(uid: $uid, email: $email)';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      metadata: data['metadata'] ?? {},
      roles: List<String>.from(data['roles'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'metadata': metadata,
      'roles': roles,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }
}

/// Model class for staff member
class StaffMember {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.metadata,
  });

  factory StaffMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StaffMember(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _parseStaffRole(data['role']),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'],
    );
  }

  static StaffRole _parseStaffRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'waiter':
        return StaffRole.waiter;
      case 'chef':
        return StaffRole.chef;
      case 'manager':
        return StaffRole.manager;
      case 'cashier':
        return StaffRole.cashier;
      default:
        return StaffRole.staff;
    }
  }
}

/// Enum for staff roles
enum StaffRole {
  waiter,
  chef,
  manager,
  cashier,
  staff,
}

/// Admin user model
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

  factory AdminUser.fromMap(String uid, Map<String, dynamic> data) {
    return AdminUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'],
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
