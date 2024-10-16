import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model representing an individual dish within the catering order
class CateringDish {
  final String title;
  final int peopleCount;
  final double pricePerPerson;
  final List<String> ingredients;

  CateringDish({
    required this.title,
    required this.peopleCount,
    required this.pricePerPerson,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'peopleCount': peopleCount,
        'pricePerPerson': pricePerPerson,
        'ingredients': ingredients,
      };

  factory CateringDish.fromJson(Map<String, dynamic> json) {
    return CateringDish(
      title: json['title'],
      peopleCount: json['peopleCount'],
      pricePerPerson: json['pricePerPerson'],
      ingredients: List<String>.from(json['ingredients']),
    );
  }
}

// Model for the overall catering order
class CateringOrderItem {
  final String title;
  final String img;
  final String description;
  final List<CateringDish> dishes;
  final String apetito;
  final String alergias;
  final String eventType;
  final String preferencia;
  final String adicionales;

  CateringOrderItem({
    required this.title,
    required this.img,
    required this.description,
    required this.dishes,
    required this.apetito,
    required this.alergias,
    required this.eventType,
    required this.preferencia,
    required this.adicionales,
  });

  // Calculates the total price for all dishes in the order
  double get totalPrice => dishes.fold(
      0, (total, dish) => total + (dish.pricePerPerson * dish.peopleCount));

  // Combines all ingredients from all dishes into a single list for display
  List<String> get combinedIngredients =>
      dishes.expand((dish) => dish.ingredients).toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'img': img,
        'description': description,
        'dishes': dishes.map((dish) => dish.toJson()).toList(),
        'apetito': apetito,
        'alergias': alergias,
        'eventType': eventType,
        'preferencia': preferencia,
        'adicionales': adicionales,
      };

  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      title: json['title'],
      img: json['img'],
      description: json['description'],
      dishes: (json['dishes'] as List)
          .map((dish) => CateringDish.fromJson(dish))
          .toList(),
      apetito: json['apetito'],
      alergias: json['alergias'],
      eventType: json['eventType'],
      preferencia: json['preferencia'],
      adicionales: json['adicionales'],
    );
  }
}

// State notifier for managing catering orders with persistence
class CateringOrderNotifier extends StateNotifier<List<CateringOrderItem>> {
  Timer? _saveDebounce;
 // Temporary storage for dishes before completing the order with form details
  final List<CateringDish> _pendingDishes = [];
  
  CateringOrderNotifier() : super([]) {
    _loadCateringOrders();
  }

  // Load catering orders from SharedPreferences
  Future<void> _loadCateringOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrders = prefs.getString('cateringOrders');
    if (serializedOrders != null) {
      state = deserializeCateringOrders(serializedOrders);
    }
  }

  // Save catering orders to SharedPreferences
  Future<void> _saveCateringOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String serializedOrders = serializeCateringOrders(state);
    await prefs.setString('cateringOrders', serializedOrders);
  }

  @override
  set state(List<CateringOrderItem> value) {
    super.state = value;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCateringOrders();
    });
  }

  // Add a new dish to the pending list
  void addCateringItem(CateringDish dish) {
    _pendingDishes.add(dish);
  }

  // Complete the catering order with form data and save it
  void finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required String apetito,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
  }) {
    if (_pendingDishes.isNotEmpty) {
      final newOrder = CateringOrderItem(
        title: title,
        img: img,
        description: description,
        dishes: List.from(_pendingDishes),
        apetito: apetito,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
      );

      state = [...state, newOrder];
      _pendingDishes.clear();
    }
  }

  // Clear all orders
  void clearCateringOrder() {
    state = [];
    _pendingDishes.clear();
  }

  // Remove a specific order from the catering list by index
  void removeFromCart(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state]..removeAt(index);
    }
  }
}

// Serialization and Deserialization for CateringOrderItems
String serializeCateringOrders(List<CateringOrderItem> orders) {
  return jsonEncode(orders.map((order) => order.toJson()).toList());
}

List<CateringOrderItem> deserializeCateringOrders(String jsonString) {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData
      .map((order) => CateringOrderItem.fromJson(order))
      .toList();
}

final cateringOrderProvider =
    StateNotifierProvider<CateringOrderNotifier, List<CateringOrderItem>>((ref) {
  return CateringOrderNotifier();
});