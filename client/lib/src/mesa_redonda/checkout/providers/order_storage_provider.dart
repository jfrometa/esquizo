import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';

final orderStorageProvider = Provider((ref) => OrderStorageService());

class OrderStorageService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anon';
  String _getEmail(Map<String, String>? contactInfo) =>
      _auth.currentUser?.email ?? contactInfo?['email'] ?? '';

  Future<void> saveRegularOrder(
    List<CartItem> items,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
  ) async {
    final orderDate = DateTime.now();
    final email = _getEmail(contactInfo);

    for (var item in items) {
      final double price = double.tryParse(item.pricing) ?? 0.0;
      final int quantity = item.quantity;

      final orderData = {
        'email': email,
        'userId': _userId,
        'orderType': item.foodType ?? 'Unknown',
        'status': 'pending',
        'orderDate': orderDate.toIso8601String(),
        'location': location,
        'deliveryDate': delivery['date'],
        'deliveryTime': delivery['time'],
        'items': [item.toJson()],
        'paymentMethod': paymentMethod,
        'totalAmount': price * quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('orders').add(orderData);
    }
  }

  Future<void> saveSubscription(
    List<CartItem> items,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
  ) async {
    final orderDate = DateTime.now();
    final email = _getEmail(contactInfo);

    for (var item in items) {
      final double price = double.tryParse(item.pricing) ?? 0.0;
      final int quantity = item.quantity;

      final orderData = {
        'email': email,
        'userId': _userId,
        'orderType': 'Subscription',
        'status': 'pending',
        'orderDate': orderDate.toIso8601String(),
        'location': location,
        'deliveryDate': delivery['date'],
        'deliveryTime': delivery['time'],
        'items': [item.toJson()],
        'paymentMethod': paymentMethod,
        'totalAmount': price * quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      final orderRef = await _firestore.collection('orders').add(orderData);

      final subscriptionData = {
        'email': email,
        'userId': _userId,
        'planName': item.title,
        'status': 'active',
        'startDate': orderDate.toIso8601String(),
        'endDate': null,
        'totalMeals': quantity,
        'consumedMeals': 0,
        'remainingMeals': quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      final subscriptionRef = await _firestore.collection('subscriptions').add(subscriptionData);

      await _createMeals(quantity, item.title, orderDate, subscriptionRef.id);
    }
  }

  Future<void> saveCateringOrder(
    CateringOrderItem order,
    Map<String, String>? contactInfo,
    String paymentMethod,
    Map<String, String> location,
    Map<String, String> delivery,
  ) async {
    final orderDate = DateTime.now();
    final email = _getEmail(contactInfo);

    final orderData = {
      'email': email,
      'userId': _userId,
      'orderType': 'Catering',
      'status': 'pending',
      'orderDate': orderDate.toIso8601String(),
      'location': location,
      'deliveryDate': delivery['date'],
      'deliveryTime': delivery['time'],
      'items': order.dishes.map((dish) => dish.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'totalAmount': order.totalPrice ?? 0.0,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('orders').add(orderData);
  }

  Future<void> _createMeals(
    int quantity,
    String planName,
    DateTime orderDate,
    String subscriptionId,
  ) async {
    for (int i = 0; i < quantity; i++) {
      final mealData = {
        'userId': _userId,
        'subscriptionId': subscriptionId,
        'subscriptionPlan': planName,
        'status': 'unconsumed',
        'orderDate': orderDate.toIso8601String(),
        'mealNumber': i + 1,
        'totalMeals': quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('meals').add(mealData);
    }
  }
}