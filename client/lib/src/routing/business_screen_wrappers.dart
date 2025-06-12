// Business screen wrappers for URL-based business routing
// These wrappers set the business context based on the URL business slug

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/unified_business_context_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';

/// Simplified business context wrapper using unified business context provider
class BusinessContextWrapper extends ConsumerWidget {
  const BusinessContextWrapper({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  final String businessSlug;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use explicit business context provider to avoid race conditions with URL detection
    final businessContextAsync =
        ref.watch(explicitBusinessContextProvider(businessSlug));

    return businessContextAsync.when(
      data: (businessContext) {
        debugPrint(
            '✅ Explicit business context loaded: ${businessContext.businessId} for slug: $businessSlug');

        return BusinessScaffoldWithNavigation(
          businessSlug: businessSlug,
          child: child,
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        debugPrint('❌ Error loading business context: $error');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading business: $businessSlug'),
                const SizedBox(height: 8),
                Text('$error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                        explicitBusinessContextProvider(businessSlug));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Wrapper for business home screen
class HomeScreenContentWrapper extends ConsumerWidget {
  const HomeScreenContentWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🏠 Loading home screen for business: $businessSlug');

    return BusinessContextWrapper(
      businessSlug: businessSlug,
      child: const MenuHome(),
    );
  }
}

/// Wrapper for business menu screen
class MenuScreenWrapper extends ConsumerWidget {
  const MenuScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🍽️ Loading menu screen for business: $businessSlug');

    return BusinessContextWrapper(
      businessSlug: businessSlug,
      child: const MenuScreen(),
    );
  }
}

/// Wrapper for business cart screen
class CartScreenWrapper extends ConsumerWidget {
  const CartScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🛒 Loading cart screen for business: $businessSlug');

    return BusinessContextWrapper(
      businessSlug: businessSlug,
      child: const CartScreen(isAuthenticated: true),
    );
  }
}

/// Wrapper for business profile screen
class ProfileScreenWrapper extends ConsumerWidget {
  const ProfileScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('👤 Loading profile screen for business: $businessSlug');

    return BusinessContextWrapper(
      businessSlug: businessSlug,
      child: const CustomProfileScreen(),
    );
  }
}

/// Wrapper for business orders screen
class OrdersScreenWrapper extends ConsumerWidget {
  const OrdersScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📋 Loading orders screen for business: $businessSlug');

    return BusinessContextWrapper(
      businessSlug: businessSlug,
      child: const InProgressOrdersScreen(),
    );
  }
}
