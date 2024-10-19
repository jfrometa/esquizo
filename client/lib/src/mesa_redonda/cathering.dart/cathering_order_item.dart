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

  // Add the copyWith method
  CateringDish copyWith({
    String? title,
    int? peopleCount,
    double? pricePerPerson,
    List<String>? ingredients,
  }) {
    return CateringDish(
      title: title ?? this.title,
      peopleCount: peopleCount ?? this.peopleCount,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      ingredients: ingredients ?? this.ingredients,
    );
  }

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
  final int cantidadPersonas; // Add cantidadPersonas field

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
    required this.cantidadPersonas, // Initialize in the constructor
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
        'cantidadPersonas':
            cantidadPersonas, // Include cantidadPersonas in JSON
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
      cantidadPersonas:
          json['cantidadPersonas'] ?? 10, // Default if not present
    );
  }

  // Add the copyWith method to include cantidadPersonas
  CateringOrderItem copyWith({
    String? title,
    String? img,
    String? description,
    List<CateringDish>? dishes,
    String? apetito,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? cantidadPersonas,
  }) {
    return CateringOrderItem(
      title: title ?? this.title,
      img: img ?? this.img,
      description: description ?? this.description,
      dishes: dishes ?? this.dishes,
      apetito: apetito ?? this.apetito,
      alergias: alergias ?? this.alergias,
      eventType: eventType ?? this.eventType,
      preferencia: preferencia ?? this.preferencia,
      adicionales: adicionales ?? this.adicionales,
      cantidadPersonas: cantidadPersonas ?? this.cantidadPersonas,
    );
  }
}

// State notifier for managing catering orders with persistence
// State notifier for managing catering orders with persistence
class CateringOrderNotifier extends StateNotifier<CateringOrderItem?> {
  Timer? _saveDebounce;

  CateringOrderNotifier() : super(null) {
    _loadCateringOrder();
  }

  // Load catering order from SharedPreferences
  Future<void> _loadCateringOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedOrder = prefs.getString('cateringOrder');
    if (serializedOrder != null) {
      state = CateringOrderItem.fromJson(jsonDecode(serializedOrder));
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

  @override
  set state(CateringOrderItem? value) {
    super.state = value;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveCateringOrder();
    });
  }

  // Add a new dish to the active order
  void addCateringItem(CateringDish dish) {
    if (state == null) {
      // Create a new order with default values
      state = CateringOrderItem(
        title: '',
        img: '',
        description: '',
        dishes: [dish],
        apetito: '',
        alergias: '',
        eventType: '',
        preferencia: '',
        adicionales: '',
        cantidadPersonas: 10,
      );
    } else {
      // Add to existing order
      state = state!.copyWith(
        dishes: [...state!.dishes, dish],
      );
    }
  }

  // Update the order detailsvoid
  finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required String apetito,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    required int cantidadPersonas, // Add cantidadPersonas
  }) {
    if (state != null) {
      state = state!.copyWith(
        title: title,
        img: img,
        description: description,
        apetito: apetito,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        cantidadPersonas: cantidadPersonas, // Update cantidadPersonas
      );
    }
  }

  // Update a specific dish by index
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null && index >= 0 && index < state!.dishes.length) {
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
    if (state != null && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes)
        ..removeAt(index); // Remove dish at the specified index

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
// Serialization and Deserialization for CateringOrderItems
String serializeCateringOrders(List<CateringOrderItem> orders) {
  return jsonEncode(orders.map((order) => order.toJson()).toList());
}

List<CateringOrderItem> deserializeCateringOrders(String jsonString) {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((order) => CateringOrderItem.fromJson(order)).toList();
}
