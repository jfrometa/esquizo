import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {
  @override
  DatabaseReference child(String path) => this;

  @override
  Future<void> update(Map<String, dynamic> value) async {
    return;
  }
}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {
  final MockDatabaseReference _reference = MockDatabaseReference();

  @override
  DatabaseReference ref([String? path]) => _reference;
}

void main() {
  group('BusinessFeaturesService initialization tests', () {
    late MockFirebaseDatabase mockDatabase;
    late BusinessFeaturesService service;

    setUp(() {
      mockDatabase = MockFirebaseDatabase();
      service = BusinessFeaturesService(database: mockDatabase);
    });

    test('Default features are correctly initialized', () {
      // Default features should all be true
      final defaultFeatures = const BusinessFeatures();

      expect(defaultFeatures.catering, true);
      expect(defaultFeatures.mealPlans, true);
      expect(defaultFeatures.inDine, true);
      expect(defaultFeatures.staff, true);
      expect(defaultFeatures.kitchen, true);
      expect(defaultFeatures.reservations, true);
    });

    test('Default UI is correctly initialized', () {
      // Default UI should all be true
      final defaultUI = const BusinessUI();

      expect(defaultUI.landingPage, true);
      expect(defaultUI.orders, true);
    });
  });

  group('BusinessFeatures for different business types', () {
    test('Restaurant features are correctly defined', () {
      final restaurantFeatures = BusinessFeatures(
        catering: true,
        mealPlans: true,
        inDine: true,
        staff: true,
        kitchen: true,
        reservations: true,
      );

      expect(restaurantFeatures.catering, true);
      expect(restaurantFeatures.mealPlans, true);
      expect(restaurantFeatures.inDine, true);
      expect(restaurantFeatures.staff, true);
      expect(restaurantFeatures.kitchen, true);
      expect(restaurantFeatures.reservations, true);
    });

    test('Food truck features are correctly defined', () {
      final foodTruckFeatures = BusinessFeatures(
        catering: true,
        mealPlans: false,
        inDine: false,
        staff: true,
        kitchen: true,
        reservations: false,
      );

      expect(foodTruckFeatures.catering, true);
      expect(foodTruckFeatures.mealPlans, false);
      expect(foodTruckFeatures.inDine, false);
      expect(foodTruckFeatures.staff, true);
      expect(foodTruckFeatures.kitchen, true);
      expect(foodTruckFeatures.reservations, false);
    });

    test('Ghost kitchen features are correctly defined', () {
      final ghostKitchenFeatures = BusinessFeatures(
        catering: true,
        mealPlans: true,
        inDine: false,
        staff: true,
        kitchen: true,
        reservations: false,
      );

      expect(ghostKitchenFeatures.catering, true);
      expect(ghostKitchenFeatures.mealPlans, true);
      expect(ghostKitchenFeatures.inDine, false);
      expect(ghostKitchenFeatures.staff, true);
      expect(ghostKitchenFeatures.kitchen, true);
      expect(ghostKitchenFeatures.reservations, false);
    });
  });

  group('BusinessUI for different business types', () {
    test('Restaurant UI is correctly defined', () {
      final restaurantUI = BusinessUI(
        landingPage: true,
        orders: true,
      );

      expect(restaurantUI.landingPage, true);
      expect(restaurantUI.orders, true);
    });

    test('Ghost kitchen UI is correctly defined', () {
      final ghostKitchenUI = BusinessUI(
        landingPage: false,
        orders: true,
      );

      expect(ghostKitchenUI.landingPage, false);
      expect(ghostKitchenUI.orders, true);
    });

    test('Quick service UI is correctly defined', () {
      final quickServiceUI = BusinessUI(
        landingPage: false,
        orders: true,
      );

      expect(quickServiceUI.landingPage, false);
      expect(quickServiceUI.orders, true);
    });
  });
}
