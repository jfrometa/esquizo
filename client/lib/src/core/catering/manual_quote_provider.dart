import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'; // Update this import path to your merged models

/// Provider for managing manual quotes - a specialized type of catering order
final manualQuoteProvider =
    StateNotifierProvider<ManualQuoteNotifier, CateringOrderItem?>((ref) {
  return ManualQuoteNotifier();
});

/// State notifier for managing manual quotes with persistence
class ManualQuoteNotifier extends StateNotifier<CateringOrderItem?> {
  Timer? _saveDebounce;
  
  // For UI styling consistency with error messages
  final ColorScheme colorScheme = ColorScheme.light(); 

  ManualQuoteNotifier() : super(null) {
    _loadManualQuote();
  }

  /// Load the quote from SharedPreferences (using the key 'manualQuote')
  Future<void> _loadManualQuote() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedQuote = prefs.getString('manualQuote');
    if (serializedQuote != null && serializedQuote.isNotEmpty) {
      try {
        state = CateringOrderItem.fromJson(jsonDecode(serializedQuote));
      } catch (e) {
        debugPrint('Error deserializing manual quote: $e');
        state = null;
      }
    } else {
      state = null;
    }
  }

  /// Create a new empty quote with default values
  void createEmptyQuote() {
    state = CateringOrderItem.legacy(
      title: 'Quote',
      img: '',
      description: '',
      dishes: [],
      hasChef: false,
      alergias: '',
      eventType: '',
      preferencia: '',
      adicionales: '',
      peopleCount: 0,
      isQuote: true,
    );
  }

  /// Save the current quote to SharedPreferences
  Future<void> _saveManualQuote() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      await prefs.setString('manualQuote', jsonEncode(state!.toJson()));
    } else {
      await prefs.remove('manualQuote');
    }
  }

  @override
  set state(CateringOrderItem? value) {
    super.state = value;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveManualQuote();
    });
  }

  /// Add a new dish to the active quote
  void addManualItem(CateringDish dish) {
    if (state == null) {
      // Create a new quote with default values
      state = CateringOrderItem.legacy(
        title: 'Quote',
        img: '',
        description: '',
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: '',
        adicionales: '',
        peopleCount: (dish.quantity > 0) ? dish.peopleCount : 0,
        isQuote: true,
      );
    } else if (state!.isLegacyItem) {
      // Check if the dish already exists (by title)
      bool dishExists =
          state!.dishes.any((existingDish) => existingDish.title == dish.title);
      if (!dishExists) {
        state = state!.copyWith(
          dishes: [...state!.dishes, dish],
        );
      }
    } else {
      // Handle case where state is not legacy format
      final legacyItem = CateringOrderItem.legacy(
        title: state!.name,
        img: '',
        description: state!.notes,
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: '',
        adicionales: '',
        peopleCount: dish.peopleCount,
        isQuote: true,
      );
      state = legacyItem;
    }
  }

  /// Finalize or update the quote details
  /// This method works like the catering order finalization but forces [isQuote] to true
  void finalizeManualQuote({
    required String title,
    required String img,
    required String description,
    required bool hasChef,
    required String alergias,
    required String eventType,
    required String preferencia,
    required String adicionales,
    required int cantidadPersonas,
  }) {
    if (state != null && state!.isLegacyItem) {
      // Update existing legacy quote
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
        isQuote: true,
      );
    } else {
      // Create a new legacy quote
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
        isQuote: true,
      );
    }
  }

  /// Update a specific dish in the quote by its index
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null && state!.isLegacyItem && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish;
      state = state!.copyWith(dishes: updatedDishes);
    }
  }

  /// Clear the active quote
  void clearManualQuote() {
    state = null;
  }

  /// Remove a specific dish from the quote by its index
  void removeFromCart(int index) {
    if (state != null && state!.isLegacyItem && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes)..removeAt(index);
      
      state = state!.copyWith(dishes: updatedDishes);
    }
  }

  /// Update the quote details for fields such as [hasChef], [alergias], etc.
  void updateQuoteDetails({
    bool? hasChef,
    String? alergias,
    String? eventType,
    String? preferencia,
    String? adicionales,
    int? peopleCount,
  }) {
    if (state != null && state!.isLegacyItem) {
      state = state!.copyWith(
        hasChef: hasChef ?? state!.hasChef,
        alergias: alergias ?? state!.alergias,
        eventType: eventType ?? state!.eventType,
        preferencia: preferencia ?? state!.preferencia,
        adicionales: adicionales ?? state!.adicionales,
        peopleCount: peopleCount ?? state!.peopleCount,
      );
    }
  }
  
  /// Convert the manual quote to a CateringOrder
  CateringOrder convertToOrder({
    required String userId,
    String? userName,
    required DateTime eventDate,
  }) {
    if (state == null || !state!.isLegacyItem) {
      throw Exception('No valid quote to convert');
    }
    
    return CateringOrder.fromLegacyItem(
      state!,
      customerId: userId,
      customerName: userName,
      eventDate: eventDate,
      status: CateringOrderStatus.pending,
    );
  }
  
  /// Submit the manual quote to Firestore
  Future<String?> submitQuoteAsOrder({
    required String userId,
    String? userName,
    required DateTime eventDate,
  }) async {
    if (state == null || !state!.isLegacyItem || state!.dishes.isEmpty) {
      return null; // Nothing to submit
    }
    
    final order = convertToOrder(
      userId: userId,
      userName: userName,
      eventDate: eventDate,
    );
    
    // Use Firebase to save the order
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final docRef = await firestore.collection('cateringOrders').add(order.toJson()..remove('id'));
    
    // Clear the quote after submission
    clearManualQuote();
    
    return docRef.id;
  }
}