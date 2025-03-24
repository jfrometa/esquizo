import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_packages_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/featured_dishes_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/catering-details-content.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/contact-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/content-sections.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/features-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/footer-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/hero-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/quick-access-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/reservation-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/restaurant-info-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/list_items/size_aware_widget.dart';

class ResponsiveLandingPage extends ConsumerStatefulWidget {
  const ResponsiveLandingPage({super.key});

  @override
  ConsumerState<ResponsiveLandingPage> createState() =>
      _EnhancedLandingPageState();
}

class _EnhancedLandingPageState extends ConsumerState<ResponsiveLandingPage>
    with SingleTickerProviderStateMixin {
  // For parallax header effect
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isScrolling = false;

  // For the tabs in the sections
  late TabController _sectionTabController;
  int _currentSectionTab = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _sectionTabController = TabController(length: 4, vsync: this);
    _sectionTabController.addListener(() {
      setState(() {
        _currentSectionTab = _sectionTabController.index;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _sectionTabController.dispose();
    super.dispose();
  }

  // Scroll handler for parallax effect and header animation
  void _handleScroll() {
    final newOffset = _scrollController.offset;
    setState(() {
      _scrollOffset = newOffset;
      _isScrolling = newOffset > 10.0;
    });
  }

  // Navigate to the reservation screen
  void _navigateToReservation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ReservationSection(),
        ),
      ),
    );
  }

  // Show restaurant info sheet
  void _showRestaurantInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: RestaurantInfoSection(scrollController: scrollController),
        ),
      ),
    );
  }

  // Show catering details sheet
  void _showCateringDetails(
      BuildContext context, int packageIndex, CateringPackage package) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.food_bank,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.description,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            package.basePrice.toStringAsFixed(2),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: CateringDetailsContent(
                  packageTitle: package.name,
                  scrollController: scrollController,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to catering form
                    GoRouter.of(context).pushNamed(AppRoute.cateringMenu.name);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Request This Package'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isMobile = screenWidth <= 600;

    // Access theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Setup app bar styling
    final appBarBgColor = _isScrolling
        ? colorScheme.surface.withOpacity(0.97)
        : Colors.transparent;
    final appBarFgColor =
        _isScrolling ? colorScheme.onSurface : colorScheme.onPrimary;

    // Get business config
    final businessConfigAsync = ref.watch(businessConfigProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        elevation: _isScrolling ? 1 : 0,
        title: AnimatedOpacity(
          opacity: _isScrolling ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: businessConfigAsync.when(
            data: (config) => Text(
              config?.name ?? 'Restaurant',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => Text(
              'Restaurant',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Menu',
            onPressed: () => GoRouter.of(context).goNamed(AppRoute.home.name),
          ),
          IconButton(
            icon: const Icon(Icons.event_seat),
            tooltip: 'Reservations',
            onPressed: () => _navigateToReservation(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Information',
            onPressed: () => _showRestaurantInfo(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref.watch(featuredDishesProvider).when(
            data: (dishes) =>
                _buildResponsiveLayout(isMobile, isTablet, isDesktop, dishes),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorView(error.toString()),
          ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _scrollOffset > 100 ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrollOffset > 100 ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToReservation(context),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Reservar'),
            elevation: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return ResponsiveSection(
      mobileBuilder: const FeaturesSectionMobile(),
      tabletBuilder: const FeaturesSectionTablet(),
      desktopBuilder: const FeaturesSectionDesktop(),
    );
  }

  Widget _buildResponsiveLayout(
      bool isMobile, bool isTablet, bool isDesktop, List<CatalogItem> dishes) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async => ref.refresh(featuredDishesProvider),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              _handleScroll();
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Enhanced hero section with parallax effect
                EnhancedHeroSection(scrollOffset: _scrollOffset),

                // Quick access section
                QuickAccessSection(
                  onReserveTap: () => _navigateToReservation(context),
                  onInfoTap: () => _showRestaurantInfo(context),
                ),

                // Restaurant features section
                _buildFeaturesSection(context),

                // Main tabbed content section
                Consumer(
                  builder: (context, ref, child) {
                    final cateringPackagesAsync =
                        ref.watch(activePackagesProvider);

                    return cateringPackagesAsync.when(
                      data: (cateringPackages) => ContentSections(
                        tabController: _sectionTabController,
                        currentTab: _currentSectionTab,
                        randomDishes: dishes,
                        cateringPackages: cateringPackages,
                        onCateringPackageTap: (index) => _showCateringDetails(
                            context, index, cateringPackages[index]),
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      ),
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) {
                        // Log the error for debugging purposes
                        debugPrint('Error loading catering packages: $error');
                        if (kDebugMode) {
                          debugPrintStack(stackTrace: stackTrace);
                        }

                        return SizedBox(
                          height: 200,
                          child: Center(
                            child:
                                Text('Error loading data: ${error.toString()}'),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Contact section
                const EnhancedContactSection(),

                // Footer section
                const EnhancedFooterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(featuredDishesProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
