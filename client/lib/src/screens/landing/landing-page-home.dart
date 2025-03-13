import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/catering-details-content.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/contact-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/content-sections.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/features-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/footer-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/hero-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/quick-access-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/reservation-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/restaurant-info-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/list_items/size_aware_widget.dart';


/// Enhanced responsive landing page for the restaurant app.
/// Integrates all restaurant features: menu, catering, reservations,
/// meal plans, and restaurant information in a cohesive design.
class ResponsiveLandingPage extends ConsumerStatefulWidget {
  const ResponsiveLandingPage({super.key});
 
  @override
  ConsumerState<ResponsiveLandingPage> createState() => _EnhancedLandingPageState();
}

class _EnhancedLandingPageState extends ConsumerState<ResponsiveLandingPage> 
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? randomDishes;
  bool _isLoading = true;
  String? _errorMessage;
  
  // For parallax header effect
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isScrolling = false;
  
  // For the tabs in the sections
  late TabController _sectionTabController;
  int _currentSectionTab = 0;
  
  // Catering packages data
  final List<Map<String, dynamic>> _cateringPackages = [
    {
      'title': 'Cocktail Party',
      'description': 'Perfect for small gatherings and celebrations',
      'price': 'S/ 500.00',
      'icon': Icons.wine_bar,
    },
    {
      'title': 'Corporate Lunch',
      'description': 'Ideal for business meetings and office events',
      'price': 'S/ 1000.00',
      'icon': Icons.business_center,
    },
    {
      'title': 'Wedding Reception',
      'description': 'Make your special day unforgettable with our gourmet service',
      'price': 'S/ 1500.00',
      'icon': Icons.celebration,
    },
    {
      'title': 'Custom Package',
      'description': 'Tell us your requirements for a personalized catering experience',
      'price': 'Starting at S/ 2000.00',
      'icon': Icons.settings,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomDishes();
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

  // Select random dishes with error handling.
  void _selectRandomDishes() {
    try {
      setState(() => _isLoading = true);
      final dishes = ref.read(dishProvider);
      if (dishes.isEmpty) {
        setState(() {
          _errorMessage = 'No se pudieron cargar los platos';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        randomDishes = dishes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando los platos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Navigate to the reservation screen
  void _navigateToReservation(BuildContext context) {
    // In a real app, this would navigate to the ReservationScreen
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
  void _showCateringDetails(BuildContext context, int packageIndex) {
    final package = _cateringPackages[packageIndex];
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
                    package['title'],
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
                      package['icon'],
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['description'],
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            package['price'],
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
                  packageTitle: package['title'],
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
    final appBarFgColor = _isScrolling
        ? colorScheme.onSurface
        : colorScheme.onPrimary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        foregroundColor: appBarFgColor,
        elevation: _isScrolling ? 1 : 0,
        title: AnimatedOpacity(
          opacity: _isScrolling ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Kako',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
      body: _errorMessage != null
          ? _buildErrorView()
          : _buildResponsiveLayout(isMobile, isTablet, isDesktop),
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

  Widget _buildResponsiveLayout(bool isMobile, bool isTablet, bool isDesktop) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async => _selectRandomDishes(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : NotificationListener<ScrollNotification>(
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
                      ContentSections(
                        tabController: _sectionTabController,
                        currentTab: _currentSectionTab,
                        randomDishes: randomDishes,
                        cateringPackages: _cateringPackages,
                        onCateringPackageTap: (index) => _showCateringDetails(context, index),
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
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

  // Error view for data loading errors
  Widget _buildErrorView() {
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
            _errorMessage ?? 'Ha ocurrido un error',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectRandomDishes,
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
