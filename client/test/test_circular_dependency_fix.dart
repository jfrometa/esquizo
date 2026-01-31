// Test to verify the circular dependency fix
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🧪 Testing circular dependency fix...');

  final container = ProviderContainer();

  try {
    // Test 1: Can we read the shouldOptimizeNavigationProvider without circular dependency?
    debugPrint('📍 Test 1: Reading shouldOptimizeNavigationProvider...');
    final shouldOptimize =
        container.read(shouldOptimizeNavigationProvider('g3', '/menu'));
    debugPrint('✅ shouldOptimizeNavigationProvider result: $shouldOptimize');

    // Test 2: Can we read currentBusinessNavigationProvider without issues?
    debugPrint('📍 Test 2: Reading currentBusinessNavigationProvider...');
    final currentNavigation = container.read(currentBusinessNavigationProvider);
    debugPrint(
        '✅ currentBusinessNavigationProvider result: $currentNavigation');

    // Test 3: Can we read the business ID provider without issues?
    debugPrint('📍 Test 3: Reading currentBusinessIdProvider...');
    final businessId = container.read(currentBusinessIdProvider);
    debugPrint('✅ currentBusinessIdProvider result: $businessId');

    // Test 4: Try to set business navigation and check optimization
    debugPrint('📍 Test 4: Setting business navigation...');

    // Set up a business navigation state
    await container
        .read(businessNavigationControllerProvider.notifier)
        .setBusinessNavigation('g3', '/menu');

    debugPrint('✅ Business navigation set successfully');

    // Now test optimization again
    debugPrint('📍 Test 5: Testing optimization after navigation is set...');
    final shouldOptimizeAfter =
        container.read(shouldOptimizeNavigationProvider('g3', '/carrito'));
    debugPrint(
        '✅ shouldOptimizeNavigationProvider after navigation: $shouldOptimizeAfter');

    debugPrint('🎉 All tests passed! Circular dependency is fixed.');
  } catch (error, stackTrace) {
    debugPrint('❌ Test failed with error: $error');
    debugPrint('📊 Stack trace:');
    debugPrint(stackTrace.toString());
  } finally {
    container.dispose();
  }
}
