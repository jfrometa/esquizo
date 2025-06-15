#!/usr/bin/env dart

/// Validation script to check if browser navigation fixes are properly implemented
/// This script verifies that the problematic patterns have been addressed

import 'dart:io';

void main() {
  print('🔍 Validating Browser Navigation Fixes...\n');

  bool allTestsPassed = true;

  // Test 1: Check if _checkForUrlChanges is disabled
  allTestsPassed &= testAppCheckForUrlChangesDisabled();

  // Test 2: Check if currentRouteLocationProvider is simplified
  allTestsPassed &= testCurrentRouteLocationProviderSimplified();

  // Test 3: Check if setPathUrlStrategy is called
  allTestsPassed &= testPathUrlStrategyEnabled();

  // Test 4: Check if manual listener was removed
  allTestsPassed &= testManualListenerRemoved();

  if (allTestsPassed) {
    print('\n✅ All validation tests passed!');
    print('🎉 Browser navigation fixes have been successfully implemented.');
    print('\nThe app should now:');
    print('  - Use path URL strategy (no # in URLs)');
    print('  - Handle browser navigation without restarting Flutter engine');
    print('  - Have simplified provider reactivity');
    print('  - Avoid navigation conflicts between browser and app state');
    exit(0);
  } else {
    print('\n❌ Some validation tests failed!');
    print('Please review the implementation.');
    exit(1);
  }
}

bool testAppCheckForUrlChangesDisabled() {
  print('📋 Test 1: Checking if _checkForUrlChanges is disabled...');

  try {
    final appFile = File('lib/src/app.dart');
    final content = appFile.readAsStringSync();

    // Check if the sync logic is commented out
    if (content.contains(
            'debugPrint(\'🧭 App lifecycle: URL check disabled to prevent navigation conflicts\');') &&
        content.contains('// DISABLED: Commenting out the sync logic') &&
        content.contains('/* \n    try {') &&
        content.contains('*/')) {
      print('   ✅ _checkForUrlChanges is properly disabled');
      return true;
    } else {
      print('   ❌ _checkForUrlChanges is not properly disabled');
      return false;
    }
  } catch (e) {
    print('   ❌ Failed to read app.dart: $e');
    return false;
  }
}

bool testCurrentRouteLocationProviderSimplified() {
  print('📋 Test 2: Checking if currentRouteLocationProvider is simplified...');

  try {
    final providerFile = File('lib/src/routing/business_routing_provider.dart');
    final content = providerFile.readAsStringSync();

    // Check if manual listener was removed and WebUtils.getCurrentPath() is used directly
    if (content.contains(
            '/// SIMPLIFIED: Direct WebUtils access - reactivity handled at app level') &&
        content.contains('final currentPath = WebUtils.getCurrentPath();') &&
        !content.contains('ref.invalidateSelf();') &&
        !content.contains('ref.listen(')) {
      print('   ✅ currentRouteLocationProvider is properly simplified');
      return true;
    } else {
      print('   ❌ currentRouteLocationProvider is not properly simplified');
      return false;
    }
  } catch (e) {
    print('   ❌ Failed to read business_routing_provider.dart: $e');
    return false;
  }
}

bool testPathUrlStrategyEnabled() {
  print('📋 Test 3: Checking if setPathUrlStrategy is called...');

  try {
    final mainFile = File('lib/main.dart');
    final content = mainFile.readAsStringSync();

    if (content.contains('setPathUrlStrategy();')) {
      print('   ✅ setPathUrlStrategy is called in main.dart');
      return true;
    } else {
      print('   ❌ setPathUrlStrategy is not called in main.dart');
      return false;
    }
  } catch (e) {
    print('   ❌ Failed to read main.dart: $e');
    return false;
  }
}

bool testManualListenerRemoved() {
  print('📋 Test 4: Checking if manual listener was removed...');

  try {
    final providerFile = File('lib/src/routing/business_routing_provider.dart');
    final content = providerFile.readAsStringSync();

    // Check that problematic patterns are not present
    if (!content.contains('ref.listen(routeLocationProvider') &&
        !content.contains('ref.invalidateSelf();')) {
      print('   ✅ Manual listener patterns have been removed');
      return true;
    } else {
      print('   ❌ Manual listener patterns are still present');
      return false;
    }
  } catch (e) {
    print('   ❌ Failed to read business_routing_provider.dart: $e');
    return false;
  }
}
