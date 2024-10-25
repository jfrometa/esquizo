import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model representing an individual dish within the catering order
class CateringDish {
  final String title;
  final int peopleCount;
  final double pricePerPerson;
  final double? pricePerUnit;
  final List<String> ingredients;
  final double pricing;
  final int quantity; // Added quantity field with default value of 1
  final String img; // Added img field
  bool hasUnitSelection;

  CateringDish({
    required this.title,
    required this.peopleCount,
    required this.pricePerPerson,
    required this.ingredients,
    required this.pricing,
    this.hasUnitSelection = false,
    this.pricePerUnit, 
    this.img = 'assets/food5.jpeg', // Added default img value
    this.quantity = 1, // Default quantity to 1
  });

  // Add the copyWith method
  CateringDish copyWith({
    String? title,
    int? peopleCount,
    double? pricePerPerson,
    double? pricePerUnit,
    List<String>? ingredients,
    bool? hasUnitSelection,
    int? quantity, // Added quantity to copyWith
    String? img, // Added img to copyWith
  }) {
    return CateringDish(
      title: title ?? this.title,
      peopleCount: peopleCount ?? this.peopleCount,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      ingredients: ingredients ?? this.ingredients,
      pricing: pricing,
      img: img ?? this.img, // Added img to copyWith
      quantity: quantity ?? this.quantity,
      hasUnitSelection: hasUnitSelection ?? this.hasUnitSelection
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'peopleCount': peopleCount,
        'pricePerPerson': pricePerPerson,
        'ingredients': ingredients,
        'pricing': pricing,
        'pricePerUnit': pricePerUnit,
        'quantity': quantity, // Added quantity to JSON
        'img': img, // Added img to JSON
        'hasUnitSelection': hasUnitSelection
      };

  factory CateringDish.fromJson(Map<String, dynamic> json) {
    return CateringDish(
      title: json['title'],
      peopleCount: json['peopleCount'],
      pricePerPerson: json['pricePerPerson'],
      ingredients: List<String>.from(json['ingredients']),
      pricing: json['pricing'],
      pricePerUnit: json['pricePerUnit'],
      hasUnitSelection: json['hasUnitSelection'],
      quantity: json['quantity'], // Added quantity from JSON
      img: json['img'] ??
          'assets/food5.jpeg', // Added default img value from JSON
    );
  }
}

class CateringOrderItem {
  final String title;
  final String img;
  final String description;
  final List<CateringDish> dishes; 
  final String alergias;
  final String eventType;
  final String preferencia;
  final String adicionales;
  final int? peopleCount; // Add cantidadPersonas field 
  bool? hasChef;

  CateringOrderItem({
    required this.title,
    required this.img,
    required this.description,
    required this.dishes, 
    required this.alergias,
    required this.eventType,
    required this.preferencia,
    required this.adicionales,
    this.hasChef,
    required this.peopleCount, 
  });

  // Calculates the total price for all dishes in the order
  double get totalPrice => dishes.fold(
      0, (total, dish) => total + ((dish.pricePerUnit ?? 1) * (peopleCount ?? 1)));

  // Combines all ingredients from all dishes into a single list for display
  List<String> get combinedIngredients =>
      dishes.expand((dish) => dish.ingredients).toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'img': img,
        'description': description,
        'dishes': dishes.map((dish) => dish.toJson()).toList(),
        'hasChef': hasChef,
        'alergias': alergias,
        'eventType': eventType,
        'preferencia': preferencia,
        'adicionales': adicionales,
        'cantidadPersonas':
            peopleCount,
      };

  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      title: json['title'],
      img: json['img'],
      description: json['description'],
      dishes: (json['dishes'] as List)
          .map((dish) => CateringDish.fromJson(dish))
          .toList(),
      hasChef: json['hasChef'],
      alergias: json['alergias'],
      eventType: json['eventType'],
      preferencia: json['preferencia'],
      adicionales: json['adicionales'],
      peopleCount: json['cantidadPersonas'],  
    );
  }

  // Add the copyWith method to include cantidadPersonas
  CateringOrderItem copyWith({
    String? title,
    String? img,
    String? description,
    List<CateringDish>? dishes,
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? peopleCount,
    int? cantidadUnidades,
  }) {
    return CateringOrderItem(
      title: title ?? this.title,
      img: img ?? this.img,
      description: description ?? this.description,
      dishes: dishes ?? this.dishes,
      hasChef: hasChef ?? this.hasChef,
      alergias: alergias ?? this.alergias,
      eventType: eventType ?? this.eventType,
      preferencia: preferencia ?? this.preferencia,
      adicionales: adicionales ?? this.adicionales,
      peopleCount: peopleCount ?? this.peopleCount, 
    );
  }
}

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
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: 'salado',
        adicionales: '',
        peopleCount: 0,
      );
    } else {
      // Check if dish already exists (comparing by title)
      bool dishExists = state!.dishes.any((existingDish) => existingDish.title == dish.title);
      
      if (!dishExists) {
        // Only add if the dish doesn't exist
        state = state!.copyWith(
          dishes: [...state!.dishes, dish],
        );
      }
    }
  }

  // Update the order detailsvoid
  finalizeCateringOrder({
    required String title,
    required String img,
    required String description,
    required bool hasChef,
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
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        peopleCount: cantidadPersonas, // Update cantidadPersonas
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
