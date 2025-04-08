import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/setup/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';
import 'package:flutter/foundation.dart';

// Update the provider to include both catering and manual orders
final cateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  final manualQuote = ref.watch(manualQuoteProvider);

  final hasCateringOrder = (cateringOrder?.dishes.length ?? 0) > 0 ? 1 : 0;
  final hasManualQuote = (manualQuote?.dishes.length ?? 0) > 0 ? 1 : 0;

  return hasCateringOrder + hasManualQuote;
});

/// --------------------------------------------------------------------------
/// 1. Computed Provider to Lazily Calculate the Total Cart Quantity
/// --------------------------------------------------------------------------
final totalCartQuantityProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  final mealItems = ref.watch(mealOrderProvider);
  final cateringCount = ref.watch(cateringItemCountProvider);
  final cartTotal =
      cartItems.items.fold(0, (total, item) => total + item.quantity);
  final mealTotal = mealItems.length;
  return cartTotal + mealTotal + cateringCount;
});

/// --------------------------------------------------------------------------
/// 2. A Separate Widget for the Cart Badge to Limit Rebuilds
/// --------------------------------------------------------------------------
class CartBadge extends ConsumerWidget {
  final IconData icon;
  const CartBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuantity = ref.watch(totalCartQuantityProvider);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (totalQuantity > 0)
          Positioned(
            top: -7,
            right: -9,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: theme.colorScheme.error,
              child: Text(
                '$totalQuantity',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// --------------------------------------------------------------------------
/// 3. ScaffoldWithNestedNavigation
/// --------------------------------------------------------------------------
class ScaffoldWithNestedNavigation extends ConsumerStatefulWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends ConsumerState<ScaffoldWithNestedNavigation> {
  bool _isDisposed = false;
  String? _originalPath;

  @override
  void initState() {
    super.initState();

    // Capture the initial path - important for route preservation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;

      try {
        // Store initial path to preserve it during admin status changes
        final router = GoRouter.of(context);
        _originalPath = router.state.matchedLocation;
        debugPrint('📝 Original path stored: $_originalPath');

        // Trigger the app startup provider to ensure admin status is checked
        ref.read(appStartupProvider);

        // Check for admin status without changing routes
        _checkAdminStatus(preserveRoute: true);

        // Update the selectedTabIndex provider for the current tab
        if (!_isDisposed) {
          ref
              .read(selectedTabIndexProvider.notifier)
              .setIndex(widget.navigationShell.currentIndex);
        }
      } catch (e) {
        debugPrint('❌ Error in initState: $e');
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _checkAdminStatus({bool preserveRoute = false}) async {
    if (_isDisposed) return;

    try {
      // Check admin status eagerly, regardless of path
      final isAdmin = await ref.read(eagerAdminStatusProvider.future);
      if (_isDisposed) return;

      // Get current path
      String currentPath = '';
      if (kIsWeb) {
        currentPath = WebUtils.getCurrentPath();
      } else {
        try {
          final router = GoRouter.of(context);
          currentPath = router.state.matchedLocation;
        } catch (e) {
          debugPrint('❌ Error getting current path: $e');
        }
      }

      debugPrint('🛣️ Current path check: $currentPath');

      // Update admin status based on path or status check
      bool shouldUpdateUI = false;

      if (currentPath.startsWith('/admin')) {
        debugPrint('🔐 Detected admin path: $currentPath');

        // Set admin status to true if we're in admin path
        if (!ref.read(cachedAdminStatusProvider)) {
          debugPrint('🔄 Setting admin status to true based on path');
          ref.read(cachedAdminStatusProvider.notifier).state = true;
          shouldUpdateUI = true;
        }

        // Store the path, but don't navigate if preserveRoute is true
        ref.read(pendingAdminPathProvider.notifier).state = currentPath;
      } else if (isAdmin) {
        // We're not on an admin path, but user is admin
        debugPrint('👤 User is admin but not on admin path');

        if (!ref.read(cachedAdminStatusProvider)) {
          ref.read(cachedAdminStatusProvider.notifier).state = true;
          shouldUpdateUI = true;
        }

        // If we should preserve the route, don't navigate
        if (preserveRoute && _originalPath != null) {
          debugPrint('🔒 Preserving original route: $_originalPath');
        }
      }

      // Request UI update if needed (only if status changed)
      if (shouldUpdateUI) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            setState(() {
              // Trigger rebuild to show admin tab without changing route
            });
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error in _checkAdminStatus: $e');
    }
  }

  void _goBranch(int index) {
    if (_isDisposed) return;

    try {
      // Get the list of destinations
      final destinations = ref.read(navigationDestinationsProvider);

      // Ensure index is valid
      if (index < 0 || index >= destinations.length) {
        debugPrint('⚠️ Invalid destination index: $index');
        return;
      }

      // Handle direct navigation for admin routes
      if (destinations[index].path == '/admin') {
        // Check if we have a pending admin path to navigate to
        final pendingAdminPath = ref.read(pendingAdminPathProvider);
        if (pendingAdminPath != null && pendingAdminPath.startsWith('/admin')) {
          debugPrint('🔐 Navigating to saved admin path: $pendingAdminPath');
          context.go(pendingAdminPath);
          return;
        }

        // Default to root admin path
        debugPrint('🔐 Navigating to admin panel');
        context.go('/admin');
        return;
      }

      // Update the provider state
      ref.read(selectedTabIndexProvider.notifier).setIndex(index);

      // Use the navigationShell to navigate
      widget.navigationShell.goBranch(
        index,
        // Navigate to initial location if selecting the same tab
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    } catch (e) {
      debugPrint('❌ Error in _goBranch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Choose which scaffold to use based on screen size
    return size.width < 450
        ? ScaffoldWithNavigationBar(
            navigationShell: widget.navigationShell,
            currentIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          )
        : ScaffoldWithNavigationRail(
            navigationShell: widget.navigationShell,
            currentIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          );
  }
}

/// --------------------------------------------------------------------------
/// 4. ScaffoldWithNavigationBar (ConsumerStatefulWidget)
/// --------------------------------------------------------------------------
class ScaffoldWithNavigationBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ScaffoldWithNavigationBarState createState() =>
      ScaffoldWithNavigationBarState();
}

class ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _adminIconController;
  bool _isDisposed = false;

  // Flag to track if we've already checked for admin status
  bool _hasCheckedAdminStatus = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth admin icon appearance
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Listen to scroll events to hide/show the navigation bar (except for the "Cuenta" tab).
    _scrollController.addListener(() {
      if (_isDisposed) return;

      if (widget.currentIndex != 3) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible) {
            setState(() {
              _isVisible = false;
            });
          }
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });

    // Check admin status on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _checkAdminStatus();
      }
    });
  }

  // Check admin status without affecting navigation
  void _checkAdminStatus() async {
    if (_isDisposed) return;

    try {
      // Mark that we've checked for admin status
      _hasCheckedAdminStatus = true;

      final isAdmin = await ref.read(eagerAdminStatusProvider.future);

      if (_isDisposed) return;

      // Update the cached admin status if needed
      if (isAdmin && !ref.read(cachedAdminStatusProvider)) {
        ref.read(cachedAdminStatusProvider.notifier).state = true;
      }

      // Start animation if admin, without navigating
      if (isAdmin &&
          !_adminIconController.isAnimating &&
          _adminIconController.status != AnimationStatus.completed) {
        _adminIconController.forward();
      }

      // Store the current path if we're on an admin path
      final currentPath = GoRouterState.of(context).uri.path;
      if (isAdmin && currentPath.startsWith('/admin')) {
        // Store the path for future reference, but don't navigate yet
        ref.read(pendingAdminPathProvider.notifier).state = currentPath;
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _adminIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If we haven't checked admin status yet and the user is authenticated, do it now
    if (!_hasCheckedAdminStatus && authState.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _checkAdminStatus();
        }
      });
    }

    // If user is signed out, ensure admin is false and reset animation
    if (authState.value == null && isAdmin) {
      if (_adminIconController.status != AnimationStatus.dismissed) {
        try {
          _adminIconController.reset();
        } catch (e) {
          debugPrint('Error resetting animation: $e');
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          ref.read(cachedAdminStatusProvider.notifier).state = false;
        }
      });
    }

    // Get the current route to check if we're on an admin page
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're on an admin route but admin status is false, update it without navigating
    if (isAdminRoute && !isAdmin && authState.value != null) {
      debugPrint('🔄 On admin route but admin status is false, updating...');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          ref.read(cachedAdminStatusProvider.notifier).state = true;

          if (!_adminIconController.isAnimating &&
              _adminIconController.status != AnimationStatus.completed) {
            try {
              _adminIconController.forward();
            } catch (e) {
              debugPrint('Error starting animation: $e');
            }
          }
        }
      });
    }

    // Check if admin status changed to trigger animation
    if (isAdmin && authState.value != null) {
      if (_adminIconController.status != AnimationStatus.completed &&
          !_adminIconController.isAnimating) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            try {
              _adminIconController.forward();
            } catch (e) {
              debugPrint('Error starting animation: $e');
            }
          }
        });
      }
    }

    // We'll use this to highlight the admin tab if needed
    int selectedIndex = widget.currentIndex;
    if (isAdminRoute) {
      // Find the index of the admin destination if it exists
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _isVisible ? kBottomNavigationBarHeight + 16 : 0.0,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: theme.colorScheme.primary,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  );
                }
                return theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? IconThemeData(color: theme.colorScheme.onPrimary)
                    : IconThemeData(color: theme.colorScheme.onSurface);
              }),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  // Map regular destinations
                  ...destinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dest = entry.value;

                    // Special handling for cart icon
                    if (dest.path == '/carrito') {
                      return NavigationDestination(
                        icon:
                            const CartBadge(icon: Icons.shopping_cart_outlined),
                        selectedIcon:
                            const CartBadge(icon: Icons.shopping_cart),
                        label: dest.label,
                      );
                    }

                    return NavigationDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.selectedIcon),
                      label: dest.label,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// 5. ScaffoldWithNavigationRail (ConsumerWidget)
/// --------------------------------------------------------------------------
class ScaffoldWithNavigationRail extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ConsumerState<ScaffoldWithNavigationRail> createState() =>
      _ScaffoldWithNavigationRailState();
}

class _ScaffoldWithNavigationRailState
    extends ConsumerState<ScaffoldWithNavigationRail>
    with SingleTickerProviderStateMixin {
  late AnimationController _adminIconController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth admin icon appearance
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Eagerly check admin status for the navigation rail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _checkAdminStatus();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _adminIconController.dispose();
    super.dispose();
  }

  void _checkAdminStatus() async {
    if (_isDisposed) return;

    try {
      // Eagerly check admin status
      final isAdmin = await ref.read(eagerAdminStatusProvider.future);

      // Start animation if admin
      if (!_isDisposed &&
          isAdmin &&
          !_adminIconController.isAnimating &&
          _adminIconController.status != AnimationStatus.completed) {
        _adminIconController.forward();
      }
    } catch (e) {
      // Safely handle any exceptions during admin status check
      debugPrint('Error checking admin status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If user is signed out, ensure admin is false and reset animation
    if (authState.value == null && isAdmin) {
      // Use safer approach instead of Future.microtask
      if (_adminIconController.status != AnimationStatus.dismissed) {
        try {
          _adminIconController.reset();
        } catch (e) {
          debugPrint('Error resetting animation: $e');
        }
      }

      // Update the admin status on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          ref.read(cachedAdminStatusProvider.notifier).state = false;
        }
      });
    }

    // Get the current route to check if we're on an admin page
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're on an admin route but admin status is false, update it
    if (isAdminRoute && !isAdmin && authState.value != null) {
      debugPrint('🔄 On admin route but admin status is false, updating...');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          ref.read(cachedAdminStatusProvider.notifier).state = true;

          if (!_adminIconController.isAnimating &&
              _adminIconController.status != AnimationStatus.completed) {
            try {
              _adminIconController.forward();
            } catch (e) {
              debugPrint('Error starting animation: $e');
            }
          }
        }
      });
    }

    // Check if admin status changed to trigger animation
    if (isAdmin && authState.value != null) {
      if (_adminIconController.status != AnimationStatus.completed &&
          !_adminIconController.isAnimating) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            try {
              _adminIconController.forward();
            } catch (e) {
              debugPrint('Error starting animation: $e');
            }
          }
        });
      }
    }

    // We'll use this to highlight the admin tab if needed
    int selectedIndex = widget.currentIndex;
    if (isAdminRoute) {
      // Find the index of the admin destination if it exists
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Use AnimatedContainer to smoothly resize the rail when items are added/removed
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: NavigationRail(
              indicatorColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              selectedIndex: selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme:
                  IconThemeData(color: theme.colorScheme.onPrimary),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme:
                  IconThemeData(color: theme.colorScheme.onSurface),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              destinations: [
                // Map regular destinations
                ...destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dest = entry.value;

                  // Special handling for cart icon
                  if (dest.path == '/carrito') {
                    return NavigationRailDestination(
                      icon: const CartBadge(icon: Icons.shopping_cart_outlined),
                      selectedIcon: const CartBadge(icon: Icons.shopping_cart),
                      label: Text(dest.label),
                    );
                  }

                  return NavigationRailDestination(
                    icon: Icon(dest.icon),
                    selectedIcon: Icon(dest.selectedIcon),
                    label: Text(dest.label),
                  );
                }),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: theme.dividerColor),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
