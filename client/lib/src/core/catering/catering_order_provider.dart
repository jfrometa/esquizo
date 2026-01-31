import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'
    as model;
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'
    show CateringOrderStatus;

part 'catering_order_provider.g.dart';

@Riverpod(keepAlive: true)
class CateringOrderNotifier extends _$CateringOrderNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _saveDebounce;

  @override
  model.CateringOrderItem? build() {
    _loadCateringOrder();
    // Disposal of timer on provider disposal
    ref.onDispose(() {
      _saveDebounce?.cancel();
    });
    return null;
  }

  // Set state and debounce save
  void _updateState(model.CateringOrderItem? newState) {
    state = newState;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCateringOrder();
    });
  }

  // Load catering order from SharedPreferences
  Future<void> _loadCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrder = prefs.getString('cateringOrder');
    if (serializedOrder != null && serializedOrder.isNotEmpty) {
      try {
        state = model.CateringOrderItem.fromJson(jsonDecode(serializedOrder));
      } catch (e) {
        debugPrint('Error deserializing catering order: $e');
        state = null;
      }
    } else {
      state = null;
    }
  }

  // Save catering order to SharedPreferences
  Future<void> _saveCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      await prefs.setString('cateringOrder', jsonEncode(state!.toJson()));
    } else {
      await prefs.remove('cateringOrder');
    }
  }

  // Update the current order
  void updateOrder(model.CateringOrderItem order) {
    _updateState(order);
  }

  // Add a new dish to the active order
  void addCateringItem(model.CateringDish dish) {
    if (state == null) {
      _updateState(model.CateringOrderItem.legacy(
        title: '',
        img: '',
        description: '',
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: 'salado',
        adicionales: '',
        peopleCount: 0,
        isQuote: false,
      ));
    } else if (state!.isLegacyItem) {
      bool dishExists =
          state!.dishes.any((existingDish) => existingDish.title == dish.title);

      if (!dishExists) {
        _updateState(state!.copyWith(
          dishes: [...state!.dishes, dish],
        ));
      }
    } else {
      final legacyItem = model.CateringOrderItem.legacy(
        title: state!.name,
        img: '',
        description: state!.notes,
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: 'salado',
        adicionales: '',
        peopleCount: 0,
        isQuote: false,
      );
      _updateState(legacyItem);
    }
  }

  void finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required bool hasChef,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    required int cantidadPersonas,
    bool isQuote = false,
  }) {
    if (state != null && state!.isLegacyItem) {
      _updateState(state!.copyWith(
        title: title,
        img: img,
        description: description,
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        peopleCount: cantidadPersonas,
        isQuote: isQuote,
      ));
    } else {
      _updateState(model.CateringOrderItem.legacy(
        title: title,
        img: img,
        description: description,
        dishes: state?.dishes ?? [],
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        peopleCount: cantidadPersonas,
        isQuote: isQuote,
      ));
    }
  }

  void updateDish(int index, model.CateringDish updatedDish) {
    if (state != null &&
        state!.isLegacyItem &&
        index >= 0 &&
        index < state!.dishes.length) {
      final updatedDishes = List<model.CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish;
      _updateState(state!.copyWith(
        dishes: updatedDishes,
      ));
    }
  }

  void clearCateringOrder() {
    _updateState(null);
  }

  void removeFromCart(int index) {
    if (state != null &&
        state!.isLegacyItem &&
        index >= 0 &&
        index < state!.dishes.length) {
      final updatedDishes = List<model.CateringDish>.from(state!.dishes)
        ..removeAt(index);
      _updateState(state!.copyWith(
        dishes: updatedDishes,
      ));
    }
  }

  // Firestore Operations
  model.CateringOrder _convertToFirestoreOrder(model.CateringOrderItem item,
      {required String userId,
      required DateTime eventDate,
      String? customerName}) {
    return model.CateringOrder.fromLegacyItem(
      item,
      customerId: userId,
      customerName: customerName,
      eventDate: eventDate,
    );
  }

  Future<String?> submitCurrentOrder({
    required String userId,
    required DateTime eventDate,
    String? customerName,
  }) async {
    if (state == null || !state!.isLegacyItem || state!.dishes.isEmpty) {
      return null;
    }

    final order = _convertToFirestoreOrder(
      state!,
      userId: userId,
      eventDate: eventDate,
      customerName: customerName,
    );

    final orderData = order.toJson();
    orderData.remove('id');
    if (!orderData.containsKey('businessId') ||
        orderData['businessId'].isEmpty) {
      debugPrint('Warning: Business ID not set in catering order');
    }

    final docRef = await _firestore.collection('cateringOrders').add(orderData);
    clearCateringOrder();
    return docRef.id;
  }

  Future<model.CateringOrder> getOrder(String id) async {
    final doc = await _firestore.collection('cateringOrders').doc(id).get();
    return model.CateringOrder.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  Stream<model.CateringOrder> streamOrder(String orderId) {
    return _firestore
        .collection('cateringOrders')
        .doc(orderId)
        .snapshots()
        .map((doc) => model.CateringOrder.fromJson({
              'id': doc.id,
              ...doc.data()!,
            }));
  }

  Stream<List<model.CateringOrder>> getUpcomingOrders() {
    final now = DateTime.now();
    return _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: now)
        .where('status', whereNotIn: [
          model.CateringOrderStatus.cancelled.name,
          model.CateringOrderStatus.refunded.name,
          model.CateringOrderStatus.completed.name,
        ])
        .orderBy('eventDate')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<model.CateringOrder>> getTodayOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: today)
        .where('eventDate', isLessThan: tomorrow)
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<model.CateringOrder>> getOrdersByStatus(
      model.CateringOrderStatus status) {
    return _firestore
        .collection('cateringOrders')
        .where('status', isEqualTo: status.name)
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<model.CateringOrder>> getUserOrders(String userId) {
    return _firestore
        .collection('cateringOrders')
        .where('customerId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<model.CateringOrder>> getAllOrders() {
    return _firestore
        .collection('cateringOrders')
        .orderBy('eventDate', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<void> updateFirestoreOrder(model.CateringOrder order) async {
    await _firestore
        .collection('cateringOrders')
        .doc(order.id)
        .update(order.toJson()..remove('id'));
  }

  Future<void> updateOrderStatus(
      String id, model.CateringOrderStatus status) async {
    await _firestore.collection('cateringOrders').doc(id).update({
      'status': status.name,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignStaff(
      String orderId, String staffId, String staffName) async {
    await _firestore.collection('cateringOrders').doc(orderId).update({
      'assignedStaffId': staffId,
      'assignedStaffName': staffName,
    });
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus,
      [String? paymentId]) async {
    final data = {'paymentStatus': paymentStatus};

    if (paymentId != null) {
      data['paymentId'] = paymentId;
    }

    await _firestore.collection('cateringOrders').doc(orderId).update(data);
  }

  Future<void> cancelOrder(String id, String reason) async {
    await _firestore.collection('cateringOrders').doc(id).update({
      'status': model.CateringOrderStatus.cancelled.name,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
      'cancellationReason': reason,
    });
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final orderQuerySnapshot =
        await _firestore.collection('cateringOrders').get();

    final orders = orderQuerySnapshot.docs
        .map((doc) => model.CateringOrder.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();

    final totalOrders = orders.length;
    final upcomingOrders = orders
        .where((order) =>
            order.eventDate.isAfter(now) == true && !order.status.isTerminal)
        .length;
    final todayOrders = orders
        .where((order) =>
            order.eventDate.isAfter(today) == true &&
            order.eventDate.isBefore(today.add(const Duration(days: 1))) ==
                true)
        .length;
    final thisWeekOrders = orders
        .where((order) =>
            order.eventDate.isAfter(startOfWeek) == true &&
            order.eventDate
                    .isBefore(startOfWeek.add(const Duration(days: 7))) ==
                true)
        .length;
    final thisMonthOrders = orders
        .where((order) =>
            order.eventDate.isAfter(startOfMonth) == true &&
            order.eventDate.isBefore(DateTime(now.year, now.month + 1, 1)) ==
                true)
        .length;

    final totalRevenue =
        orders.fold(0.0, (total, order) => total + order.total);
    final todayRevenue = orders
        .where((order) =>
            order.eventDate.isAfter(today) == true &&
            order.eventDate.isBefore(today.add(const Duration(days: 1))) ==
                true)
        .fold(0.0, (total, order) => total + order.total);
    final thisWeekRevenue = orders
        .where((order) =>
            order.eventDate.isAfter(startOfWeek) == true &&
            order.eventDate
                    .isBefore(startOfWeek.add(const Duration(days: 7))) ==
                true)
        .fold(0.0, (total, order) => total + order.total);
    final thisMonthRevenue = orders
        .where((order) =>
            order.eventDate.isAfter(startOfMonth) == true &&
            order.eventDate.isBefore(DateTime(now.year, now.month + 1, 1)) ==
                true)
        .fold(0.0, (total, order) => total + order.total);

    final Map<String, int> statusCounts = {};
    for (final status in model.CateringOrderStatus.values) {
      statusCounts[status.name] =
          orders.where((order) => order.status == status).length;
    }

    return {
      'totalOrders': totalOrders,
      'upcomingOrders': upcomingOrders,
      'todayOrders': todayOrders,
      'thisWeekOrders': thisWeekOrders,
      'thisMonthOrders': thisMonthOrders,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'thisWeekRevenue': thisWeekRevenue,
      'thisMonthRevenue': thisMonthRevenue,
      'statusCounts': statusCounts,
    };
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingEvents = await _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: today)
        .where('status', whereNotIn: [
          model.CateringOrderStatus.cancelled.name,
          model.CateringOrderStatus.refunded.name,
        ])
        .orderBy('eventDate')
        .limit(5)
        .get();

    final recentOrders = await _firestore
        .collection('cateringOrders')
        .orderBy('orderDate', descending: true)
        .limit(5)
        .get();

    final pendingConfirmation = await _firestore
        .collection('cateringOrders')
        .where('status', isEqualTo: model.CateringOrderStatus.pending.name)
        .count()
        .get();

    final readyForDelivery = await _firestore
        .collection('cateringOrders')
        .where('status',
            isEqualTo: model.CateringOrderStatus.readyForDelivery.name)
        .count()
        .get();

    final todayEvents = await _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: today)
        .where('eventDate', isLessThan: today.add(const Duration(days: 1)))
        .count()
        .get();

    return {
      'upcomingEvents': upcomingEvents.docs
          .map((doc) =>
              model.CateringOrder.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
      'recentOrders': recentOrders.docs
          .map((doc) =>
              model.CateringOrder.fromJson({'id': doc.id, ...doc.data()}))
          .toList(),
      'pendingConfirmation': pendingConfirmation.count,
      'readyForDelivery': readyForDelivery.count,
      'todayEvents': todayEvents.count,
    };
  }
}

// Convenience providers
@Riverpod(keepAlive: true)
Stream<List<model.CateringOrder>> upcomingCateringOrders(Ref ref) {
  return ref.watch(cateringOrderNotifierProvider.notifier).getUpcomingOrders();
}

@Riverpod(keepAlive: true)
Stream<List<model.CateringOrder>> allCateringOrders(Ref ref) {
  return ref.watch(cateringOrderNotifierProvider.notifier).getAllOrders();
}

@Riverpod(keepAlive: true)
Stream<List<model.CateringOrder>> todayCateringOrders(Ref ref) {
  return ref.watch(cateringOrderNotifierProvider.notifier).getTodayOrders();
}

@riverpod
Stream<List<model.CateringOrder>> ordersByStatus(
    Ref ref, model.CateringOrderStatus status) {
  return ref
      .watch(cateringOrderNotifierProvider.notifier)
      .getOrdersByStatus(status);
}

@riverpod
Stream<List<model.CateringOrder>> userCateringOrders(Ref ref, String userId) {
  return ref
      .watch(cateringOrderNotifierProvider.notifier)
      .getUserOrders(userId);
}

@riverpod
Stream<model.CateringOrder> cateringOrderStream(Ref ref, String orderId) {
  return ref.watch(cateringOrderNotifierProvider.notifier).streamOrder(orderId);
}

@riverpod
Future<model.CateringOrder> cateringOrderStatistics(Ref ref) async {
  final stats =
      await ref.watch(cateringOrderNotifierProvider.notifier).getStatistics();
  return model.CateringOrder.fromStatistics(stats);
}

@riverpod
Future<Map<String, dynamic>> cateringDashboardSummary(Ref ref) async {
  return ref
      .watch(cateringOrderNotifierProvider.notifier)
      .getDashboardSummary();
}
