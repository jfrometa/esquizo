import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class DeliveryLocation {
  final String address;
  final String floor;
  final String city;
  final String note;

  DeliveryLocation({
    required this.address,
    required this.floor,
    required this.city,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'floor': floor,
        'city': city,
        'note': note,
      };

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      address: json['address'] ?? '',
      floor: json['floor'] ?? '',
      city: json['city'] ?? '',
      note: json['note'] ?? '',
    );
  }

  DeliveryLocation copyWith({
    String? address,
    String? floor,
    String? city,
    String? note,
  }) {
    return DeliveryLocation(
      address: address ?? this.address,
      floor: floor ?? this.floor,
      city: city ?? this.city,
      note: note ?? this.note,
    );
  }
}

class DeliveryLocationNotifier extends StateNotifier<DeliveryLocation?> {
  DeliveryLocationNotifier() : super(null) {
    _loadLocation();
  }

  static const _key = 'delivery_location';

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? serializedLocation = prefs.getString(_key) ?? "";
    state = _deserializeLocation(serializedLocation);
    }

  Future<void> _saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      String serializedLocation = _serializeLocation(state!);
      await prefs.setString(_key, serializedLocation);
    } else {
      await prefs.remove(_key);
    }
  }

  @override
  set state(DeliveryLocation? value) {
    super.state = value;
    _saveLocation();
  }

  DeliveryLocation? _deserializeLocation(String jsonString) {
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return DeliveryLocation.fromJson(jsonData);
  }

  String _serializeLocation(DeliveryLocation location) {
    return jsonEncode(location.toJson());
  }

  void updateLocation({
    required String address,
    required String floor,
    required String city,
    required String note,
  }) {
    state = DeliveryLocation(
      address: address,
      floor: floor,
      city: city,
      note: note,
    );
  }

  void updatePartialLocation({
    String? address,
    String? floor,
    String? city,
    String? note,
  }) {
    if (state != null) {
      state = state!.copyWith(
        address: address,
        floor: floor,
        city: city,
        note: note,
      );
    } else {
      state = DeliveryLocation(
        address: address ?? '',
        floor: floor ?? '',
        city: city ?? '',
        note: note ?? '',
      );
    }
  }

  void clearLocation() {
    state = null;
  }
}

final deliveryLocationProvider =
    StateNotifierProvider<DeliveryLocationNotifier, DeliveryLocation?>((ref) {
  return DeliveryLocationNotifier();
});