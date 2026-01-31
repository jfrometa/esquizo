import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';

part 'manual_quote_provider.g.dart';

/// State notifier for managing manual quotes with persistence
@Riverpod(keepAlive: true)
class ManualQuote extends _$ManualQuote {
  Timer? _saveDebounce;

  @override
  CateringOrderItem? build() {
    _loadManualQuote();
    ref.onDispose(() {
      _saveDebounce?.cancel();
    });
    return null;
  }

  // Set state and debounce save
  void _updateState(CateringOrderItem? newState) {
    state = newState;
    if (_saveDebounce?.isActive ?? false) _saveDebounce!.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveManualQuote();
    });
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
    _updateState(CateringOrderItem.legacy(
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
    ));
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

  /// Add a new dish to the active quote
  void addManualItem(CateringDish dish) {
    if (state == null) {
      _updateState(CateringOrderItem.legacy(
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
      _updateState(legacyItem);
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
        isQuote: true,
      ));
    } else {
      _updateState(CateringOrderItem.legacy(
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
      ));
    }
  }

  /// Update a specific dish in the quote by its index
  void updateDish(int index, CateringDish updatedDish) {
    if (state != null &&
        state!.isLegacyItem &&
        index >= 0 &&
        index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes);
      updatedDishes[index] = updatedDish;
      _updateState(state!.copyWith(dishes: updatedDishes));
    }
  }

  /// Clear the active quote
  void clearManualQuote() {
    _updateState(null);
  }

  /// Remove a specific dish from the quote by its index
  void removeFromCart(int index) {
    if (state != null &&
        state!.isLegacyItem &&
        index >= 0 &&
        index < state!.dishes.length) {
      final updatedDishes = List<CateringDish>.from(state!.dishes)
        ..removeAt(index);
      _updateState(state!.copyWith(dishes: updatedDishes));
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
      _updateState(state!.copyWith(
        hasChef: hasChef ?? state!.hasChef,
        alergias: alergias ?? state!.alergias,
        eventType: eventType ?? state!.eventType,
        preferencia: preferencia ?? state!.preferencia,
        adicionales: adicionales ?? state!.adicionales,
        peopleCount: peopleCount ?? state!.peopleCount,
      ));
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
      return null;
    }

    final order = convertToOrder(
      userId: userId,
      userName: userName,
      eventDate: eventDate,
    );

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final docRef = await firestore
        .collection('cateringOrders')
        .add(order.toJson()..remove('id'));

    clearManualQuote();
    return docRef.id;
  }
}
