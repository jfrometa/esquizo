import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_search_interface.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_tab_bar.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

// Import all the necessary files from your project
import '../QR/models/qr_code_data.dart';
import '../../core/menu/menu_providers.dart';
// Views
import 'views/category_view.dart';
import 'views/catering_view.dart';
import 'views/filter_bottom_sheet.dart';
import 'views/meal_plans_view.dart';
import 'views/search_results_view.dart';
import 'views/special_offers_view.dart';

// Provider to share scroll position across the entire menu
final menuScrollOffsetProvider = StateProvider<double>((ref) => 0.0);

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // State variables
  bool _isSearching = false;
  final double _headerThreshold = 80.0; // Threshold for header animation
  final double _parallaxFactor = 0.5;

  // Tab and scroll controllers
  late final TabController _tabController;
  final ScrollController _mainScrollController = ScrollController();
  final Map<int, ScrollController> _tabScrollControllers = {};

  // Animation controllers
  late final AnimationController _headerAnimationController;

  // Table data
  late final QRCodeData _tableData;

  // Cached widget references for preventing unnecessary rebuilds
  final Map<int, Widget> _cachedTabViews = {};
  bool _areTabViewsInitialized = false;

  // Track which feature tabs are enabled
  bool _showMealPlans = true;
  bool _showCatering = true;

  // List of tab indices
  final List<int> _enabledTabIndices = [];

  @override
  void initState() {
    super.initState();

    // Initialize table data
    _initializeTableData();

    // Default to showing all tabs, will be updated in didChangeDependencies
    _enabledTabIndices.addAll([0, 1, 2, 3]);

    // Setup controllers - initial length is 4, may be updated later
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Setup scroll controllers for each tab
    for (int i = 0; i < 4; i++) {
      _tabScrollControllers[i] = ScrollController();

      // Add a listener to update the shared scroll position provider
      _tabScrollControllers[i]!.addListener(() {
        if (_tabScrollControllers[i]!.hasClients) {
          ref.read(menuScrollOffsetProvider.notifier).state =
              _tabScrollControllers[i]!.offset;
        }
      });
    }

    // Main scroll controller
    _mainScrollController.addListener(() {
      if (_mainScrollController.hasClients) {
        ref.read(menuScrollOffsetProvider.notifier).state =
            _mainScrollController.offset;
      }
    });

    // Setup animation controller
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Setup listeners
    _searchController.addListener(_handleSearchChanges);
    _searchFocusNode.addListener(_handleFocusChanges);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get current business navigation info to identify the business
    final businessInfo = ref.watch(currentBusinessNavigationProvider);
    final String? businessSlug = businessInfo?.businessSlug;

    // Update feature flags based on business configuration
    if (businessSlug != null) {
      // Get business features from provider
      final businessFeaturesAsync =
          ref.watch(businessFeaturesProvider(businessSlug));

      // Update flags based on features
      businessFeaturesAsync.whenData((features) {
        if (mounted) {
          final shouldUpdateTabs = _showMealPlans != features.mealPlans ||
              _showCatering != features.catering;

          setState(() {
            _showMealPlans = features.mealPlans;
            _showCatering = features.catering;

            // Recalculate enabled tabs
            _enabledTabIndices.clear();
            _enabledTabIndices.add(0); // Menu tab always enabled

            if (_showMealPlans) _enabledTabIndices.add(1);
            if (_showCatering) _enabledTabIndices.add(2);
            _enabledTabIndices
                .add(_enabledTabIndices.length); // Deals tab is always the last

            // Recreate tab controller if needed
            if (shouldUpdateTabs) {
              _tabController.dispose();
              _tabController =
                  TabController(length: _enabledTabIndices.length, vsync: this);
              _tabController.addListener(_handleTabChange);
              _areTabViewsInitialized = false;
            }
          });

          debugPrint(
              '🍽 Menu features updated - Meal Plans: $_showMealPlans, Catering: $_showCatering');
        }
      });
    }

    // Initialize tab views after dependencies are available
    if (!_areTabViewsInitialized) {
      _initCachedTabViews();
    }
  }

  void _initCachedTabViews() {
    // Ensure _tableData is initialized
    setState(() {
      _cachedTabViews.clear();

      // Calculate which tab indices to use
      final List<int> tabIndices = [];
      tabIndices.add(0); // Menu tab always enabled at index 0

      // Add other tabs based on feature flags
      int indexCounter = 1;

      // Add meal plans tab if enabled
      if (_showMealPlans) {
        tabIndices.add(indexCounter);
        indexCounter++;
      }

      // Add catering tab if enabled
      if (_showCatering) {
        tabIndices.add(indexCounter);
        indexCounter++;
      }

      // Add deals tab at the end
      tabIndices.add(indexCounter);

      // Create each tab view with a separate scroll controller
      for (int i = 0; i < tabIndices.length; i++) {
        // Create appropriate scroll controller if needed
        if (!_tabScrollControllers.containsKey(i)) {
          _tabScrollControllers[i] = ScrollController();
          _tabScrollControllers[i]!.addListener(() {
            if (_tabScrollControllers[i]!.hasClients) {
              ref.read(menuScrollOffsetProvider.notifier).state =
                  _tabScrollControllers[i]!.offset;
            }
          });
        }
      }

      // Menu tab is always at index 0
      _cachedTabViews[0] = CategoryView(
        scrollController: _tabScrollControllers[0]!,
        tableData: _tableData,
      );

      int viewIndex = 1;

      // Add Meal Plans tab if enabled
      if (_showMealPlans) {
        _cachedTabViews[viewIndex] = MealPlansView(
          scrollController: _tabScrollControllers[viewIndex]!,
        );
        viewIndex++;
      }

      // Add Catering tab if enabled
      if (_showCatering) {
        _cachedTabViews[viewIndex] = CateringView(
          scrollController: _tabScrollControllers[viewIndex]!,
        );
        viewIndex++;
      }

      // Special Offers is always the last tab
      _cachedTabViews[viewIndex] = SpecialOffersView(
        scrollController: _tabScrollControllers[viewIndex]!,
      );

      _areTabViewsInitialized = true;

      debugPrint(
          '🧩 Menu tabs initialized - Total tabs: ${_cachedTabViews.length}');
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _searchController.removeListener(_handleSearchChanges);
    _searchController.dispose();
    _searchFocusNode.removeListener(_handleFocusChanges);
    _searchFocusNode.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _mainScrollController.dispose();

    // Dispose all tab scroll controllers
    for (final controller in _tabScrollControllers.values) {
      controller.dispose();
    }

    _headerAnimationController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      ref.read(menuActiveTabProvider.notifier).state = _tabController.index;
    }
  }

  void _handleFocusChanges() {
    ref.read(searchFocusProvider.notifier).state = _searchFocusNode.hasFocus;
  }

  void _handleSearchChanges() {
    final newText = _searchController.text;
    final isNowSearching = newText.isNotEmpty;

    if (_isSearching != isNowSearching) {
      setState(() {
        _isSearching = isNowSearching;
      });
      ref.read(searchQueryProvider.notifier).state = newText;
    }
  }

  void _initializeTableData() {
    try {
      _tableData = QRCodeData(
        tableId: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'Takeaway',
        restaurantId: 'restaurant-123',
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      // Show an error snackbar after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });

      // Fallback data
      _tableData = QRCodeData(
        tableId: 'default',
        tableName: 'Default',
        restaurantId: 'default',
        generatedAt: DateTime.now(),
      );
    }
  }

  Future<void> _handleSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    try {
      // Add to recent searches
      ref.read(menuRecentSearchesProvider.notifier).addSearch(query);

      setState(() {
        _isSearching = true;
      });

      ref.read(searchQueryProvider.notifier).state = query;
      FocusScope.of(context).unfocus();
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    ref.read(searchQueryProvider.notifier).state = '';
  }

  Future<void> _handleFilterTap() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  // Controller methods are defined above

  void _showSearchInterface() {
    if (!mounted) return;

    // Enable tabs when search interface is dismissed
    ref.read(tabsEnabledProvider.notifier).state = false;

    // Calculate proper position
    final appBarHeight =
        AppBar().preferredSize.height + MediaQuery.paddingOf(context).top;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: appBarHeight),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return MenuSearchInterface(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _handleSearchSubmitted,
              onFilterPressed: _handleFilterTap,
              onClear: _clearSearch,
              isSearching: _isSearching,
              searchResults: _isSearching
                  ? SearchResultsView(
                      key: const ValueKey('search'),
                      searchQuery: ref.watch(searchQueryProvider),
                      onClearSearch: _clearSearch,
                    )
                  : null,
            );
          },
        ),
      ),
    ).then((_) {
      // Re-enable tabs when search is dismissed
      ref.read(tabsEnabledProvider.notifier).state = true;
    });
  }

  Widget _buildTabView(int index) {
    // If tab views aren't initialized yet, try to initialize them
    if (!_areTabViewsInitialized) {
      _initCachedTabViews();
    }

    // Return cached view if available, using a notification listener to capture scroll events
    return _cachedTabViews.containsKey(index)
        ? _cachedTabViews[index]!
        : Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
  }

  // Improved header with smooth transitions, using the global scroll provider
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get the current scroll offset from the shared provider
    final scrollOffset = ref.watch(menuScrollOffsetProvider);

    // Calculate opacity based on scroll position
    // Header starts hiding immediately as scrolling begins
    final headerOpacity =
        1.0 - (scrollOffset / _headerThreshold).clamp(0.0, 1.0);

    // Calculate header offset for parallax effect
    final headerOffset = -scrollOffset * _parallaxFactor;

    return Opacity(
      opacity: headerOpacity,
      child: Transform.translate(
        offset: Offset(0, headerOffset),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background design elements
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.onPrimary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // Progress indicator
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 2,
                  color: colorScheme.onPrimary.withOpacity(0.5),
                  width: MediaQuery.of(context).size.width *
                      (scrollOffset / (_headerThreshold * 2)).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeTabIndex = ref.watch(menuActiveTabProvider);
    final cartItemCount = ref.watch(cartProvider).items.length;

    // Get scroll offset from the shared provider
    final scrollOffset = ref.watch(menuScrollOffsetProvider);

    // Update TabController when activeTabIndex changes
    if (_tabController.index != activeTabIndex) {
      _tabController.animateTo(activeTabIndex);
    }

    // Calculate app bar properties based on scroll position
    final scrollProgress = (scrollOffset / _headerThreshold).clamp(0.0, 1.0);
    final appBarBgColor = ColorTween(
      begin: Colors.transparent,
      end: colorScheme.surface.withOpacity(0.97),
    ).transform(scrollProgress)!;

    final appBarFgColor = ColorTween(
      begin: colorScheme.onPrimary,
      end: colorScheme.onSurface,
    ).transform(scrollProgress)!;

    // Define our main scaffold
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        // Use SafeArea to prevent UI elements from being blocked by system UI
        top: false, // Let the content extend behind the status bar
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: scrollProgress > 0.5
              ? SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: colorScheme.surface,
                )
              : SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: colorScheme.surface,
                ),
          child: Stack(
            children: [
              // Header background - placed at bottom of stack
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(),
              ),

              // Use a simple Column layout with CustomScrollView
              Column(
                children: [
                  // App bar with search and cart buttons
                  Container(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    decoration: BoxDecoration(
                      color: appBarBgColor,
                      boxShadow: scrollProgress > 0.5
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Title with icon
                        Expanded(
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 32 + ((1 - scrollProgress) * 4),
                                width: 32 + ((1 - scrollProgress) * 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.1 + ((1 - scrollProgress) * 0.1)),
                                      blurRadius:
                                          4 + ((1 - scrollProgress) * 4),
                                      spreadRadius:
                                          scrollProgress > 0.5 ? 0 : 1,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/appIcon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.restaurant,
                                          size: 24);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Opacity(
                                opacity: scrollProgress,
                                child: Text(
                                  'Menu',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: appBarFgColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        IconButton(
                          icon: Icon(Icons.search, color: appBarFgColor),
                          tooltip: 'Search',
                          onPressed: _showSearchInterface,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.shopping_cart_outlined,
                                    color: appBarFgColor),
                                tooltip: 'View cart',
                                onPressed: () {
                                  context.goNamed(AppRoute.homecart.name);
                                  HapticFeedback.selectionClick();
                                },
                              ),
                              if (cartItemCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      cartItemCount.toString(),
                                      style: TextStyle(
                                        color: colorScheme.onError,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                    child: MenuTabBar(
                      tabController: _tabController,
                      onTabChanged: (index) {
                        ref.read(menuActiveTabProvider.notifier).state = index;
                      },
                      showMealPlans: _showMealPlans,
                      showCatering: _showCatering,
                    ),
                  ),

                  // Tab content area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      // Add padding to top for more content space
                      padding: const EdgeInsets.only(top: 4),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // Update the shared scroll provider from any scroll events inside tabs
                            if (notification is ScrollUpdateNotification) {
                              ref
                                  .read(menuScrollOffsetProvider.notifier)
                                  .state = notification.metrics.pixels;
                            }
                            return false; // Continue propagating the notification
                          },
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(
                                4, (index) => _buildTabView(index)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Scroll to top button - visible when scrolling down
      // floatingActionButton: AnimatedSlide(
      //   duration: const Duration(milliseconds: 200),
      //   offset: scrollOffset > 100 ? Offset.zero : const Offset(0, 2),
      //   child: AnimatedOpacity(
      //     duration: const Duration(milliseconds: 200),
      //     opacity: scrollOffset > 100 ? 1.0 : 0.0,
      //     child: FloatingActionButton.small(
      //       onPressed: _scrollToTop,
      //       elevation: 4,
      //       tooltip: 'Scroll to top ',
      //       child: const Icon(Icons.keyboard_arrow_up),
      //     ),
      //   ),
      // ),
    );
  }
}
