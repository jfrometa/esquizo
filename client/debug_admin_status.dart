import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
    
    // Check current user
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    
    if (currentUser == null) {
      print('❌ No user is currently logged in');
      return;
    }
    
    print('👤 Current user: ${currentUser.uid}');
    print('📧 Current user email: ${currentUser.email}');
    
    // Check admin status using the service directly
    final adminService = UnifiedAdminService();
    final isAdmin = await adminService.isCurrentUserAdmin();
    
    print('🔐 Is admin from service: $isAdmin');
    
    // Check admin document in Firestore directly
    final firestore = FirebaseFirestore.instance;
    final adminDoc = await firestore.collection('admins').doc(currentUser.uid).get();
    print('📄 Admin document exists: ${adminDoc.exists}');
    
    if (adminDoc.exists) {
      print('📄 Admin document data: ${adminDoc.data()}');
    }
    
    // Check business relationships
    final businessRelationships = await firestore
        .collection('business_relationships')
        .where('userId', isEqualTo: currentUser.uid)
        .where('role', isEqualTo: 'owner')
        .get();
    
    print('🏢 Business owner relationships: ${businessRelationships.docs.length}');
    
    for (final doc in businessRelationships.docs) {
      print('🏢 Business relationship: ${doc.data()}');
    }
    
    // Check token claims
    try {
      final idTokenResult = await currentUser.getIdTokenResult(true);
      final isAdminClaim = idTokenResult.claims?['admin'] == true;
      print('🎫 Admin claim in token: $isAdminClaim');
      print('🎫 All claims: ${idTokenResult.claims}');
    } catch (e) {
      print('❌ Error getting token claims: $e');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
