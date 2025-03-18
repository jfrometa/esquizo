import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Reservation {
  final String id;
  final String businessId;
  final String resourceId; // Could be tableId for restaurants, roomId for hotels, etc.
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final DateTime date;
  final String timeSlot;
  final int partySize;
  final String status; // confirmed, pending, cancelled
  final String specialRequests;
  final DateTime createdAt;
  
  Reservation({
    required this.id,
    required this.businessId,
    required this.resourceId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.date,
    required this.timeSlot,
    required this.partySize,
    required this.status,
    this.specialRequests = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      resourceId: data['resourceId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      partySize: data['partySize'] ?? 1,
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'resourceId': resourceId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'partySize': partySize,
      'status': status,
      'specialRequests': specialRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ReservationService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  
  ReservationService({
    FirebaseFirestore? firestore,
    required String businessId,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _businessId = businessId;
  
  // Collection reference
  CollectionReference get _reservationsCollection => 
      _firestore.collection('businesses').doc(_businessId).collection('reservations');
  
  // Create a new reservation
  Future<String> createReservation(Reservation reservation) async {
    try {
      // Check for conflicting reservations
      final conflictingReservations = await _reservationsCollection
          .where('resourceId', isEqualTo: reservation.resourceId)
          .where('date', isEqualTo: Timestamp.fromDate(reservation.date))
          .where('timeSlot', isEqualTo: reservation.timeSlot)
          .where('status', isNotEqualTo: 'cancelled')
          .get();
      
      if (conflictingReservations.docs.isNotEmpty) {
        throw Exception('This time slot is already reserved');
      }
      
      final docRef = await _reservationsCollection.add(reservation.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      rethrow;
    }
  }
  
  // Get reservations for a specific date
  Future<List<Reservation>> getReservationsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final snapshot = await _reservationsCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', isNotEqualTo: 'cancelled')
          .get();
      
      return snapshot.docs
          .map((doc) => Reservation.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
      return [];
    }
  }
  
  // Get reservations for a specific resource
  Stream<List<Reservation>> getReservationsForResource(String resourceId) {
    return _reservationsCollection
        .where('resourceId', isEqualTo: resourceId)
        .where('status', isNotEqualTo: 'cancelled')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc))
            .toList());
  }
  
  // Update reservation status
  Future<void> updateReservationStatus(String reservationId, String status) async {
    await _reservationsCollection.doc(reservationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get user reservations
  Stream<List<Reservation>> getUserReservations(String userId) {
    return _reservationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc))
            .toList());
  }
  
  // Get available time slots for a specific date and resource
  Future<List<String>> getAvailableTimeSlots(String resourceId, DateTime date) async {
    try {
      // Define all possible time slots
      final allTimeSlots = [
        '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', 
        '8:00 PM', '8:30 PM', '9:00 PM', '9:30 PM'
      ];
      
      // Get existing reservations for this date and resource
      final existingReservations = await getReservationsByDate(date);
      final bookedTimeSlots = existingReservations
          .where((res) => res.resourceId == resourceId)
          .map((res) => res.timeSlot)
          .toList();
      
      // Return available time slots
      return allTimeSlots.where((slot) => !bookedTimeSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint('Error getting available time slots: $e');
      return [];
    }
  }
}