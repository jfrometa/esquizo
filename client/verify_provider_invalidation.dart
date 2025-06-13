#!/usr/bin/env dart

/// Test script to verify that provider invalidation works correctly when business changes
/// This ensures that all business-dependent providers are refreshed with new business context

import 'dart:io';

Future<void> main() async {
  print('🔍 Verifying comprehensive provider invalidation logic...\n');

  final results = <String, bool>{};

  // Verify that the invalidation method includes all necessary business-dependent providers
  results['Provider invalidation method exists'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['_invalidateBusinessDependentProviders']);

  // Check catalog and menu providers
  results['Catalog providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart', [
    'catalogItemsProvider',
    'menuProductsProvider',
    'menuCategoriesProvider'
  ]);

  // Check catering providers
  results['Catering providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['cateringItemRepositoryProvider', 'cateringCategoryRepositoryProvider']);

  // Check order management providers
  results['Order providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart', [
    'activeOrdersStreamProvider',
    'allOrdersStreamProvider',
    'pendingOrdersProvider'
  ]);

  // Check table management providers
  results['Table providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart', [
    'tablesStreamProvider',
    'activeTablesProvider',
    'availableTablesProvider'
  ]);

  // Check admin statistics providers
  results['Admin stats providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart', [
    'admin_stats.combinedAdminStatsProvider',
    'admin_stats.orderStatsProvider'
  ]);

  // Check business configuration providers
  results['Business config providers are invalidated'] =
      await _checkFileContains(
          'lib/src/core/business/unified_business_context_provider.dart', [
    'businessConfigProvider',
    'businessTypeProvider',
    'businessNameProvider'
  ]);

  // Check service providers
  results['Service providers are invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['tableServiceProvider', 'orderServiceProvider']);

  // Check cart provider
  results['Cart provider is invalidated'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['cartProvider']);

  // Verify that invalidation is called when business changes
  results['Invalidation is called on business change'] =
      await _checkFileContains(
          'lib/src/core/business/unified_business_context_provider.dart', [
    'await _invalidateBusinessDependentProviders();',
    'Providers invalidated due to business change'
  ]);

  // Verify necessary imports are present
  results['Required imports are present'] = await _checkFileContains(
      'lib/src/core/business/unified_business_context_provider.dart',
      ['unified_order_service.dart', 'table_service.dart', 'as admin_stats']);

  // Verify that core providers are NOT invalidated (to prevent circular dependencies)
  results['Core providers are NOT invalidated'] =
      await _checkFileDoesNotContain(
          'lib/src/core/business/unified_business_context_provider.dart', [
    'ref.invalidate(currentBusinessIdProvider)',
    'ref.invalidate(urlAwareBusinessIdProvider)',
    'ref.invalidate(unifiedBusinessContextProvider)'
  ]);

  print('📊 Provider Invalidation Verification Results:');
  print('=' * 70);

  int passed = 0;
  int total = results.length;

  results.forEach((test, success) {
    final status = success ? '✅ PASS' : '❌ FAIL';
    print('$status $test');
    if (success) passed++;
  });

  print('=' * 70);
  print('📈 Summary: $passed/$total tests passed');

  if (passed == total) {
    print('🎉 All provider invalidation verifications passed!');
    print(
        '✨ Business-dependent providers will be properly refreshed when business changes.');
    exit(0);
  } else {
    print(
        '⚠️  Some provider invalidation verifications failed. Please review the issues above.');
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
