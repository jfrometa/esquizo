import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String planName;
  final int mealsRemaining;

  Subscription({
    required this.id,
    required this.planName,
    required this.mealsRemaining,
  });

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      planName: data['planName'] ?? 'Unknown Plan',
      mealsRemaining: data['mealsRemaining'] ?? 0,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final double totalAmount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? 'Unknown',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class Sizes {
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
}
