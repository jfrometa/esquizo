import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : 
    _auth = auth ?? FirebaseAuth.instance,
    _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }
  
  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
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
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
  
  // Stream user data for real-time updates
  Stream<AppUser?> streamUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return AppUser.fromFirestore(doc);
          }
          return null;
        });
  }
  
  // Update user profile
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
      print('Error updating user profile: $e');
      throw e;
    }
  }
  
  // Update user metadata
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
      print('Error updating user metadata: $e');
      throw e;
    }}
}