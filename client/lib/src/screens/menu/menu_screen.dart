import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_search_interface.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_tab_bar.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

// Import all the necessary files from your project
import '../QR/models/qr_code_data.dart';
import '../../core/providers/menu/menu_providers.dart';
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
  late final Animation<double> _headerOpacityAnimation;

  // Table data
  late final QRCodeData _tableData;

  // Cached widget references for preventing unnecessary rebuilds
  final Map<int, Widget> _cachedTabViews = {};
  bool _areTabViewsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize table data
    _initializeTableData();

    // Setup controllers
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

    _headerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Setup listeners
    _searchController.addListener(_handleSearchChanges);
    _searchFocusNode.addListener(_handleFocusChanges);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize tab views after dependencies are available
    if (!_areTabViewsInitialized) {
      _initCachedTabViews();
    }
  }

  void _initCachedTabViews() {
    // Ensure _tableData is initialized
    setState(() {
      // Create each tab view with a separate scroll controller
      _cachedTabViews[0] = CategoryView(
        scrollController: _tabScrollControllers[0]!,
        tableData: _tableData,
      );
      _cachedTabViews[1] = MealPlansView(
        scrollController: _tabScrollControllers[1]!,
      );
      _cachedTabViews[2] = CateringView(
        scrollController: _tabScrollControllers[2]!,
      );
      _cachedTabViews[3] = SpecialOffersView(
        scrollController: _tabScrollControllers[3]!,
      );

      _areTabViewsInitialized = true;
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

  void _scrollToTop() {
    final activeIndex = _tabController.index;
    final controller = _tabScrollControllers[activeIndex];

    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

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
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: scrollOffset > 100 ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: scrollOffset > 100 ? 1.0 : 0.0,
          child: FloatingActionButton.small(
            onPressed: _scrollToTop,
            elevation: 4,
            tooltip: 'Scroll to top',
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        ),
      ),
    );
  }
}
