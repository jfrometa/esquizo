// Test to verify the circular dependency fix
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Testing circular dependency fix...');

  final container = ProviderContainer();

  try {
    // Test 1: Can we read the shouldOptimizeNavigationProvider without circular dependency?
    print('📍 Test 1: Reading shouldOptimizeNavigationProvider...');
    final shouldOptimize =
        container.read(shouldOptimizeNavigationProvider('g3', '/menu'));
    print('✅ shouldOptimizeNavigationProvider result: $shouldOptimize');

    // Test 2: Can we read currentBusinessNavigationProvider without issues?
    print('📍 Test 2: Reading currentBusinessNavigationProvider...');
    final currentNavigation = container.read(currentBusinessNavigationProvider);
    print('✅ currentBusinessNavigationProvider result: $currentNavigation');

    // Test 3: Can we read the business ID provider without issues?
    print('📍 Test 3: Reading currentBusinessIdProvider...');
    final businessId = container.read(currentBusinessIdProvider);
    print('✅ currentBusinessIdProvider result: $businessId');

    // Test 4: Try to set business navigation and check optimization
    print('📍 Test 4: Setting business navigation...');

    // Set up a business navigation state
    await container
        .read(businessNavigationControllerProvider.notifier)
        .setBusinessNavigation('g3', '/menu');

    print('✅ Business navigation set successfully');

    // Now test optimization again
    print('📍 Test 5: Testing optimization after navigation is set...');
    final shouldOptimizeAfter =
        container.read(shouldOptimizeNavigationProvider('g3', '/carrito'));
    print(
        '✅ shouldOptimizeNavigationProvider after navigation: $shouldOptimizeAfter');

    print('🎉 All tests passed! Circular dependency is fixed.');
  } catch (error, stackTrace) {
    print('❌ Test failed with error: $error');
    print('📊 Stack trace:');
    print(stackTrace);
  } finally {
    container.dispose();
  }
}
