import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';


/// State notifier for managing catering orders with persistence.
class CateringOrderNotifier extends StateNotifier<CateringOrderItem?> {
  Timer? _saveDebounce;

  CateringOrderNotifier() : super(null) {
    _loadCateringOrder();
  }

  // Load catering order from SharedPreferences.
  Future<void> _loadCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrder = prefs.getString('cateringOrder');
    if (serializedOrder != null) {
      state = CateringOrderItem.fromJson(jsonDecode(serializedOrder));
    }
  }

  // Save catering order to SharedPreferences.
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

 void updateOrder(CateringOrderItem order) {
    state = order;
  }

  /// Add a new dish to the active order.
  void addCateringItem(CateringDish dish) {
    if (state == null) {
      // Create a new order with default values.
      state = CateringOrderItem(
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
    } else {
      // Check if dish already exists (comparing by title).
      bool dishExists =
          state!.dishes.any((existingDish) => existingDish.title == dish.title);

      if (!dishExists) {
        // Only add if the dish doesn't exist.
        state = state!.copyWith(
          dishes: [...state!.dishes, dish],
        );
      }
    }
  }

  /// Update or finalize the order details.
  /// An optional [isQuote] flag can be provided to mark the order as a manual quote.
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
    if (state != null) {
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
      // Create a new order with the provided details.
      state = CateringOrderItem(
        title: title,
        img: img,
        description: description,
        dishes: [],
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

  /// Update a specific dish by index.
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish; // Update dish at the specified index.
      state = state!.copyWith(
        dishes: updatedDishes,
      );
    }
  }

  /// Clear the active order.
  void clearCateringOrder() {
    state = null;
  }

  /// Remove a specific dish from the order by index.
  void removeFromCart(int index) {
    if (state != null && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes)
        ..removeAt(index); // Remove dish at the specified index.
      state = state!.copyWith(
        dishes: updatedDishes,
      );
    }
  }
}

final cateringOrderProvider =
    StateNotifierProvider<CateringOrderNotifier, CateringOrderItem?>((ref) {
  return CateringOrderNotifier();
});

/// Serialization and Deserialization for CateringOrderItems.
String serializeCateringOrders(List<CateringOrderItem> orders) {
  return jsonEncode(orders.map((order) => order.toJson()).toList());
}

List<CateringOrderItem> deserializeCateringOrders(String jsonString) {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((order) => CateringOrderItem.fromJson(order)).toList();
}