#!/usr/bin/env dart

/// Simple verification script to check that business context logic is URL-driven
/// and no longer depends on localStorage.

import 'dart:io';

Future<void> main() async {
  print('🔍 Verifying localStorage removal from business logic...\n');

  final results = <String, bool>{};

  // Check that unified_business_context_provider.dart doesn't contain localStorage reads
  results['No localStorage reads in unified_business_context_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/core/business/unified_business_context_provider.dart', [
    'localStorage.getString',
    'localStorage.getBool',
    'localStorage.getInt'
  ]);

  // Check that unified_business_context_provider.dart doesn't contain localStorage writes
  results['No localStorage writes in unified_business_context_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/core/business/unified_business_context_provider.dart', [
    'localStorage.setString',
    'localStorage.setBool',
    'localStorage.setInt'
  ]);

  // Check that business_routing_provider.dart doesn't contain localStorage reads
  results['No localStorage reads in business_routing_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/routing/business_routing_provider.dart', [
    'localStorage.getString',
    'localStorage.getBool',
    'localStorage.getInt'
  ]);

  // Check that business_routing_provider.dart doesn't contain localStorage writes
  results['No localStorage writes in business_routing_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/routing/business_routing_provider.dart', [
    'localStorage.setString',
    'localStorage.setBool',
    'localStorage.setInt'
  ]);

  // Check that local storage import is removed from unified_business_context_provider
  results['No localStorage import in unified_business_context_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/core/business/unified_business_context_provider.dart',
          ['local_storange/local_storage_service.dart']);

  // Check that business providers still exist and are functional
  results['Current business ID provider exists'] = await _checkFileContains(
      'lib/src/core/business/business_config_provider.dart',
      ['currentBusinessIdProvider']);

  results['Unified business context provider exists'] =
      await _checkFileContains(
          'lib/src/core/business/unified_business_context_provider.dart',
          ['unifiedBusinessContextProvider']);

  results['Business slug from URL provider exists'] = await _checkFileContains(
      'lib/src/routing/business_routing_provider.dart',
      ['businessSlugFromUrlProvider']);

  // Check that business context is determined by URL
  results['Business context uses URL-based routing'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['businessSlugFromUrlProvider', 'currentBusinessIdProvider']);

  // Check that no localStorage business ID storage methods remain
  results['No _storeBusinessIdAsync method in business_routing_provider'] =
      await _checkFileDoesNotContain(
          'lib/src/routing/business_routing_provider.dart',
          ['_storeBusinessIdAsync']);

  print('📊 Verification Results:');
  print('=' * 60);

  int passed = 0;
  int total = results.length;

  results.forEach((test, success) {
    final status = success ? '✅ PASS' : '❌ FAIL';
    print('$status $test');
    if (success) passed++;
  });

  print('=' * 60);
  print('📈 Summary: $passed/$total tests passed');

  if (passed == total) {
    print('🎉 All verifications passed! Business logic is now URL-driven.');
    exit(0);
  } else {
    print('⚠️  Some verifications failed. Please review the issues above.');
    exit(1);
  }
}

Future<bool> _checkFileContains(String filePath, List<String> patterns) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      print('   ⚠️  File not found: $filePath');
      return false;
    }

    final content = await file.readAsString();

    for (final pattern in patterns) {
      if (!content.contains(pattern)) {
        print('   ❌ Pattern "$pattern" not found in $filePath');
        return false;
      }
    }

    return true;
  } catch (e) {
    print('   ❌ Error reading $filePath: $e');
    return false;
  }
}

Future<bool> _checkFileDoesNotContain(
    String filePath, List<String> patterns) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      print('   ⚠️  File not found: $filePath');
      return true; // If file doesn't exist, it can't contain the patterns
    }

    final content = await file.readAsString();

    for (final pattern in patterns) {
      if (content.contains(pattern)) {
        print(
            '   ❌ Pattern "$pattern" found in $filePath (should not be present)');
        return false;
      }
    }

    return true;
  } catch (e) {
    print('   ❌ Error reading $filePath: $e');
    return false;
  }
}
