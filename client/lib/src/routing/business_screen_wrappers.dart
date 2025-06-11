// Business screen wrappers for URL-based business routing
// These wrappers set the business context based on the URL business slug

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';

/// Base wrapper that sets business context for business-specific routes
class BusinessContextWrapper extends ConsumerStatefulWidget {
  const BusinessContextWrapper({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  final String businessSlug;
  final Widget child;

  @override
  ConsumerState<BusinessContextWrapper> createState() =>
      _BusinessContextWrapperState();
}

class _BusinessContextWrapperState
    extends ConsumerState<BusinessContextWrapper> {
  bool _isContextSet = false;

  @override
  void initState() {
    super.initState();
    _setBusinessContext();
  }

  @override
  void didUpdateWidget(BusinessContextWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the business slug has changed, update the business context
    if (widget.businessSlug != oldWidget.businessSlug) {
      debugPrint(
          '🔄 Business slug changed from ${oldWidget.businessSlug} to ${widget.businessSlug}');
      _isContextSet = false;
      _setBusinessContext();
    }
  }

  Future<void> _setBusinessContext() async {
    try {
      debugPrint(
          '🏢 Setting business context for slug: ${widget.businessSlug}');

      // Get business ID from slug
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId =
          await slugService.getBusinessIdFromSlug(widget.businessSlug);

      if (businessId != null) {
        debugPrint(
            '🏢 Resolved business ID: $businessId for slug: ${widget.businessSlug}');

        // Update local storage to set this as the current business
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', businessId);

        // Force refresh the URL-aware business ID provider
        ref.invalidate(urlAwareBusinessIdProvider);

        // Only invalidate currentBusinessIdProvider which is safe
        ref.invalidate(currentBusinessIdProvider);

        debugPrint('🔄 Essential business context providers refreshed');

        debugPrint(
            '🏢 Business context updated successfully for: ${widget.businessSlug}');

        if (mounted) {
          setState(() {
            _isContextSet = true;
          });
        }
      } else {
        debugPrint('⚠️ Business slug not found: ${widget.businessSlug}');
        if (mounted) {
          setState(() {
            _isContextSet = true;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error setting business context: $e');
      if (mounted) {
        setState(() {
          _isContextSet = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isContextSet) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BusinessScaffoldWithNavigation(
      businessSlug: widget.businessSlug,
      child: widget.child,
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
