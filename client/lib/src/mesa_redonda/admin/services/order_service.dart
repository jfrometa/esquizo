
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_status.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AdminOrder>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminOrder.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus.name});
  }

  Future<void> confirmPayment(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.paymentConfirmed.name,
      'paymentConfirmedAt': FieldValue.serverTimestamp(),
    });
  }
}

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
