
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';

/// Unified provider for both admin and user catering orders
class CateringOrderProvider extends StateNotifier<CateringOrderItem?> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _saveDebounce;

  CateringOrderProvider() : super(null) {
    _loadCateringOrder();
  }
  
  // SECTION: Local State Management (SharedPreferences)
  
  // Load catering order from SharedPreferences
  Future<void> _loadCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrder = prefs.getString('cateringOrder') ?? "";
    state = CateringOrderItem.fromJson(jsonDecode(serializedOrder));
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

  @override
  set state(CateringOrderItem? value) {
    super.state = value;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCateringOrder();
    });
  }

  // SECTION: Cart Management (Uses Legacy CateringOrderItem)

  // Update the current order
  void updateOrder(CateringOrderItem order) {
    state = order;
  }

  // Add a new dish to the active order
  void addCateringItem(CateringDish dish) {
    if (state == null) {
      // Create a new order with default values
      state = CateringOrderItem.legacy(
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
      );
    } else if (state!.isLegacyItem) {
      // Handle legacy mode - check if dish already exists (comparing by title)
      bool dishExists =
          state!.dishes.any((existingDish) => existingDish.title == dish.title);

      if (!dishExists) {
        // Only add if the dish doesn't exist
        state = state!.copyWith(
          dishes: [...state!.dishes, dish],
        );
      }
    } else {
      // Handle modern mode - convert the current order to legacy first
      final legacyItem = CateringOrderItem.legacy(
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
      state = legacyItem;
    }
  }

  // Update or finalize the order details
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
      // Update existing legacy order
      state = state!.copyWith(
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
      );
    } else {
      // Create a new legacy order
      state = CateringOrderItem.legacy(
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
      );
    }
  }

  // Update a specific dish by index
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null && state!.isLegacyItem && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish; // Update dish at the specified index
      state = state!.copyWith(
        dishes: updatedDishes,
      );
    }
  }

  // Clear the active order
  void clearCateringOrder() {
    state = null;
  }

  // Remove a specific dish from the order by index
  void removeFromCart(int index) {
    if (state != null && state!.isLegacyItem && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes)
        ..removeAt(index); // Remove dish at the specified index
      state = state!.copyWith(
        dishes: updatedDishes,
      );
    }
  }

  // SECTION: Firestore Operations

  // Convert CateringOrderItem to CateringOrder for Firestore
  CateringOrder _convertToFirestoreOrder(
    CateringOrderItem item, 
    {required String userId, required DateTime eventDate, String? customerName}
  ) {
    return CateringOrder.fromLegacyItem(
      item,
      customerId: userId,
      customerName: customerName,
      eventDate: eventDate,
    );
  }

  // Submit current cart/order to Firestore
  Future<String?> submitCurrentOrder({
    required String userId, 
    required DateTime eventDate,
    String? customerName,
  }) async {
    if (state == null || !state!.isLegacyItem || state!.dishes.isEmpty) {
      return null; // Nothing to submit
    }
    
    // Convert local state to Firestore model
    final order = _convertToFirestoreOrder(
      state!, 
      userId: userId, 
      eventDate: eventDate,
      customerName: customerName,
    );
    
    // Save to Firestore
    final docRef = await _firestore.collection('cateringOrders').add(order.toJson()..remove('id'));
    
    // Optionally clear the cart after submission
    clearCateringOrder();
    
    return docRef.id;
  }

  // Get a specific order from Firestore
  Future<CateringOrder> getOrder(String id) async {
    final doc = await _firestore.collection('cateringOrders').doc(id).get();
    return CateringOrder.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  // Stream a specific order
  Stream<CateringOrder> streamOrder(String orderId) {
    return _firestore
        .collection('cateringOrders')
        .doc(orderId)
        .snapshots()
        .map((doc) => CateringOrder.fromJson({
              'id': doc.id,
              ...doc.data()!,
            }));
  }

  // Get all catering orders (admin)
  Stream<List<CateringOrder>> getAllOrders() {
    return _firestore
        .collection('cateringOrders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }
  
  // Get orders for a specific user
  Stream<List<CateringOrder>> getUserOrders(String userId) {
    return _firestore
        .collection('cateringOrders')
        .where('customerId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Update an existing order
  Future<void> updateFirestoreOrder(CateringOrder order) async {
    await _firestore
        .collection('cateringOrders')
        .doc(order.id)
        .update(order.toJson()..remove('id'));
  }

  // Update order status
  Future<void> updateOrderStatus(String id, CateringOrderStatus status) async {
    await _firestore.collection('cateringOrders').doc(id).update({
      'status': status.name,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
    });
  }

  // Assign staff to an order
  Future<void> assignStaff(String orderId, String staffId, String staffName) async {
    await _firestore.collection('cateringOrders').doc(orderId).update({
      'assignedStaffId': staffId,
      'assignedStaffName': staffName,
    });
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus, [String? paymentId]) async {
    final data = {'paymentStatus': paymentStatus};
    
    if (paymentId != null) {
      data['paymentId'] = paymentId;
    }
    
    await _firestore.collection('cateringOrders').doc(orderId).update(data);
  }

  // Cancel an order
  Future<void> cancelOrder(String id, String reason) async {
    await _firestore.collection('cateringOrders').doc(id).update({
      'status': CateringOrderStatus.cancelled.name,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
      'cancellationReason': reason,
    });
  }

  // SECTION: Specialized Queries (Admin)

  // Get upcoming orders
  Stream<List<CateringOrder>> getUpcomingOrders() {
    final now = DateTime.now();
    return _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: now)
        .where('status', whereNotIn: [
          CateringOrderStatus.cancelled.name,
          CateringOrderStatus.refunded.name,
          CateringOrderStatus.completed.name,
        ])
        .orderBy('eventDate')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Get today's orders
  Stream<List<CateringOrder>> getTodayOrders() {
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
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Get orders by status
  Stream<List<CateringOrder>> getOrdersByStatus(CateringOrderStatus status) {
    return _firestore
        .collection('cateringOrders')
        .where('status', isEqualTo: status.name)
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CateringOrder.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getStatistics() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final orderQuerySnapshot = await _firestore
        .collection('cateringOrders')
        .get();
    
    final orders = orderQuerySnapshot.docs
        .map((doc) => CateringOrder.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
    
    // Total orders
    final totalOrders = orders.length;
    
    // Upcoming orders
    final upcomingOrders = orders.where((order) => 
        order.eventDate.isAfter(now) && 
        !order.status.isTerminal
    ).length;
    
    // Today's orders
    final todayOrders = orders.where((order) => 
        order.eventDate.isAfter(today) && 
        order.eventDate.isBefore(today.add(const Duration(days: 1)))
    ).length;
    
    // This week's orders
    final thisWeekOrders = orders.where((order) => 
        order.eventDate.isAfter(startOfWeek) && 
        order.eventDate.isBefore(startOfWeek.add(const Duration(days: 7)))
    ).length;
    
    // This month's orders
    final thisMonthOrders = orders.where((order) => 
        order.eventDate.isAfter(startOfMonth) && 
        order.eventDate.isBefore(DateTime(now.year, now.month + 1, 1))
    ).length;
    
    // Revenue calculations
    final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.total);
    
    final todayRevenue = orders
        .where((order) => 
            order.eventDate.isAfter(today) && 
            order.eventDate.isBefore(today.add(const Duration(days: 1))))
        .fold(0.0, (sum, order) => sum + order.total);
    
    final thisWeekRevenue = orders
        .where((order) => 
            order.eventDate.isAfter(startOfWeek) && 
            order.eventDate.isBefore(startOfWeek.add(const Duration(days: 7))))
        .fold(0.0, (sum, order) => sum + order.total);
    
    final thisMonthRevenue = orders
        .where((order) => 
            order.eventDate.isAfter(startOfMonth) && 
            order.eventDate.isBefore(DateTime(now.year, now.month + 1, 1)))
        .fold(0.0, (sum, order) => sum + order.total);
    
    // Status breakdown
    final Map<String, int> statusCounts = {};
    for (final status in CateringOrderStatus.values) {
      statusCounts[status.name] = orders
          .where((order) => order.status == status)
          .length;
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

  // Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final upcomingEvents = await _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: today)
        .where('status', whereNotIn: [
          CateringOrderStatus.cancelled.name,
          CateringOrderStatus.refunded.name,
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
        .where('status', isEqualTo: CateringOrderStatus.pending.name)
        .count()
        .get();
    
    final readyForDelivery = await _firestore
        .collection('cateringOrders')
        .where('status', isEqualTo: CateringOrderStatus.readyForDelivery.name)
        .count()
        .get();
    
    final todayEvents = await _firestore
        .collection('cateringOrders')
        .where('eventDate', isGreaterThanOrEqualTo: today)
        .where('eventDate', isLessThan: today.add(const Duration(days: 1)))
        .count()
        .get();
    
    return {
      'upcomingEvents': upcomingEvents.docs.map((doc) => 
          CateringOrder.fromJson({'id': doc.id, ...doc.data()})
      ).toList(),
      'recentOrders': recentOrders.docs.map((doc) => 
          CateringOrder.fromJson({'id': doc.id, ...doc.data()})
      ).toList(),
      'pendingConfirmation': pendingConfirmation.count,
      'readyForDelivery': readyForDelivery.count,
      'todayEvents': todayEvents.count,
    };
  }
}

// Main provider for accessing the CateringOrderProvider
final cateringOrderProvider =
    StateNotifierProvider<CateringOrderProvider, CateringOrderItem?>((ref) {
  return CateringOrderProvider();
});

// Convenience providers for common queries using StreamProvider
final upcomingCateringOrdersProvider = StreamProvider<List<CateringOrder>>((ref) {
  return ref.watch(cateringOrderProvider.notifier).getUpcomingOrders();
});

final todayCateringOrdersProvider = StreamProvider<List<CateringOrder>>((ref) {
  return ref.watch(cateringOrderProvider.notifier).getTodayOrders();
});

final ordersByStatusProvider = StreamProvider.family<List<CateringOrder>, CateringOrderStatus>((ref, status) {
  return ref.watch(cateringOrderProvider.notifier).getOrdersByStatus(status);
});

final userCateringOrdersProvider = Provider.family<Stream<List<CateringOrder>>, String>((ref, userId) {
  return ref.watch(cateringOrderProvider.notifier).getUserOrders(userId);
});

final cateringOrderStreamProvider = Provider.family<Stream<CateringOrder>, String>((ref, orderId) {
  return ref.watch(cateringOrderProvider.notifier).streamOrder(orderId);
});

// Direct stream provider that returns the raw Stream without wrapping in Provider
final rawCateringOrderStream = StreamProvider.family<CateringOrder, String>((ref, orderId) {
  return ref.watch(cateringOrderProvider.notifier).streamOrder(orderId);
});

// Update the return type from Map<String, dynamic> to CateringOrder
final cateringOrderStatisticsProvider = FutureProvider<CateringOrder>((ref) async {
  final stats = await ref.watch(cateringOrderProvider.notifier).getStatistics();
  // Convert the statistics map to a CateringOrder object
  return CateringOrder.fromStatistics(stats);
});

final cateringDashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(cateringOrderProvider.notifier).getDashboardSummary();
});