import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


// Admin user model with null safety improvements
class AdminUser {
  final String uid;
  final String email;
  final String role;
  final DateTime? createdAt;
  final String? createdBy;

  AdminUser({
    required this.uid,
    required this.email,
    required this.role,
    this.createdAt,
    this.createdBy,
  });

  factory AdminUser.fromMap(String uid, Map<String, dynamic> map) {
    // Handle potential null timestamp
    DateTime? createdDate;
    try {
      final timestamp = map['createdAt'];
      if (timestamp != null) {
        createdDate = (timestamp as Timestamp).toDate();
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
    }
    
    return AdminUser(
      uid: uid,
      email: map['email'] ?? 'No email',
      role: map['role'] ?? 'admin',
      createdAt: createdDate,
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
    };
  }
}
