import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/firebase/firebase_providers.dart';

// Staff Service Implementation
class StaffService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final CloudFireStore.CollectionReference _staffCollection;
  
  StaffService(this._firestore) : _staffCollection = _firestore.collection('staff');
  
  // Get current staff member (would typically use Firebase Auth)
  Stream<StaffMember?> getCurrentStaffStream() {
    // In a real app, you would get the current user ID from Firebase Auth
    // For this example, we'll use a mock ID
    const currentStaffId = 'current_staff_id';
    
    return _staffCollection
        .doc(currentStaffId)
        .snapshots()
        .map((doc) => doc.exists ? StaffMember.fromFirestore(doc) : null);
  }
  
  // Get staff by role
  Future<List<StaffMember>> getStaffByRole(StaffRole role) async {
    try {
      final roleStr = role.toString().split('.').last;
      final snapshot = await _staffCollection
          .where('role', isEqualTo: roleStr)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => StaffMember.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching staff by role: $e');
      return [];
    }
  }
}


final staffServiceProvider = Provider<StaffService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return StaffService(firestore);
});
