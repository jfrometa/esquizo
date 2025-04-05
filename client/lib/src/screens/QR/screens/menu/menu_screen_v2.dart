import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/cart/cart_service.dart';

import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/QR/models/qr_code_data.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/category_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/filter_bottom_sheet.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/meal_plans_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/search_results_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/special_offers_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_header.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_search_interface.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widget/menu_tab_bar.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/menu/menu_providers.dart';

 

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  // Scroll controllers for each tab
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _mealPlansScrollController = ScrollController();
  final ScrollController _cateringScrollController = ScrollController();
  final ScrollController _specialOffersScrollController = ScrollController();

  // Tab controller
  late final TabController _tabController;

  // QR code data
  late final QRCodeData _tableData;

  // Parallax effect variables
  double _scrollOffset = 0;
  bool _isScrolling = false;
  final _parallaxFactor = 0.5;

  // Animation controllers
  late final AnimationController _headerAnimationController;
  late final Animation<double> _headerOpacityAnimation;

  // Use keys to prevent unnecessary rebuilds
  final GlobalKey<MenuTabBarState> _tabBarKey = GlobalKey<MenuTabBarState>();
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // Initialize QR data immediately to avoid null checks
    _initializeTableData();
    
    // Lightweight listeners
    _searchController.addListener(_handleSearchChanges);
    _searchFocusNode.addListener(_handleFocusChanges);

    // Initialize TabController
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // More efficient approach: use a single scroll listener
    _setupScrollListeners();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _headerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _setupScrollListeners() {
    // Add a more efficient single listener to each controller
    _categoryScrollController.addListener(() => _handleScroll(_categoryScrollController));
    _mealPlansScrollController.addListener(() => _handleScroll(_mealPlansScrollController));
    _cateringScrollController.addListener(() => _handleScroll(_cateringScrollController));
    _specialOffersScrollController.addListener(() => _handleScroll(_specialOffersScrollController));
  }

  void _handleScroll(ScrollController controller) {
    if (!controller.hasClients) return;
    
    final newOffset = controller.offset;
    
    // Only update state if there's a meaningful change
    if ((newOffset - _scrollOffset).abs() > 0.5) {
      final wasScrolling = _isScrolling;
      final isNowScrolling = newOffset > 0;
      
      // Only setState if the scrolling state changed or significant movement
      if (wasScrolling != isNowScrolling || (newOffset - _scrollOffset).abs() > 5) {
        setState(() {
          _scrollOffset = newOffset;
          _isScrolling = isNowScrolling;
        });
        
        // Update animation state based on scroll position
        if (isNowScrolling && !_headerAnimationController.isAnimating) {
          _headerAnimationController.forward();
        } else if (!isNowScrolling && !_headerAnimationController.isAnimating) {
          _headerAnimationController.reverse();
        }
        
        // Update Riverpod state (do this less frequently)
        ref.read(scrollStateProvider.notifier).state = newOffset;
      }
    }
  }

  void _handleFocusChanges() {
    final hasFocus = _searchFocusNode.hasFocus;
    ref.read(searchFocusProvider.notifier).state = hasFocus;
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Update provider state when tab changes
      ref.read(menuActiveTabProvider.notifier).state = _tabController.index;
    }
  }

  ScrollController _getActiveScrollController(int index) {
    switch (index) {
      case 0:
        return _categoryScrollController;
      case 1:
        return _mealPlansScrollController;
      case 2:
        return _cateringScrollController;
      case 3:
        return _specialOffersScrollController;
      default:
        return _categoryScrollController;
    }
  }

  void _initializeTableData() {
    try {
      _tableData = QRCodeData(
        tableId: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: 'Takeaway',
        restaurantId: 'la-redonda-123',
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error initializing table data: $e');
      // Show a snackbar with the error (deferred to after build)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize table data: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
      
      // Initialize with default data to avoid null issues
      _tableData = QRCodeData(
        tableId: 'default',
        tableName: 'Default',
        restaurantId: 'default',
        generatedAt: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _searchController.removeListener(_handleSearchChanges);
    _searchController.dispose();
    _searchFocusNode.removeListener(_handleFocusChanges);
    _searchFocusNode.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _categoryScrollController.dispose();
    _mealPlansScrollController.dispose();
    _cateringScrollController.dispose();
    _specialOffersScrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _handleSearchChanges() {
    final newText = _searchController.text;
    final wasSearching = _isSearching;
    final isNowSearching = newText.isNotEmpty;
    
    // Only update if there's a change
    if (wasSearching != isNowSearching) {
      setState(() {
        _isSearching = isNowSearching;
      });
      ref.read(searchQueryProvider.notifier).state = newText;
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
      await HapticFeedback.selectionClick(); // lighter than mediumImpact
    } catch (e) {
      debugPrint('Error handling search: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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
    try {
      await HapticFeedback.selectionClick(); // lighter than lightImpact
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        builder: (context) => const FilterBottomSheet(),
      );
    } catch (e) {
      debugPrint('Error showing filter sheet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to show filters: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToTop() {
    final activeIndex = _tabController.index;
    final currentController = _getActiveScrollController(activeIndex);

    if (currentController.hasClients) {
      currentController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showSearchInterface() {
    if (!mounted) return;
    
    // Enable tabs when search interface is dismissed
    ref.read(tabsEnabledProvider.notifier).state = true;
    
    // Position the bottom sheet below the app bar
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: appBarHeight), // Prevent overlapping the app bar
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            // Disable tabs while search is active
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(tabsEnabledProvider.notifier).state = false;
            });
            
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeTabIndex = ref.watch(menuActiveTabProvider);
    final cartItemCount = ref.watch(cartProvider).items.length;
    
    // Update TabController when activeTabIndex changes (without rebuilding)
    if (_tabController.index != activeTabIndex) {
      _tabController.animateTo(activeTabIndex);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _isScrolling
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Parallax header component with key for efficient updates
              RepaintBoundary(
                child: MenuHeader(
                  key: _headerKey,
                  scrollOffset: _scrollOffset,
                  isScrolling: _isScrolling,
                  parallaxFactor: _parallaxFactor,
                  opacityAnimation: _headerOpacityAnimation,
                ),
              ),

              // Main content
              NestedScrollView(
                controller: _getActiveScrollController(activeTabIndex),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // App bar with search button
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      snap: false,
                      elevation: 0,
                      scrolledUnderElevation: 2,
                      expandedHeight: 120,
                      backgroundColor: _isScrolling
                          ? colorScheme.surface.withOpacity(0.97)
                          : Colors.transparent,
                      foregroundColor: _isScrolling
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary,
                      title: AnimatedOpacity(
                        opacity: _isScrolling ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSlide(
                          offset: _isScrolling 
                              ? Offset.zero 
                              : const Offset(0, 0.5),
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'Menu',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        // Search icon to open search interface
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Search',
                          onPressed: _showSearchInterface,
                        ),
                        // Cart icon with badge
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined),
                                tooltip: 'View cart',
                                onPressed: () {
                                  context.pushNamed(AppRoute.homecart.name);
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
                      flexibleSpace: FlexibleSpaceBar(
                        background: SafeArea(
                          child: AnimatedAlign(
                            alignment: _isScrolling 
                                ? const Alignment(0.0, 0.2)
                                : Alignment.bottomCenter,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              height: _isScrolling ? 48 : 56,
                              width: _isScrolling ? 48 : 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(_isScrolling ? 0.1 : 0.2),
                                    blurRadius: _isScrolling ? 4 : 8,
                                    spreadRadius: _isScrolling ? 0 : 1,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Column(
                  children: [
                    // Enhanced tab bar with toggle flag
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: RepaintBoundary(
                        child: MenuTabBar(
                          key: _tabBarKey,
                          tabController: _tabController,
                          onTabChanged: (index) {
                            ref.read(menuActiveTabProvider.notifier).state = index;
                          },
                        ),
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: DecoratedBox(
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
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Wrap each view in RepaintBoundary to optimize rendering
                              RepaintBoundary(
                                child: CategoryView(
                                  scrollController: _categoryScrollController,
                                  tableData: _tableData,
                                ),
                              ),
                              RepaintBoundary(
                                child: MealPlansView(
                                  scrollController: _mealPlansScrollController,
                                ),
                              ),
                              RepaintBoundary(
                                child: CateringView(
                                  scrollController: _cateringScrollController,
                                ),
                              ),
                              RepaintBoundary(
                                child: SpecialOffersView(
                                  scrollController: _specialOffersScrollController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _scrollOffset > 100 ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrollOffset > 100 ? 1.0 : 0.0,
          child: FloatingActionButton.small(
            onPressed: _scrollToTop,
            elevation: 4,
            enableFeedback: true,
            tooltip: 'Scroll to top',
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        ),
      ),
    );
  }
}