import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

final manualQuoteProvider =
    StateNotifierProvider<ManualQuoteNotifier, CateringOrderItem?>((ref) {
  return ManualQuoteNotifier();
});

class ManualQuoteNotifier extends StateNotifier<CateringOrderItem?> {
  Timer? _saveDebounce;
  
  // For UI styling consistency with error messages
  final ColorScheme colorScheme = ColorScheme.light(); 

  ManualQuoteNotifier() : super(null) {
    _loadManualQuote();
  }

  /// Load the quote from SharedPreferences (using the key 'manualQuote').
  Future<void> _loadManualQuote() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedQuote = prefs.getString('manualQuote');
    if (serializedQuote != null) {
      state = CateringOrderItem.fromJson(jsonDecode(serializedQuote));
    }
  }

  /// Create a new empty quote with default values.
  void createEmptyQuote() {
    state = CateringOrderItem(
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

  /// Save the current quote to SharedPreferences.
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

  /// Add a new dish to the active quote.
  void addManualItem(CateringDish dish) {
    if (state == null) {
      state = CateringOrderItem(
        title: 'Quote',
        img: '',
        description: '',
        dishes: [dish],
        hasChef: false,
        alergias: '',
        eventType: '',
        preferencia: '',
        adicionales: '',
        peopleCount: (dish.quantity > 0 ) ? state?.peopleCount : 0,
        isQuote: true,
      );
    } else {
      // Check if the dish already exists (by title).
      bool dishExists =
          state!.dishes.any((existingDish) => existingDish.title == dish.title);
      if (!dishExists) {
        state = state!.copyWith(
          dishes: [...state!.dishes, dish],
        );
      }
    }
  }

  /// Finalize or update the quote details.
  /// This method works like the catering order finalization but forces [isQuote] to true.
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
        isQuote: true,
      );
    } else {
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
        isQuote: true,
      );
    }
  }

  /// Update a specific dish in the quote by its index.
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null && index >= 0 && index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish;
      state = state!.copyWith(dishes: updatedDishes);
    }
  }

  /// Clear the active quote.
  void clearManualQuote() {
    state = null;
  }

  /// Remove a specific dish from the quote by its index.
  void removeFromCart(int index) {
    if (state != null && index >= 0 && index < state!.dishes.length) {
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
    if (state != null) {
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
}