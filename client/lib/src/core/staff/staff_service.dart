import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

// Staff Service Implementation with business relationship filtering
class StaffService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final String _businessId;

  StaffService(this._firestore, this._businessId);

  // Get staff members for the current business through business relationships
  Stream<List<StaffMember>> getBusinessStaffStream() {
    return _firestore
        .collection('business_relationships')
        .where('businessId', isEqualTo: _businessId)
        .where('role', whereIn: [
          'staff',
          'admin',
          'waiter',
          'cook',
          'supervisor',
          'cashier'
        ])
        .snapshots()
        .asyncMap((relationshipSnapshot) async {
          final List<StaffMember> staffMembers = [];

          for (final relationshipDoc in relationshipSnapshot.docs) {
            final userId = relationshipDoc.data()['userId'] as String;
            final role = relationshipDoc.data()['role'] as String;

            // Get user details from the users collection
            final userDoc =
                await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              // Convert to StaffMember with the role from the relationship
              final staffMember = StaffMember(
                id: userId,
                name: userData['displayName'] ?? userData['name'] ?? '',
                email: userData['email'] ?? '',
                role: _parseStaffRole(role),
                isActive: userData['isActive'] ?? true,
                metadata: userData['metadata'],
              );
              staffMembers.add(staffMember);
            }
          }

          return staffMembers;
        });
  }

  // Get current staff member (would typically use Firebase Auth)
  Stream<StaffMember?> getCurrentStaffStream() {
    // In a real app, you would get the current user ID from Firebase Auth
    // For this example, we'll use a mock ID
    const currentStaffId = 'current_staff_id';

    return _firestore
        .collection('business_relationships')
        .where('businessId', isEqualTo: _businessId)
        .where('userId', isEqualTo: currentStaffId)
        .snapshots()
        .asyncMap((relationshipSnapshot) async {
      if (relationshipSnapshot.docs.isEmpty) return null;

      final relationshipDoc = relationshipSnapshot.docs.first;
      final userId = relationshipDoc.data()['userId'] as String;
      final role = relationshipDoc.data()['role'] as String;

      // Get user details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return StaffMember(
        id: userId,
        name: userData['displayName'] ?? userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: _parseStaffRole(role),
        isActive: userData['isActive'] ?? true,
        metadata: userData['metadata'],
      );
    });
  }

  // Get staff by role for the current business
  Future<List<StaffMember>> getStaffByRole(StaffRole role) async {
    try {
      final roleStr = role.toString().split('.').last;
      final relationshipSnapshot = await _firestore
          .collection('business_relationships')
          .where('businessId', isEqualTo: _businessId)
          .where('role', isEqualTo: roleStr)
          .get();

      final List<StaffMember> staffMembers = [];

      for (final relationshipDoc in relationshipSnapshot.docs) {
        final userId = relationshipDoc.data()['userId'] as String;

        // Get user details
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final isActive = userData['isActive'] ?? true;

          if (isActive) {
            final staffMember = StaffMember(
              id: userId,
              name: userData['displayName'] ?? userData['name'] ?? '',
              email: userData['email'] ?? '',
              role: role,
              isActive: isActive,
              metadata: userData['metadata'],
            );
            staffMembers.add(staffMember);
          }
        }
      }

      return staffMembers;
    } catch (e) {
      print('Error fetching staff by role: $e');
      return [];
    }
  }

  // Helper method to parse staff role from string
  StaffRole _parseStaffRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return StaffRole.admin;
      case 'waiter':
        return StaffRole.waiter;
      case 'cook':
        return StaffRole.cook;
      case 'supervisor':
        return StaffRole.supervisor;
      case 'cashier':
        return StaffRole.cashier;
      default:
        return StaffRole.waiter; // Default role
    }
  }

  // Add staff member to business (create business relationship)
  Future<void> addStaffToBusiness(String userId, StaffRole role) async {
    try {
      await _firestore.collection('business_relationships').add({
        'businessId': _businessId,
        'userId': userId,
        'role': role.toString().split('.').last,
        'createdAt': CloudFireStore.FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      print('Error adding staff to business: $e');
      rethrow;
    }
  }

  // Remove staff member from business (delete business relationship)
  Future<void> removeStaffFromBusiness(String userId) async {
    try {
      final relationshipSnapshot = await _firestore
          .collection('business_relationships')
          .where('businessId', isEqualTo: _businessId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in relationshipSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing staff from business: $e');
      rethrow;
    }
  }

  // Update staff role in business
  Future<void> updateStaffRole(String userId, StaffRole newRole) async {
    try {
      final relationshipSnapshot = await _firestore
          .collection('business_relationships')
          .where('businessId', isEqualTo: _businessId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in relationshipSnapshot.docs) {
        await doc.reference.update({
          'role': newRole.toString().split('.').last,
          'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating staff role: $e');
      rethrow;
    }
  }
}

final staffServiceProvider = Provider<StaffService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return StaffService(firestore, businessId);
});
