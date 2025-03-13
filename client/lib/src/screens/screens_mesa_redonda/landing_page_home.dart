 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/ordering_providers.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart'; 
// import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/dish_item.dart';
// import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/list_items/size_aware_widget.dart';
// import 'package:url_launcher/url_launcher.dart';


// // // Provider for dish data used in _selectRandomDishes() method
// // final dishProvider = Provider<List<Map<String, dynamic>>>((ref) {
// //   // Implementation that provides the list of dishes
// //   return [
// //     // Sample dish data structure
// //     {
// //       'title': 'Sample Dish',
// //       'description': 'Description of the dish',
// //       'pricing': 'S/ 25.00',
// //       'img': 'image_url',
// //       'ingredients': <String>['Ingredient 1', 'Ingredient 2'],
// //       'isSpicy': false,
// //       'foodType': 'Main',
// //     },
// //     // Additional dishes would be added here
// //   ];
// // });

// // Meal Plan data class
// // class MealPlan {
// //   final String id;
// //   final String title;
// //   final String description;
// //   final String price;
  
// //   const MealPlan({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.price,
// //   });
// // }

// // // Provider for meal plans data used in MealPlansSection
// // final mealPlansProvider = Provider<List<MealPlan>>((ref) {
// //   return [
// //     MealPlan(
// //       id: 'plan1',
// //       title: 'Plan Básico',
// //       description: 'Ideal para individuos o parejas, incluye 5 comidas a la semana',
// //       price: 'S/ 149.99/semana',
// //     ),
// //     MealPlan(
// //       id: 'plan2',
// //       title: 'Plan Familiar',
// //       description: 'Perfecto para familias, incluye 10 comidas a la semana',
// //       price: 'S/ 259.99/semana',
// //     ),
// //     MealPlan(
// //       id: 'plan3',
// //       title: 'Plan Ejecutivo',
// //       description: 'Comidas gourmet para profesionales ocupados, 7 almuerzos a la semana',
// //       price: 'S/ 199.99/semana',
// //     ),
// //   ];
// // });

// // Widget for displaying meal plan cards in MealPlansSection
// class PlanCard extends StatelessWidget {
//   final String planName;
//   final String description;
//   final String price;
//   final String planId;

//   const PlanCard({
//     Key? key,
//     required this.planName,
//     required this.description,
//     required this.price,
//     required this.planId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: colorScheme.secondaryContainer,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text(
//                 planName,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSecondaryContainer,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               description,
//               style: theme.textTheme.bodyMedium,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height:16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   price,
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.primary,
//                     foregroundColor: colorScheme.onPrimary,
//                   ),
//                   child: const Text('Suscribir'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Enhanced responsive landing page for the restaurant app.
// /// Integrates all restaurant features: menu, catering, reservations,
// /// meal plans, and restaurant information in a cohesive design.
// class ResponsiveLandingPage extends ConsumerStatefulWidget {
//   const ResponsiveLandingPage({super.key});
 

//   @override
//   ConsumerState<ResponsiveLandingPage> createState() => _EnhancedLandingPageState();
// }

// class _EnhancedLandingPageState extends ConsumerState<ResponsiveLandingPage> 
//     with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>>? randomDishes;
//   bool _isLoading = true;
//   String? _errorMessage;
  
//   // For parallax header effect
//   final ScrollController _scrollController = ScrollController();
//   double _scrollOffset = 0;
//   bool _isScrolling = false;
  
//   // For the tabs in the sections
//   late TabController _sectionTabController;
//   int _currentSectionTab = 0;
  
//   // Catering packages data
//   final List<Map<String, dynamic>> _cateringPackages = [
//     {
//       'title': 'Cocktail Party',
//       'description': 'Perfect for small gatherings and celebrations',
//       'price': 'S/ 500.00',
//       'icon': Icons.wine_bar,
//     },
//     {
//       'title': 'Corporate Lunch',
//       'description': 'Ideal for business meetings and office events',
//       'price': 'S/ 1000.00',
//       'icon': Icons.business_center,
//     },
//     {
//       'title': 'Wedding Reception',
//       'description': 'Make your special day unforgettable with our gourmet service',
//       'price': 'S/ 1500.00',
//       'icon': Icons.celebration,
//     },
//     {
//       'title': 'Custom Package',
//       'description': 'Tell us your requirements for a personalized catering experience',
//       'price': 'Starting at S/ 2000.00',
//       'icon': Icons.settings,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _selectRandomDishes();
//     _scrollController.addListener(_handleScroll);
//     _sectionTabController = TabController(length: 4, vsync: this);
//     _sectionTabController.addListener(() {
//       setState(() {
//         _currentSectionTab = _sectionTabController.index;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     _sectionTabController.dispose();
//     super.dispose();
//   }

//   // Scroll handler for parallax effect and header animation
//   void _handleScroll() {
//     final newOffset = _scrollController.offset;
//     setState(() {
//       _scrollOffset = newOffset;
//       _isScrolling = newOffset > 10.0;
//     });
//   }

//   // Select random dishes with error handling.
//   void _selectRandomDishes() {
//     try {
//       setState(() => _isLoading = true);
//       final dishes = ref.read(dishProvider);
//       if (dishes.isEmpty) {
//         setState(() {
//           _errorMessage = 'No se pudieron cargar los platos';
//           _isLoading = false;
//         });
//         return;
//       }
//       setState(() {
//         randomDishes = dishes;
//         _isLoading = false;
//         _errorMessage = null;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error cargando los platos: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   // Navigate to the reservation screen
//   void _navigateToReservation(BuildContext context) {
//     // In a real app, this would navigate to the ReservationScreen
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: const ReservationSection(),
//         ),
//       ),
//     );
//   }

//   // Show restaurant info sheet
//   void _showRestaurantInfo(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           padding: const EdgeInsets.all(20),
//           child: RestaurantInfoSection(scrollController: scrollController),
//         ),
//       ),
//     );
//   }

//   // Show catering details sheet
//   void _showCateringDetails(BuildContext context, int packageIndex) {
//     final package = _cateringPackages[packageIndex];
//     final theme = Theme.of(context);
    
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     package['title'],
//                     style: theme.textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 20),
              
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primaryContainer.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       package['icon'],
//                       size: 40,
//                       color: theme.colorScheme.primary,
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             package['description'],
//                             style: theme.textTheme.bodyLarge,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             package['price'],
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               Expanded(
//                 child: CateringDetailsContent(
//                   packageTitle: package['title'],
//                   scrollController: scrollController,
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Navigate to catering form
//                     GoRouter.of(context).pushNamed(AppRoute.cateringMenu.name);
//                     // ScaffoldMessenger.of(context).showSnackBar(
//                     //   SnackBar(
//                     //     content: const Text('Navigating to catering request form'),
//                     //     behavior: SnackBarBehavior.floating,
//                     //     backgroundColor: theme.colorScheme.primary,
//                     //   ),
//                     // );
//                   },
//                   icon: const Icon(Icons.send),
//                   label: const Text('Request This Package'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: theme.colorScheme.primary,
//                     foregroundColor: theme.colorScheme.onPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final isDesktop = screenWidth > 1024;
//     final isTablet = screenWidth > 600 && screenWidth <= 1024;
//     final isMobile = screenWidth <= 600;

//     // Access theme data
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     // Setup app bar styling 
//     final appBarBgColor = _isScrolling
//         ? colorScheme.surface.withOpacity(0.97)
//         : Colors.transparent;
//     final appBarFgColor = _isScrolling
//         ? colorScheme.onSurface
//         : colorScheme.onPrimary;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: appBarBgColor,
//         foregroundColor: appBarFgColor,
//         elevation: _isScrolling ? 1 : 0,
//         title: AnimatedOpacity(
//           opacity: _isScrolling ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 200),
//           child: Text(
//             'Kako',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.restaurant_menu),
//             tooltip: 'Menu',
//             onPressed: () => GoRouter.of(context).goNamed(AppRoute.home.name),
//           ),
//           IconButton(
//             icon: const Icon(Icons.event_seat),
//             tooltip: 'Reservations',
//             onPressed: () => _navigateToReservation(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             tooltip: 'Information',
//             onPressed: () => _showRestaurantInfo(context),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: _errorMessage != null
//           ? _buildErrorView()
//           : _buildResponsiveLayout(isMobile, isTablet, isDesktop),
//       floatingActionButton: AnimatedSlide(
//         duration: const Duration(milliseconds: 200),
//         offset: _scrollOffset > 100 ? Offset.zero : const Offset(0, 2),
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 200),
//           opacity: _scrollOffset > 100 ? 1.0 : 0.0,
//           child: FloatingActionButton.extended(
//             onPressed: () => _navigateToReservation(context),
//             icon: const Icon(Icons.calendar_today),
//             label: const Text('Reservar'),
//             elevation: 4,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeaturesSection(BuildContext context) {
//   return ResponsiveSection(
//     mobileBuilder: const FeaturesSectionMobile(),
//     tabletBuilder: const FeaturesSectionTablet(),
//     desktopBuilder: const FeaturesSectionDesktop(),
//   );
// }

//   Widget _buildResponsiveLayout(bool isMobile, bool isTablet, bool isDesktop) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: RefreshIndicator(
//         onRefresh: () async => _selectRandomDishes(),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : NotificationListener<ScrollNotification>(
//                 onNotification: (notification) {
//                   if (notification is ScrollUpdateNotification) {
//                     _handleScroll();
//                   }
//                   return false;
//                 },
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     children: [
//                       // Enhanced hero section with parallax effect
//                       EnhancedHeroSection(scrollOffset: _scrollOffset),
                      
//                       // Quick access section
//                       QuickAccessSection(
//                         onReserveTap: () => _navigateToReservation(context),
//                         onInfoTap: () => _showRestaurantInfo(context),
//                       ),
                      
//                       // Restaurant features section
//                       // if (isMobile) 
//                       //   const FeaturesSectionMobile()
//                       // else if (isTablet) 
//                       //   const FeaturesSectionTablet()
//                       // else 
//                       //   const FeaturesSectionDesktop(),

//                       _buildFeaturesSection(context),
                      
//                       // Main tabbed content section
//                       ContentSections(
//                         tabController: _sectionTabController,
//                         currentTab: _currentSectionTab,
//                         randomDishes: randomDishes,
//                         cateringPackages: _cateringPackages,
//                         onCateringPackageTap: (index) => _showCateringDetails(context, index),
//                         isMobile: isMobile,
//                         isTablet: isTablet,
//                         isDesktop: isDesktop,
//                       ),
                      
//                       // Contact section
//                       const EnhancedContactSection(),
                      
//                       // Footer section
//                       const EnhancedFooterSection(),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   // Error view for data loading errors
//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Theme.of(context).colorScheme.error,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _errorMessage ?? 'Ha ocurrido un error',
//             style: Theme.of(context).textTheme.titleLarge,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _selectRandomDishes,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//             ),
//             child: const Text('Reintentar'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 1. Optimize ParallaxHeader with RepaintBoundary
// class EnhancedHeroSection extends StatelessWidget {
//   final double scrollOffset;
  
//   const EnhancedHeroSection({
//     super.key,
//     required this.scrollOffset,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     // Height calculation with parallax effect
//     final heroHeight = isMobile ? size.height * 0.85 : size.height * 0.75;
//     final parallaxOffset = scrollOffset * 0.4;
    
//     return Container(
//       width: double.infinity,
//       height: heroHeight,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: colorScheme.primary,
//       ),
//       child: Stack(
//         children: [
//           // Background image with parallax effect - Wrapped in RepaintBoundary for better performance
          
//              Positioned(
//               top: -parallaxOffset.clamp(0.0, 100.0),
//               left: 0,
//               right: 0,
//               height: heroHeight + 100, // Extra height for parallax
//               child: RepaintBoundary(
//                 child: ShaderMask(
//                   shaderCallback: (Rect bounds) {
//                     return LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.7),
//                         Colors.black.withOpacity(0.5),
//                       ],
//                     ).createShader(bounds);
//                   },
//                   blendMode: BlendMode.srcOver,
//                   // Use the OptimizedNetworkImage for better image loading
//                   child: SizedBox.shrink()
                  
//                   //  OptimizedNetworkImage(
//                   //   imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
//                   //   width: double.infinity,
//                   //   height: double.infinity,
//                   //   fit: BoxFit.cover,
//                   //   backgroundColor: colorScheme.primary,
//                   // ),
//                 ),
//               ),
//             ),
          
          
//           // Gradient overlay
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   colorScheme.primary.withOpacity(0.3),
//                   colorScheme.primary.withOpacity(0.7),
//                 ],
//               ),
//             ),
//           ),
          
//           // Content
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo or icon
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     // child: Icon(
//                     //   Icons.restaurant,
//                     //   size: 60,
//                     //   color: colorScheme.primary,
//                     // ),
//                       child: ClipOval(
//                       child: Image.asset(
//                         'assets/appicon.png',
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Kako',
//                     style: textTheme.displaySmall?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: isMobile ? 36 : 48,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Experiencia Gastronómica Excepcional',
//                     style: textTheme.headlineSmall?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w300,
//                       fontSize: isMobile ? 18 : 24,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
//                     style: textTheme.bodyLarge?.copyWith(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: isMobile ? 14 : 18,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: () => context.goNamed(AppRoute.home.name),
//                         icon: const Icon(Icons.restaurant_menu),
//                         label: const Text('Ver Menú'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: colorScheme.primary,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Scroll indicator at bottom - Only build if needed (performance optimization)
//           if (scrollOffset < 10)
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: AnimatedOpacity(
//                   opacity: scrollOffset < 10 ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Explorar',
//                         style: textTheme.bodyMedium?.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
        
//         ],
//       ),
//     );
    
//   }
// }
// /// Quick access section with cards for main features
// class QuickAccessSection extends StatelessWidget {
//   final VoidCallback onReserveTap;
//   final VoidCallback onInfoTap;
  
//   const QuickAccessSection({
//     super.key,
//     required this.onReserveTap,
//     required this.onInfoTap,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     return Container(
//       width: double.infinity,
//       color: colorScheme.surface,
//       padding: EdgeInsets.symmetric(
//         vertical: 24,
//         horizontal: isMobile ? 16 : 32,
//       ),
//       child: Column(
//         children: [
//           Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             alignment: WrapAlignment.center,
//             children: [
              
//               _buildQuickAccessCard(
//                   context,
//                   title: 'Reservar Mesa',
//                   icon: Icons.calendar_today,
//                   description: 'Reserve su mesa para una experiencia gastronómica inolvidable',
//                   onTap: onReserveTap,
//                   color: colorScheme.primaryContainer,
//                 ),
               
               
//                   _buildQuickAccessCard(
//                   context,
//                   title: 'Nuestro Menú',
//                   icon: Icons.restaurant_menu,
//                   description: 'Descubra nuestra variedad de platos exquisitos',
//                   onTap: () => context.goNamed(AppRoute.home.name),
//                   color: colorScheme.secondaryContainer,
//                 ),
               
//               _buildQuickAccessCard(
//                   context,
//                   title: 'Catering',
//                   icon: Icons.celebration,
//                   description: 'Servicios de catering para eventos especiales',
//                   onTap: () => context.goNamed(AppRoute.cateringMenuE.name),
//                   color: colorScheme.tertiaryContainer,
             
//               ),
              
//                  _buildQuickAccessCard(
//                   context,
//                   title: 'Información',
//                   icon: Icons.info_outline,
//                   description: 'Conozca más sobre nosotros, ubicación y horarios',
//                   onTap: onInfoTap,
//                   color: colorScheme.surfaceVariant,
//                 ),
              
            
            
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
// Widget _buildQuickAccessCard(
//   BuildContext context, {
//   required String title,
//   required IconData icon,
//   required String description,
//   required VoidCallback onTap,
//   required Color color,
// }) {
//   final theme = Theme.of(context);
//   final size = MediaQuery.sizeOf(context);
//   final isMobile = size.width < 600;
  
//   return InkWell(
//     onTap: onTap,
//     borderRadius: BorderRadius.circular(16),
//     child: Container(
//        width: isMobile ? double.infinity : 220,
//       // ADD THIS HEIGHT CONSTRAINT:
       
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.5),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min, // This is important!
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             size: 36,
//             color: color,
//           ),
//           const SizedBox(height: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 description,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.7),
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }


// }

// /// Features section showcasing restaurant perks/values for mobile
// class FeaturesSectionMobile extends StatelessWidget {
//   const FeaturesSectionMobile({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     const features = [
//       {
//         'title': 'Ingredientes Frescos',
//         'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
//         'icon': Icons.eco,
//       },
//       {
//         'title': 'Presentación Exquisita',
//         'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
//         'icon': Icons.palette,
//       },
//       {
//         'title': 'Servicio Personalizado',
//         'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
//         'icon': Icons.person,
//       },
//       {
//         'title': 'Ambiente Acogedor',
//         'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
//         'icon': Icons.home,
//       },
//     ];
    
//     return Container(
//       color: colorScheme.background,
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//       child: Column(
//         children: [
//           Text(
//             '¿Por qué Elegirnos?',
//             style: theme.textTheme.headlineMedium?.copyWith(
//               color: colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: features.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final feature = features[index];
//               return Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primaryContainer.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           feature['icon'] as IconData,
//                           size: 36,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               feature['title'] as String,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               feature['description'] as String,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.7),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Features section showcasing restaurant perks/values for tablet
// class FeaturesSectionTablet extends StatelessWidget {
//   const FeaturesSectionTablet({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     const features = [
//       {
//         'title': 'Ingredientes Frescos',
//         'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
//         'icon': Icons.eco,
//       },
//       {
//         'title': 'Presentación Exquisita',
//         'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
//         'icon': Icons.palette,
//       },
//       {
//         'title': 'Servicio Personalizado',
//         'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
//         'icon': Icons.person,
//       },
//       {
//         'title': 'Ambiente Acogedor',
//         'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
//         'icon': Icons.home,
//       },
//     ];
    
//     return Container(
//       color: colorScheme.background,
//       padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
//       child: Column(
//         children: [
//           Text(
//             '¿Por qué Elegirnos?',
//             style: theme.textTheme.headlineMedium?.copyWith(
//               color: colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 40),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1.3,
//               crossAxisSpacing: 20,
//               mainAxisSpacing: 20,
//             ),
//             itemCount: features.length,
//             itemBuilder: (context, index) {
//               final feature = features[index];
//               return Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primaryContainer.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           feature['icon'] as IconData,
//                           size: 40,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         feature['title'] as String,
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         feature['description'] as String,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Features section showcasing restaurant perks/values for desktop
// class FeaturesSectionDesktop extends StatelessWidget {
//   const FeaturesSectionDesktop({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     const features = [
//       {
//         'title': 'Ingredientes Frescos',
//         'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
//         'icon': Icons.eco,
//       },
//       {
//         'title': 'Presentación Exquisita',
//         'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
//         'icon': Icons.palette,
//       },
//       {
//         'title': 'Servicio Personalizado',
//         'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
//         'icon': Icons.person,
//       },
//       {
//         'title': 'Ambiente Acogedor',
//         'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
//         'icon': Icons.home,
//       },
//     ];
    
//     return Container(
//       color: colorScheme.background,
//       padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
//       child: Column(
//         children: [
//           Text(
//             '¿Por qué Elegirnos?',
//             style: theme.textTheme.displaySmall?.copyWith(
//               color: colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Nos esforzamos por ofrecer experiencias gastronómicas excepcionales',
//             style: theme.textTheme.titleLarge?.copyWith(
//               color: colorScheme.onBackground.withOpacity(0.7),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 64),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: features.map((feature) {
//               return Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: colorScheme.primaryContainer.withOpacity(0.4),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           feature['icon'] as IconData,
//                           size: 40,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         feature['title'] as String,
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         feature['description'] as String,
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.7),
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Main content sections with tabs (Menu, Meal Plans, Catering, Reservations)
// /// Main content sections with tabs (Menu, Meal Plans, Catering, Reservations)
// class ContentSections extends StatelessWidget {
//   final TabController tabController;
//   final int currentTab;
//   final List<Map<String, dynamic>>? randomDishes;
//   final List<Map<String, dynamic>> cateringPackages;
//   final Function(int) onCateringPackageTap;
//   final bool isMobile;
//   final bool isTablet;
//   final bool isDesktop;
  
//   const ContentSections({
//     super.key,
//     required this.tabController,
//     required this.currentTab,
//     required this.randomDishes,
//     required this.cateringPackages,
//     required this.onCateringPackageTap,
//     required this.isMobile,
//     required this.isTablet,
//     required this.isDesktop,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Container(
//       color: colorScheme.surface,
//       padding: const EdgeInsets.only(top: 40),
//       child: Column(
//         children: [
//           // Tab bar
//           Container(
//             margin: EdgeInsets.symmetric(
//               horizontal: isMobile ? 16 : 32,
//             ),
//             decoration: BoxDecoration(
//               color: colorScheme.surfaceVariant.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: TabBar(
//               controller: tabController,
//               indicator: BoxDecoration(
//                 color: colorScheme.primary,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               labelColor: colorScheme.onPrimary,
//               unselectedLabelColor: colorScheme.onSurfaceVariant,
//               dividerHeight: 0,
//               isScrollable: false, // Make sure tabs are not scrollable
//               tabAlignment: TabAlignment.fill, // Make tabs take up equal space
//               padding: EdgeInsets.zero, // Remove padding around the TabBar
//               labelPadding: EdgeInsets.zero, // Remove padding around each tab label
//               tabs: const [
//                 // Use SizedBox.expand to make the whole tab area clickable
//                 Tab(
//                   child: SizedBox.expand(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.restaurant_menu),
//                         SizedBox(height: 4),
//                         Text('Menú'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: SizedBox.expand(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.food_bank),
//                         SizedBox(height: 4),
//                         Text('Planes'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: SizedBox.expand(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.celebration),
//                         SizedBox(height: 4),
//                         Text('Catering'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: SizedBox.expand(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.event_available),
//                         SizedBox(height: 4),
//                         Text('Eventos'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 40),
          
//           // Tab content
//           SizedBox(
//             // Fixed height makes the layout more stable
//             height: isMobile ? 600 : 700,
//             child: TabBarView(
//               controller: tabController,
//               children: [
//                 // Menu tab
//                 MenuSection(
//                   randomDishes: randomDishes,
//                   isMobile: isMobile,
//                   isTablet: isTablet,
//                   isDesktop: isDesktop,
//                 ),
                
//                 // Meal plans tab
//                 MealPlansSection(
//                   isMobile: isMobile,
//                   isTablet: isTablet,
//                   isDesktop: isDesktop,
//                 ),
                
//                 // Catering tab
//                 CateringSection(
//                   cateringPackages: cateringPackages,
//                   onPackageTap: onCateringPackageTap,
//                   isMobile: isMobile,
//                   isTablet: isTablet,
//                   isDesktop: isDesktop,
//                 ),
                
//                 // Events tab
//                 EventsSection(
//                   isMobile: isMobile,
//                   isTablet: isTablet,
//                   isDesktop: isDesktop,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// /// Menu section showing featured dishes
// class MenuSection extends StatelessWidget {
//   final List<Map<String, dynamic>>? randomDishes;
//   final bool isMobile;
//   final bool isTablet;
//   final bool isDesktop;
  
//   const MenuSection({
//     super.key,
//     required this.randomDishes,
//     required this.isMobile,
//     required this.isTablet,
//     required this.isDesktop,
//   });
 
// // Usage in the MenuSection class:
// // Replace current grid implementations with:
// @override
// Widget build(BuildContext context) {
//   final theme = Theme.of(context);
//   final colorScheme = theme.colorScheme;
  
//   if (randomDishes == null || randomDishes!.isEmpty) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: colorScheme.primary),
//           const SizedBox(height: 16),
//           Text(
//             'Cargando platos...',
//             style: theme.textTheme.titleMedium,
//           ),
//         ],
//       ),
//     );
//   }
  
//   return SingleChildScrollView(
//     padding: EdgeInsets.symmetric(
//       horizontal: isMobile ? 16 : 32,
//       vertical: 20,
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: Column(
//             children: [
//               Text(
//                 'Nuestros Platos',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Descubra nuestra deliciosa selección de platos preparados con ingredientes frescos y de alta calidad',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: colorScheme.onSurface.withOpacity(0.7),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 32),
        
//         // Use the fully responsive grid for all screen sizes
//         _buildResponsiveMenuGrid(context),
        
//         const SizedBox(height: 32),
        
//         // View all button
//         Center(
//           child: ElevatedButton.icon(
//             onPressed: () => GoRouter.of(context).goNamed(AppRoute.home.name),
//             icon: const Icon(Icons.restaurant_menu),
//             label: const Text('Ver Menú Completo'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.primary,
//               foregroundColor: colorScheme.onPrimary,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // Widget _buildMobileMenuGrid(BuildContext context) {
// //   return ListView.builder(
// //     shrinkWrap: true,
// //     physics: const NeverScrollableScrollPhysics(),
// //     itemCount: randomDishes!.length > 4 ? 4 : randomDishes!.length,
// //     itemBuilder: (context, index) {
// //       final dish = randomDishes![index];
// //       return Padding(
// //         padding: const EdgeInsets.only(bottom: 16),
// //         child: SizedBox(
// //           // Increase the height to accommodate the content (8px more than constraint)
// //           // height: 90, // Original constraint was 80px and overflowed by 8px
// //           child: DishItem(
// //             key: Key('dish_$index'),
// //             index: index,
// //             img: dish['img'],
// //             title: dish['title'],
// //             description: dish['description'],
// //             pricing: dish['pricing'],
// //             ingredients: List<String>.from(dish['ingredients']),
// //             isSpicy: dish['isSpicy'],
// //             foodType: dish['foodType'],
// //             dishData: dish,
// //             hideIngredients: true,
// //             showDetailsButton: true,
// //             showAddButton: true,
// //             useHorizontalLayout: true,
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }
// //   // Updated tablet menu grid implementation to use full available width
// // Widget _buildTabletMenuGrid(BuildContext context) {
// //   return LayoutBuilder(
// //     builder: (context, constraints) {
// //       final columnCount = 2; // Two columns for tablet
// //       final spacing = 16.0;
// //       final availableWidth = constraints.maxWidth;
      
// //       // Calculate card width including spacing
// //       final totalSpacingWidth = spacing * (columnCount - 1);
// //       final cardWidth = (availableWidth - totalSpacingWidth) / columnCount;
      
// //       return Container(
// //         width: double.infinity, // Force full width
// //         child: Wrap(
// //           spacing: spacing,
// //           runSpacing: 24, // Increased vertical spacing for better visual separation
// //           alignment: WrapAlignment.start,
// //           children: List.generate(
// //             randomDishes!.length > 4 ? 4 : randomDishes!.length,
// //             (index) {
// //               final dish = randomDishes![index];
// //               return SizedBox(
// //                 width: cardWidth,
// //                 child: DishItem(
// //                   key: Key('dish_$index'),
// //                   index: index,
// //                   img: dish['img'],
// //                   title: dish['title'],
// //                   description: dish['description'],
// //                   pricing: dish['pricing'],
// //                   ingredients: List<String>.from(dish['ingredients']),
// //                   isSpicy: dish['isSpicy'],
// //                   foodType: dish['foodType'],
// //                   dishData: dish,
// //                   hideIngredients: false,
// //                   showDetailsButton: true,
// //                   showAddButton: true,
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       );
// //     }
// //   );
// // }

// // // Updated desktop menu grid implementation to use full available width
// // Widget _buildDesktopMenuGrid(BuildContext context) {
// //   return LayoutBuilder(
// //     builder: (context, constraints) {
// //       final columnCount = 4; // Four columns for desktop
// //       final spacing = 20.0;
// //       final availableWidth = constraints.maxWidth;
      
// //       // Calculate card width including spacing
// //       final totalSpacingWidth = spacing * (columnCount - 1);
// //       final cardWidth = (availableWidth - totalSpacingWidth) / columnCount;
      
// //       return Container(
// //         width: double.infinity, // Force full width
// //         child: Wrap(
// //           spacing: spacing,
// //           runSpacing: 30, // Increased vertical spacing for better visual separation
// //           alignment: WrapAlignment.start,
// //           children: List.generate(
// //             randomDishes!.length > 8 ? 8 : randomDishes!.length,
// //             (index) {
// //               final dish = randomDishes![index];
// //               return SizedBox(
// //                 width: cardWidth,
// //                 child: DishItem(
// //                   key: Key('dish_$index'),
// //                   index: index,
// //                   img: dish['img'],
// //                   title: dish['title'],
// //                   description: dish['description'],
// //                   pricing: dish['pricing'],
// //                   ingredients: List<String>.from(dish['ingredients']),
// //                   isSpicy: dish['isSpicy'],
// //                   foodType: dish['foodType'],
// //                   dishData: dish,
// //                   hideIngredients: false,
// //                   showDetailsButton: true,
// //                   showAddButton: true,
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       );
// //     }
// //   );
// // }

// Widget _buildResponsiveMenuGrid(BuildContext context) {
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       final screenWidth = constraints.maxWidth;
//       int columnCount;
//       double spacing;
//       int itemCount;
      
//       // Determine column count and spacing based on available width
//       if (screenWidth > 1200) {
//         columnCount = 4; // Desktop - 4 columns
//         spacing = 24;
//         itemCount = randomDishes!.length > 8 ? 8 : randomDishes!.length;
//       } else if (screenWidth > 800) {
//         columnCount = 3; // Large tablet - 3 columns
//         spacing = 20;
//         itemCount = randomDishes!.length > 6 ? 6 : randomDishes!.length;
//       } else if (screenWidth > 600) {
//         columnCount = 2; // Tablet - 2 columns
//         spacing = 16;
//         itemCount = randomDishes!.length > 4 ? 4 : randomDishes!.length;
//       } else {
//         // For mobile, we use a more efficient ListView
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: randomDishes!.length > 4 ? 4 : randomDishes!.length,
//           itemBuilder: (context, index) {
//             final dish = randomDishes![index];
            
//             // Use RepaintBoundary to optimize painting performance
//             return RepaintBoundary(
//               // Add key for more efficient reconciliation
//               key: ValueKey('dish_item_$index'),
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: DishItem(
//                   key: Key('dish_$index'),
//                   index: index,
//                   img: dish['img'],
//                   title: dish['title'],
//                   description: dish['description'],
//                   pricing: dish['pricing'],
//                   ingredients: List<String>.from(dish['ingredients']),
//                   isSpicy: dish['isSpicy'],
//                   foodType: dish['foodType'],
//                   dishData: dish,
//                   hideIngredients: true,
//                   showDetailsButton: true,
//                   showAddButton: true,
//                   useHorizontalLayout: true,
//                 ),
//               ),
//             );
//           },
//         );
//       }
      
//       // Create an efficient grid using LayoutBuilder + Wrap for larger screens
//       // This is more performant than GridView in some cases
//       final totalSpacingWidth = spacing * (columnCount - 1);
//       final cardWidth = (screenWidth - totalSpacingWidth) / columnCount;
      
//       // Precalculate indices to avoid repeated calculations
//       final indices = List<int>.generate(itemCount, (i) => i);
      
//       return Column(  // Using Column instead of Container for cleaner hierarchy
//         children: [
//           Wrap(
//             spacing: spacing,
//             runSpacing: spacing * 1.5,
//             children: indices.map((index) {
//               final dish = randomDishes![index];
              
//               // Use RepaintBoundary to optimize painting
//               return RepaintBoundary(
//                 key: ValueKey('dish_grid_item_$index'),
//                 child: SizedBox(
//                   width: cardWidth,
//                   child: DishItem(
//                     key: Key('dish_$index'),
//                     index: index,
//                     img: dish['img'],
//                     title: dish['title'],
//                     description: dish['description'],
//                     pricing: dish['pricing'],
//                     ingredients: List<String>.from(dish['ingredients']),
//                     isSpicy: dish['isSpicy'],
//                     foodType: dish['foodType'],
//                     dishData: dish,
//                     hideIngredients: screenWidth < 800, // Hide ingredients on smaller screens
//                     showDetailsButton: true,
//                     showAddButton: true,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       );
//     }
//   );
// }

// }

// /// Meal plans section
// class MealPlansSection extends ConsumerWidget {
//   final bool isMobile;
//   final bool isTablet;
//   final bool isDesktop;
  
//   const MealPlansSection({
//     super.key,
//     required this.isMobile,
//     required this.isTablet,
//     required this.isDesktop,
//   });
  
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final mealPlans = ref.watch(mealPlansProvider);
    
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 32,
//         vertical: 20,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 Text(
//                   'Planes de Comida',
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Descubra nuestros planes de comida semanales, diseñados para adaptarse a su estilo de vida y preferencias',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
          
//           if (mealPlans.isEmpty)
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(color: colorScheme.primary),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Cargando planes...',
//                     style: theme.textTheme.titleMedium,
//                   ),
//                 ],
//               ),
//             )
//           else
//             // Meal plans grid
//             if (isMobile) 
//               _buildMobileMealPlansGrid(context, mealPlans)
//             else if (isTablet) 
//               _buildTabletMealPlansGrid(context, mealPlans)
//             else 
//               _buildDesktopMealPlansGrid(context, mealPlans),
              
//           const SizedBox(height: 32),
          
//           // Subscription benefits
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: colorScheme.secondaryContainer.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: colorScheme.secondaryContainer,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Beneficios de Suscripción',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.secondary,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: [
//                     _buildBenefitItem(
//                       context,
//                       icon: Icons.local_shipping,
//                       title: 'Entrega Gratuita',
//                       description: 'Todos los planes incluyen entrega a domicilio sin costo adicional',
//                     ),
//                     _buildBenefitItem(
//                       context,
//                       icon: Icons.sync,
//                       title: 'Flexibilidad',
//                       description: 'Pausa, reactiva o cambia tu plan en cualquier momento',
//                     ),
//                     _buildBenefitItem(
//                       context,
//                       icon: Icons.menu_book,
//                       title: 'Menú Personalizado',
//                       description: 'Selecciona tus platos favoritos cada semana',
//                     ),
//                     _buildBenefitItem(
//                       context,
//                       icon: Icons.eco,
//                       title: 'Sostenibilidad',
//                       description: 'Envases eco-amigables y prácticas sustentables',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildBenefitItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Container(
//       width: isMobile ? double.infinity : isTablet ? 220 : 260,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             size: 24,
//             color: colorScheme.secondary,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMobileMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: mealPlans.length,
//       itemBuilder: (context, index) {
//         final mealPlan = mealPlans[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: PlanCard(
//             planName: mealPlan.title,
//             description: mealPlan.description,
//             price: mealPlan.price,
//             planId: mealPlan.id,
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildTabletMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         // childAspectRatio: 0.85,
//         // crossAxisSpacing: 16,
//         // mainAxisSpacing: 16,
//       ),
//       itemCount: mealPlans.length,
//       itemBuilder: (context, index) {
//         final mealPlan = mealPlans[index];
//         return PlanCard(
//           planName: mealPlan.title,
//           description: mealPlan.description,
//           price: mealPlan.price,
//           planId: mealPlan.id,
//         );
//       },
//     );
//   }
  
//   Widget _buildDesktopMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         // childAspectRatio: 0.85,
//         // crossAxisSpacing: 20,
//         // mainAxisSpacing: 20,
//       ),
//       itemCount: mealPlans.length,
//       itemBuilder: (context, index) {
//         final mealPlan = mealPlans[index];
//         return PlanCard(
//           planName: mealPlan.title,
//           description: mealPlan.description,
//           price: mealPlan.price,
//           planId: mealPlan.id,
//         );
//       },
//     );
//   }
// }

// /// Catering section
// class CateringSection extends StatelessWidget {
//   final List<Map<String, dynamic>> cateringPackages;
//   final Function(int) onPackageTap;
//   final bool isMobile;
//   final bool isTablet;
//   final bool isDesktop;
  
//   const CateringSection({
//     super.key,
//     required this.cateringPackages,
//     required this.onPackageTap,
//     required this.isMobile,
//     required this.isTablet,
//     required this.isDesktop,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 32,
//         vertical: 20,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 Text(
//                   'Servicios de Catering',
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Ofrecemos servicios de catering de alta calidad para todo tipo de eventos, desde pequeñas reuniones hasta grandes celebraciones',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
          
//           // Catering packages grid
//           if (isMobile) 
//             _buildMobileCateringPackages(context)
//           else if (isTablet) 
//             _buildTabletCateringPackages(context)
//           else 
//             _buildDesktopCateringPackages(context),
          
//           const SizedBox(height: 32),
          
//           // Custom catering teaser
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: colorScheme.tertiaryContainer.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: colorScheme.tertiaryContainer,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.design_services,
//                       size: 32,
//                       color: colorScheme.tertiary,
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         '¿Necesita un Servicio de Catering Personalizado?',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: colorScheme.tertiary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Cuéntenos sobre su evento y crearemos un menú personalizado que se adapte perfectamente a sus necesidades y presupuesto.',
//                   style: theme.textTheme.bodyLarge,
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: [
//                     _buildCateringInfoItem(
//                       context,
//                       'Eventos Corporativos',
//                       Icons.business,
//                     ),
//                     _buildCateringInfoItem(
//                       context,
//                       'Bodas y Celebraciones',
//                       Icons.celebration,
//                     ),
//                     _buildCateringInfoItem(
//                       context,
//                       'Fiestas Privadas',
//                       Icons.grass,
//                     ),
//                     _buildCateringInfoItem(
//                       context,
//                       'Eventos Especiales',
//                       Icons.event_available,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => GoRouter.of(context).pushNamed(AppRoute.cateringQuote.name),
//                     icon: const Icon(Icons.send),
//                     label: const Text('Solicitar Cotización Personalizada'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: colorScheme.tertiary,
//                       foregroundColor: colorScheme.onTertiary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildCateringInfoItem(
//     BuildContext context,
//     String title,
//     IconData icon,
//   ) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 12,
//       ),
//       decoration: BoxDecoration(
//         color: colorScheme.tertiary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 18,
//             color: colorScheme.tertiary,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.tertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  

// Widget _buildMobileCateringPackages(BuildContext context) {
//   return ListView.builder(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     itemCount: cateringPackages.length,
//     itemBuilder: (context, index) {
//       final package = cateringPackages[index];
//       return Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () => onPackageTap(index),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start, // Ensure proper alignment
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         package['icon'],
//                         color: Theme.of(context).colorScheme.primary,
//                         size: 32,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             package['title'],
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 2, // Limit lines
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             package['price'],
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   package['description'],
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   maxLines: 2, // Limit the description to 2 lines
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => onPackageTap(index),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                   ),
//                   child: const Text('Ver Detalles'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// Widget _buildTabletCateringPackages(BuildContext context) {
//   return GridView.builder(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,
//       childAspectRatio: 1.1, // Keep as is, but we'll make content scrollable if needed
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//     ),
//     itemCount: cateringPackages.length,
//     itemBuilder: (context, index) {
//       final package = cateringPackages[index];
//       return Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () => onPackageTap(index),
//           borderRadius: BorderRadius.circular(16),
//           child: SingleChildScrollView( // Make the content scrollable
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     package['icon'],
//                     size: 48,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     package['title'],
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     package['description'],
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     package['price'],
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   OutlinedButton(
//                     onPressed: () => onPackageTap(index),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Theme.of(context).colorScheme.primary,
//                     ),
//                     child: const Text('Ver Detalles'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }


//   Widget _buildDesktopCateringPackages(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         childAspectRatio: 0.85,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//       ),
//       itemCount: cateringPackages.length,
//       itemBuilder: (context, index) {
//         final package = cateringPackages[index];
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: InkWell(
//             onTap: () => onPackageTap(index),
//             borderRadius: BorderRadius.circular(16),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       package['icon'],
//                       size: 40,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     package['title'],
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     package['description'],
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     textAlign: TextAlign.center,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     package['price'],
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height:16),
//                   ElevatedButton(
//                     onPressed: () => onPackageTap(index),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     ),
//                     child: const Text('Ver Detalles'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// Events section
// class EventsSection extends StatelessWidget {
//   final bool isMobile;
//   final bool isTablet;
//   final bool isDesktop;
  
//   const EventsSection({
//     super.key,
//     required this.isMobile,
//     required this.isTablet,
//     required this.isDesktop,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     // Sample events
//     final events = [
//       {
//         'title': 'Noche de Degustación',
//         'date': '15 de Marzo, 2025',
//         'time': '19:00 - 22:00',
//         'description': 'Degustación de vinos y tapas con nuestro chef ejecutivo',
//         'image': 'https://images.unsplash.com/photo-1528605248644-14dd04022da1',
//         'price': 'S/ 120.00 por persona',
//       },
//       {
//         'title': 'Clase de Cocina',
//         'date': '22 de Marzo, 2025',
//         'time': '15:00 - 17:30',
//         'description': 'Aprenda a preparar platos peruanos tradicionales',
//         'image': 'https://images.unsplash.com/photo-1556910103-1c02745aae4d',
//         'price': 'S/ 150.00 por persona',
//       },
//       {
//         'title': 'Cena con el Chef',
//         'date': '5 de Abril, 2025',
//         'time': '20:00 - 23:00',
//         'description': 'Menú degustación especial con maridaje de vinos',
//         'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
//         'price': 'S/ 200.00 por persona',
//       },
//     ];
    
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 32,
//         vertical: 20,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 Text(
//                   'Eventos Especiales',
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Participe en nuestros eventos exclusivos donde la gastronomía, el arte y la cultura se encuentran',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
          
//           // Events list
//           if (isMobile) 
//             _buildMobileEventsList(context, events)
//           else if (isTablet) 
//             _buildTabletEventsList(context, events)
//           else 
//             _buildDesktopEventsList(context, events),
          
//           const SizedBox(height: 32),
          
//           // Event space rental
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: colorScheme.secondaryContainer.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(16),
//               image: DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1414235077428-338989a2e8c0'
//                 ),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.6),
//                   BlendMode.darken,
//                 ),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Alquiler de Espacios para Eventos',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Ofrecemos espacios elegantes y versátiles para sus eventos privados o corporativos. Nuestro equipo de expertos se encargará de todos los detalles para que su evento sea un éxito.',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: [
//                     _buildEventSpaceFeature(
//                       context,
//                       'Capacidad para 150 personas',
//                       Icons.people,
//                     ),
//                     _buildEventSpaceFeature(
//                       context,
//                       'Equipo audiovisual',
//                       Icons.speaker,
//                     ),
//                     _buildEventSpaceFeature(
//                       context,
//                       'Catering incluido',
//                       Icons.restaurant,
//                     ),
//                     _buildEventSpaceFeature(
//                       context,
//                       'Estacionamiento',
//                       Icons.local_parking,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.calendar_today),
//                   label: const Text('Solicitar Información'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: colorScheme.primary,
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildEventSpaceFeature(
//     BuildContext context,
//     String title,
//     IconData icon,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 12,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: Colors.white,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
// Widget _buildMobileEventsList(BuildContext context, List<Map<String, dynamic>> events) {
//   return ListView.builder(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     itemCount: events.length,
//     itemBuilder: (context, index) {
//       final event = events[index];
//       return Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 9,
//               child: Image.network(
//                 event['image'] as String,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                   child: Icon(
//                     Icons.image_not_supported,
//                     size: 48,
//                     color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     event['title'] as String,
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap( // Use Wrap instead of Row for date and time
//                     spacing: 16,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             event['date'] as String,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 16,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             event['time'] as String,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     event['description'] as String,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     event['price'] as String,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {},
//                           child: const Text('Más Información'),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).colorScheme.primary,
//                             foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                           ),
//                           child: const Text('Reservar'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

//   Widget _buildTabletEventsList(BuildContext context, List<Map<String, dynamic>> events) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: events.length,
//       itemBuilder: (context, index) {
//         final event = events[index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           clipBehavior: Clip.antiAlias,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: IntrinsicHeight(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(
//                   width: 200,
//                   child: Image.network(
//                     event['image'] as String,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                       child: Icon(
//                         Icons.image_not_supported,
//                         size: 48,
//                         color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           event['title'] as String,
//                           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 16,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               event['date'] as String,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                             const SizedBox(width: 16),
//                             Icon(
//                               Icons.access_time,
//                               size: 16,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               event['time'] as String,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           event['description'] as String,
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               event['price'] as String,
//                               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height:16),
//                             OutlinedButton(
//                               onPressed: () {},
//                               child: const Text('Más Información'),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton(
//                               onPressed: () {},
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Theme.of(context).colorScheme.primary,
//                                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                               ),
//                               child: const Text('Reservar'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildDesktopEventsList(BuildContext context, List<Map<String, dynamic>> events) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 0.85,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//       ),
//       itemCount: events.length,
//       itemBuilder: (context, index) {
//         final event = events[index];
//         return Card(
//           clipBehavior: Clip.antiAlias,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: Image.network(
//                   event['image'] as String,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                     child: Icon(
//                       Icons.image_not_supported,
//                       size: 48,
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         event['title'] as String,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 14,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             event['date'] as String,
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             event['time'] as String,
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         event['description'] as String,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                       const SizedBox(height:16),
//                       Text(
//                         event['price'] as String,
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           color: Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).colorScheme.primary,
//                             foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                           ),
//                           child: const Text('Reservar'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

 
// /// Completes the EnhancedContactSection class
// class EnhancedContactSection extends StatelessWidget {
//   const EnhancedContactSection({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     return Container(
//       color: colorScheme.surfaceVariant.withOpacity(0.3),
//       padding: EdgeInsets.symmetric(
//         vertical: 60,
//         horizontal: isMobile ? 16 : 32,
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Contáctanos',
//             style: theme.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: colorScheme.primary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Estamos aquí para ayudarte con cualquier consulta o reserva',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               color: colorScheme.onSurfaceVariant,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 40),
          
//           if (isMobile)
//             _buildMobileContactLayout(context)
//           else
//             _buildDesktopContactLayout(context),
          
//           const SizedBox(height: 40),
          
//           // Social media
//        Wrap(
//   alignment: WrapAlignment.center,
//   spacing: 16,
//   runSpacing: 16,
//   children: [
//     _buildSocialButton(
//       context,
//       icon: Icons.facebook,
//       label: 'Facebook',
//     ),
//     _buildSocialButton(
//       context,
//       icon: Icons.social_distance,
//       label: 'Instagram',
//     ),
//     _buildSocialButton(
//       context,
//       icon: Icons.social_distance,
//       label: 'Twitter',
//     ),
//   ],
// )
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMobileContactLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Column(
//       children: [
//         // Contact info cards
//         Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Phone
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: colorScheme.primaryContainer.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.phone,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Teléfono',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       InkWell(
//                         onTap: () => _launchUrl('tel:+51123456789'),
//                         child: Text(
//                           '+51 123 456 789',
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
              
//               // Email
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: colorScheme.primaryContainer.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.email,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Email',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       InkWell(
//                         onTap: () => _launchUrl('mailto:info@upgrade.do'),
//                         child: Text(
//                           'info@upgrade.do',
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
              
//               // Address
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: colorScheme.primaryContainer.withOpacity(0.3),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.location_on,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Dirección',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         InkWell(
//                           onTap: () => _launchUrl('https://maps.google.com'),
//                           child: Text(
//                             'Av. La Marina 2000, San Miguel, Lima',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 32),
        
//         // Contact form
//         Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Envíanos un mensaje',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Name field
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Nombre completo',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.person),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Email field
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.email),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Subject field
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Asunto',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   prefixIcon: const Icon(Icons.subject),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Message field
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Mensaje',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   alignLabelWithHint: true,
//                   prefixIcon: const Icon(Icons.message),
//                 ),
//                 maxLines: 5,
//               ),
//               const SizedBox(height: 24),
              
//               // Submit button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.send),
//                   label: const Text('Enviar Mensaje'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: colorScheme.primary,
//                     foregroundColor: colorScheme.onPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildDesktopContactLayout(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Contact info
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Información de Contacto',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Phone
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: colorScheme.primaryContainer.withOpacity(0.3),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.phone,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Teléfono',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         InkWell(
//                           onTap: () => _launchUrl('tel:+51123456789'),
//                           child: Text(
//                             '+51 123 456 789',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Email
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: colorScheme.primaryContainer.withOpacity(0.3),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.email,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Email',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         InkWell(
//                           onTap: () => _launchUrl('mailto:info@upgrade.do'),
//                           child: Text(
//                             'info@upgrade.do',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Address
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: colorScheme.primaryContainer.withOpacity(0.3),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.location_on,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Dirección',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           InkWell(
//                             onTap: () => _launchUrl('https://maps.google.com'),
//                             child: Text(
//                               'Av. La Marina 2000, San Miguel, Lima',
//                               style: theme.textTheme.bodyLarge?.copyWith(
//                                 color: colorScheme.primary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Business hours
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: colorScheme.surfaceVariant.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 20,
//                             color: colorScheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Horario de Atención',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       _buildBusinessHourRow(context, 'Lunes - Viernes', '11:00 AM - 10:00 PM'),
//                       const SizedBox(height: 8),
//                       _buildBusinessHourRow(context, 'Sábado', '10:00 AM - 11:00 PM'),
//                       const SizedBox(height: 8),
//                       _buildBusinessHourRow(context, 'Domingo', '10:00 AM - 9:00 PM'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         const SizedBox(width: 24),
        
//         // Contact form
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Envíanos un mensaje',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Name field
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Nombre completo',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     prefixIcon: const Icon(Icons.person),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Email field
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     prefixIcon: const Icon(Icons.email),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Subject field
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Asunto',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     prefixIcon: const Icon(Icons.subject),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Message field
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Mensaje',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     alignLabelWithHint: true,
//                     prefixIcon: const Icon(Icons.message),
//                   ),
//                   maxLines: 5,
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.send),
//                     label: const Text('Enviar Mensaje'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: colorScheme.onPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

// Widget _buildBusinessHourRow(BuildContext context, String day, String hours) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           day,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           hours,
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
  
//   void _launchUrl(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     }
//   }
// }



//   Widget _buildSocialButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//   }) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return ElevatedButton.icon(
//       onPressed: () {},
//       icon: Icon(icon),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: colorScheme.surfaceVariant,
//         foregroundColor: colorScheme.primary,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       ),
//     );
//   }
  
//   void _launchUrl(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     }
//   }


// /// Enhanced Footer Section with links and information
// class EnhancedFooterSection extends StatelessWidget {
//   const EnhancedFooterSection({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     return Container(
//       color: colorScheme.surface,
//       padding: EdgeInsets.symmetric(
//         vertical: 60,
//         horizontal: isMobile ? 16 : 32,
//       ),
//       child: Column(
//         children: [
//           if (isMobile)
//             _buildMobileFooterContent(context)
//           else
//             _buildDesktopFooterContent(context),
          
//           const SizedBox(height: 40),
          
//           Divider(
//             color: colorScheme.outline.withOpacity(0.2),
//           ),
          
//           const SizedBox(height: 20),
          
// Wrap(
//   alignment: WrapAlignment.spaceBetween,
//   runSpacing: 10,
//   children: [
//     Text(
//       '© 2025 Kako. Todos los derechos reservados.',
//       style: theme.textTheme.bodyMedium?.copyWith(
//         color: colorScheme.onSurface.withOpacity(0.7),
//       ),
//     ),
//     if (!isMobile)
//       Wrap(
//         spacing: 16,
//         children: [
//           InkWell(
//             onTap: () {},
//             child: Text(
//               'Términos y Condiciones',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.primary,
//               ),
//             ),
//           ),
//           InkWell(
//             onTap: () {},
//             child: Text(
//               'Política de Privacidad',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.primary,
//               ),
//             ),
//           ),
//         ],
//       ),
//   ],
// )
// ,
          
//           if (isMobile) ...[
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 InkWell(
//                   onTap: () {},
//                   child: Text(
//                     'Términos y Condiciones',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 InkWell(
//                   onTap: () {},
//                   child: Text(
//                     'Política de Privacidad',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMobileFooterContent(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Logo and description
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               // child: Icon(
//               //   Icons.restaurant,
//               //   size: 40,
//               //   color: colorScheme.primary,
//               // ),
//                 child: ClipOval(
//                       child: Image.asset(
//                         'assets/appicon.png',
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Kako',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.primary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
        
//         const SizedBox(height: 32),
        
//         // Quick links
//         Text(
//           'Enlaces Rápidos',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildFooterLink(context, 'Inicio', Icons.home),
//         _buildFooterLink(context, 'Menú', Icons.restaurant_menu),
//         _buildFooterLink(context, 'Reservaciones', Icons.event_seat),
//         _buildFooterLink(context, 'Planes de Comida', Icons.food_bank),
//         _buildFooterLink(context, 'Catering', Icons.celebration),
//         _buildFooterLink(context, 'Contacto', Icons.mail),
        
//         const SizedBox(height: 32),
        
//         // Newsletter
//         Text(
//           'Suscríbete a nuestro boletín',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Recibe nuestras últimas noticias, eventos y ofertas especiales directamente en tu bandeja de entrada.',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: colorScheme.onSurface.withOpacity(0.7),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Ingresa tu email',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colorScheme.primary,
//                 foregroundColor: colorScheme.onPrimary,
//                 minimumSize: const Size(0, 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Suscribir'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
  
//   Widget _buildDesktopFooterContent(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Logo and description
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     // child: Icon(
//                     //   Icons.restaurant,
//                     //   size: 30,
//                     //   color: colorScheme.primary,
//                     // ),
//                       child: ClipOval(
//                       child: Image.asset(
//                         'assets/appicon.png',
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Text(
//                     'Kako',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta o servidas en nuestro elegante restaurante.',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurface.withOpacity(0.7),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Av. La Marina 2000, San Miguel, Lima\nTeléfono: +51 123 456 789\nEmail: info@upgrade.do',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   height: 1.6,
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(width: 64),
        
//         // Quick links
//         Expanded(
//           flex: 1,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Enlaces Rápidos',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _buildFooterLink(context, 'Inicio', Icons.home),
//               _buildFooterLink(context, 'Menú', Icons.restaurant_menu),
//               _buildFooterLink(context, 'Reservaciones', Icons.event_seat),
//               _buildFooterLink(context, 'Planes de Comida', Icons.food_bank),
//               _buildFooterLink(context, 'Catering', Icons.celebration),
//               _buildFooterLink(context, 'Contacto', Icons.mail),
//             ],
//           ),
//         ),
        
//         const SizedBox(width: 64),
        
//         // Newsletter
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Suscríbete a nuestro boletín',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Recibe nuestras últimas noticias, eventos y ofertas especiales directamente en tu bandeja de entrada.',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurface.withOpacity(0.7),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: 'Ingresa tu email',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colorScheme.primary,
//                       foregroundColor: colorScheme.onPrimary,
//                       minimumSize: const Size(0, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('Suscribir'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Síguenos',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   _buildSocialIconButton(context, Icons.facebook),
//                   const SizedBox(width: 12),
//                   _buildSocialIconButton(context, Icons.facebook),
//                   const SizedBox(width: 12),
//                   _buildSocialIconButton(context, Icons.social_distance),
//                   const SizedBox(width: 12),
//                   _buildSocialIconButton(context, Icons.social_distance),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildFooterLink(BuildContext context, String title, IconData icon) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: InkWell(
//         onTap: () {},
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: colorScheme.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               title,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSocialIconButton(BuildContext context, IconData icon) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: colorScheme.primaryContainer.withOpacity(0.3),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         icon,
//         size: 20,
//         color: colorScheme.primary,
//       ),
//     );
//   }
// }

// /// Reservation section for making table reservations
// class ReservationSection extends StatefulWidget {
//   const ReservationSection({super.key});

//   @override
//   State<ReservationSection> createState() => _ReservationSectionState();
// }

// class _ReservationSectionState extends State<ReservationSection> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
  
//   DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
//   TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
//   int _guestCount = 2;
  
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
  
//   void _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 90)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).colorScheme.primary,
//               onPrimary: Theme.of(context).colorScheme.onPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
  
//   void _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).colorScheme.primary,
//               onPrimary: Theme.of(context).colorScheme.onPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }
  
//   void _submitReservation() {
//     // Validation
//     if (_nameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Por favor complete todos los campos requeridos'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//       return;
//     }
    
//     // Submit logic would go here
    
//     // Show confirmation
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('¡Reserva enviada con éxito! Le contactaremos pronto para confirmar.'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//       ),
//     );
    
//     // Close modal
//     Navigator.pop(context);
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(isMobile ? 16 : 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Reserva de Mesa',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.primary,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Llena el formulario para reservar tu mesa en Kako',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 32),
          
//           // Reservation form
//           isMobile
//               ? _buildMobileReservationForm()
//               : _buildDesktopReservationForm(),
          
//           const SizedBox(height: 24),
          
//           // Reservation notes
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: colorScheme.secondaryContainer.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: colorScheme.secondaryContainer,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: colorScheme.secondary,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Información Importante',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.secondary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 _buildReservationInfoItem(
//                   'Las reservas deben realizarse con al menos 24 horas de anticipación',
//                 ),
//                 _buildReservationInfoItem(
//                   'Para grupos de más de 8 personas, por favor contáctenos directamente por teléfono',
//                 ),
//                 _buildReservationInfoItem(
//                   'Se aplica una política de cancelación de 4 horas',
//                 ),
//                 _buildReservationInfoItem(
//                   'Las mesas se reservan por un máximo de 2 horas',
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 32),
          
//           // Submit button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _submitReservation,
//               icon: const Icon(Icons.check_circle),
//               label: const Text('Confirmar Reserva'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: colorScheme.primary,
//                 foregroundColor: colorScheme.onPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildMobileReservationForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Guest information
//         Text(
//           'Información del Cliente',
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Name field
//         TextField(
//           controller: _nameController,
//           decoration: const InputDecoration(
//             labelText: 'Nombre completo *',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.person),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Email field
//         TextField(
//           controller: _emailController,
//           decoration: const InputDecoration(
//             labelText: 'Email *',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.email),
//           ),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         const SizedBox(height: 16),
        
//         // Phone field
//         TextField(
//           controller: _phoneController,
//           decoration: const InputDecoration(
//             labelText: 'Teléfono *',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.phone),
//           ),
//           keyboardType: TextInputType.phone,
//         ),
//         const SizedBox(height: 32),
        
//         // Reservation details
//         Text(
//           'Detalles de la Reserva',
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Date picker
//         InkWell(
//           onTap: () => _selectDate(context),
//           child: InputDecorator(
//             decoration: const InputDecoration(
//               labelText: 'Fecha',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.calendar_today),
//             ),
//             child: Text(
//               '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Time picker
//         InkWell(
//           onTap: () => _selectTime(context),
//           child: InputDecorator(
//             decoration: const InputDecoration(
//               labelText: 'Hora',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.access_time),
//             ),
//             child: Text(
//               '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Guest count
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Número de Personas',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     if (_guestCount > 1) {
//                       setState(() {
//                         _guestCount--;
//                       });
//                     }
//                   },
//                   icon: const Icon(Icons.remove_circle_outline),
//                 ),
//                 Text(
//                   _guestCount.toString(),
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     if (_guestCount < 12) {
//                       setState(() {
//                         _guestCount++;
//                       });
//                     }
//                   },
//                   icon: const Icon(Icons.add_circle_outline),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
        
//         // Special requests
//         TextField(
//           controller: _notesController,
//           decoration: const InputDecoration(
//             labelText: 'Solicitudes especiales',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.comment),
//           ),
//           maxLines: 3,
//         ),
//       ],
//     );
//   }
  
//   Widget _buildDesktopReservationForm() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Guest information
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Información del Cliente',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Name field
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nombre completo *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Email field
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
              
//               // Phone field
//               TextField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Teléfono *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
              
//               // Special requests
//               TextField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   labelText: 'Solicitudes especiales',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.comment),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(width: 24),
        
//         // Reservation details
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Detalles de la Reserva',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Date picker
//               InkWell(
//                 onTap: () => _selectDate(context),
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Fecha',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.calendar_today),
//                   ),
//                   child: Text(
//                     '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Time picker
//               InkWell(
//                 onTap: () => _selectTime(context),
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Hora',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.access_time),
//                   ),
//                   child: Text(
//                     '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Guest count
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Número de Personas',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           if (_guestCount > 1) {
//                             setState(() {
//                               _guestCount--;
//                             });
//                           }
//                         },
//                         icon: const Icon(Icons.remove_circle_outline),
//                       ),
//                       Text(
//                         _guestCount.toString(),
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           if (_guestCount < 12) {
//                             setState(() {
//                               _guestCount++;
//                             });
//                           }
//                         },
//                         icon: const Icon(Icons.add_circle_outline),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 16),
              
//               // Available time slots (for demonstration)
//               Text(
//                 'Horarios Disponibles',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   _buildTimeSlotChip('12:00'),
//                   _buildTimeSlotChip('13:00'),
//                   _buildTimeSlotChip('19:00', isSelected: true),
//                   _buildTimeSlotChip('20:00'),
//                   _buildTimeSlotChip('21:00'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildTimeSlotChip(String time, {bool isSelected = false}) {
//     final colorScheme = Theme.of(context).colorScheme;
    
//     return ChoiceChip(
//       label: Text(time),
//       selected: isSelected,
//       selectedColor: colorScheme.primary,
//       labelStyle: TextStyle(
//         color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
//       ),
//       onSelected: (bool selected) {
//         // Handle time selection
//       },
//     );
//   }
  
//   Widget _buildReservationInfoItem(String text) {
//     return SizedBox(
//   width: double.infinity, // Ensure full width
//   child: Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('• '),
//         Expanded(
//           child: Text(text),
//         ),
//       ],
//     ),
//   ));
//   }
// }

// /// Restaurant information section
// class RestaurantInfoSection extends StatelessWidget {
//   final ScrollController scrollController;
  
//   const RestaurantInfoSection({
//     super.key,
//     required this.scrollController,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
    
//     return ListView(
//       controller: scrollController,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Acerca de Nosotros',
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.primary,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
        
//         // Restaurant image
//         ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Image.network(
//             'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
//             height: 240,
//             width: double.infinity,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => Container(
//               height: 240,
//               width: double.infinity,
//               color: colorScheme.primaryContainer,
//               child: const Icon(
//                 Icons.image_not_supported,
//                 size: 64,
//                 color: Colors.white54,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
        
//         // Restaurant story
//         Text(
//           'Nuestra Historia',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: colorScheme.primary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Kako nació en 2010 con la visión de ofrecer una experiencia gastronómica excepcional en Lima. Fundada por el reconocido chef Carlos Mendoza, nuestro restaurante combina técnicas culinarias tradicionales peruanas con influencias internacionales para crear platos únicos y deliciosos.\n\nDesde nuestros humildes comienzos como un pequeño bistró, hemos crecido hasta convertirnos en uno de los destinos gastronómicos más respetados de la ciudad, manteniendo siempre nuestro compromiso con la calidad, la creatividad y el servicio excepcional.',
//           style: theme.textTheme.bodyLarge,
//         ),
//         const SizedBox(height: 24),
        
//         // Business hours and location
//         if (isMobile)
//           _buildMobileInfoSection(context)
//         else
//           _buildDesktopInfoSection(context),
        
//         const SizedBox(height: 24),
        
//         // Meet the team
//         Text(
//           'Nuestro Equipo',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: colorScheme.primary,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Team members
//         Wrap(
//           spacing: 16,
//           runSpacing: 16,
//           children: [
//             _buildTeamMemberCard(
//               context,
//               name: 'Carlos Mendoza',
//               position: 'Chef Ejecutivo',
//               image: 'https://images.unsplash.com/photo-1583394838336-acd977736f90',
//             ),
//             _buildTeamMemberCard(
//               context,
//               name: 'María López',
//               position: 'Chef de Pastelería',
//               image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
//             ),
//             _buildTeamMemberCard(
//               context,
//               name: 'Juan Pérez',
//               position: 'Jefe de Sala',
//               image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
//             ),
//           ],
//         ),
        
//         const SizedBox(height: 24),
        
//         // Awards and recognitions
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Premios y Reconocimientos',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildAwardItem(context, '2023', 'Mejor Restaurante de Fusión - Lima Food Awards'),
//               _buildAwardItem(context, '2022', 'Chef del Año - Revista Gastronomía & Sabor'),
//               _buildAwardItem(context, '2021', 'Excelencia en Servicio - TripAdvisor'),
//               _buildAwardItem(context, '2020', 'Innovación Culinaria - Premios Mesa Perú'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildMobileInfoSection(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Business hours
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.access_time,
//                     size: 20,
//                     color: colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Horario de Atención',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _buildHourRow(context, 'Lunes - Viernes', '11:00 AM - 10:00 PM'),
//               const SizedBox(height: 8),
//               _buildHourRow(context, 'Sábado', '10:00 AM - 11:00 PM'),
//               const SizedBox(height: 8),
//               _buildHourRow(context, 'Domingo', '10:00 AM - 9:00 PM'),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Location
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 20,
//                     color: colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Ubicación',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Av. La Marina 2000, San Miguel, Lima',
//                 style: theme.textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 12),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   height: 200,
//                   width: double.infinity,
//                   color: colorScheme.primaryContainer.withOpacity(0.3),
//                   child: const Center(
//                     child: Text('Mapa de ubicación'),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               OutlinedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.directions),
//                 label: const Text('Cómo llegar'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: colorScheme.primary,
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Contact information
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.contact_phone,
//                     size: 20,
//                     color: colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Contacto',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _buildContactItem(context, Icons.phone, 'Teléfono', '+51 123 456 789'),
//               const SizedBox(height: 8),
//               _buildContactItem(context, Icons.email, 'Email', 'info@upgrade.do'),
//               const SizedBox(height: 8),
//               _buildContactItem(context, Icons.language, 'Web', 'www.upgrade.do'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildDesktopInfoSection(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left column - Hours and Contact
//         Expanded(
//           child: Column(
//             children: [
//               // Business hours
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: _buildBusinessHoursSection(context),
//               ),
//               const SizedBox(height: 16),
//               // Contact info
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: _buildContactSection(context),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(width: 16),
        
//         // Right column - Location map
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: _buildLocationSection(context),
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildBusinessHoursSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.access_time,
//               size: 20,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Horario de Atención',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _buildHourRow(context, 'Lunes - Viernes', '11:00 AM - 10:00 PM'),
//         const SizedBox(height: 8),
//         _buildHourRow(context, 'Sábado', '10:00 AM - 11:00 PM'),
//         const SizedBox(height: 8),
//         _buildHourRow(context, 'Domingo', '10:00 AM - 9:00 PM'),
//       ],
//     );
//   }
  
//   Widget _buildContactSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.contact_phone,
//               size: 20,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Contacto',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _buildContactItem(context, Icons.phone, 'Teléfono', '+51 123 456 789'),
//         const SizedBox(height: 8),
//         _buildContactItem(context, Icons.email, 'Email', 'info@upgrade.do'),
//         const SizedBox(height: 8),
//         _buildContactItem(context, Icons.language, 'Web', 'www.upgrade.do'),
//       ],
//     );
//   }
  
//   Widget _buildLocationSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.location_on,
//               size: 20,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Ubicación',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'Av. La Marina 2000, San Miguel, Lima',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         const SizedBox(height: 12),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             height: 200,
//             width: double.infinity,
//             color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
//             child: const Center(
//               child: Text('Mapa de ubicación'),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.directions),
//           label: const Text('Cómo llegar'),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: Theme.of(context).colorScheme.primary,
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildHourRow(BuildContext context, String day, String hours) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           day,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           hours,
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
  
//   Widget _buildContactItem(BuildContext context, IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//             Text(
//               value,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
  
//   Widget _buildTeamMemberCard(
//     BuildContext context, {
//     required String name,
//     required String position,
//     required String image,
//   }) {
//     final size = MediaQuery.sizeOf(context);
//     final isMobile = size.width < 600;
//     final cardWidth = isMobile ? double.infinity : 200.0;
    
//     return Container(
//       width: cardWidth,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundImage: NetworkImage(image),
//             onBackgroundImageError: (exception, stackTrace) {},
//           ),
//           const SizedBox(height: 12),
//           Text(
//             name,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             position,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildAwardItem(BuildContext context, String year, String award) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               year,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               award,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Catering details content
// class CateringDetailsContent extends StatelessWidget {
//   final String packageTitle;
//   final ScrollController scrollController;
  
//   const CateringDetailsContent({
//     super.key,
//     required this.packageTitle,
//     required this.scrollController,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     // Sample menu items based on package type
//     List<Map<String, dynamic>> menuItems = [];
//     String packageDescription = '';
    
//     if (packageTitle == 'Cocktail Party') {
//       packageDescription = 'Nuestro paquete para cocktails es perfecto para reuniones informales, lanzamientos y eventos sociales. Incluye una selección de canapés gourmet, bebidas y servicio profesional.';
//       menuItems = [
//         {
//           'title': 'Canapés Variados',
//           'description': 'Selección de 8 variedades de canapés gourmet (3 por persona)',
//           'included': true,
//         },
//         {
//           'title': 'Estación de Quesos',
//           'description': 'Selección de quesos locales e importados con acompañamientos',
//           'included': true,
//         },
//         {
//           'title': 'Barra de Bebidas',
//           'description': 'Selección de vinos, cervezas y bebidas sin alcohol',
//           'included': true,
//         },
//         {
//           'title': 'Cócktails Preparados',
//           'description': 'Selección de cócteles clásicos preparados por nuestros bartenders',
//           'included': false,
//         },
//         {
//           'title': 'Postres Miniatura',
//           'description': 'Selección de postres en formato miniatura (2 por persona)',
//           'included': true,
//         },
//       ];
//     } else if (packageTitle == 'Corporate Lunch') {
//       packageDescription = 'Diseñado para reuniones de negocios y eventos corporativos, nuestro paquete de almuerzo ofrece un menú equilibrado y profesional que impresionará a sus clientes y colaboradores.';
//       menuItems = [
//         {
//           'title': 'Ensaladas Gourmet',
//           'description': 'Selección de ensaladas frescas y saludables',
//           'included': true,
//         },
//         {
//           'title': 'Plato Principal',
//           'description': 'Elección entre 3 opciones de plato principal (carne, pescado, vegetariano)',
//           'included': true,
//         },
//         {
//           'title': 'Guarniciones',
//           'description': 'Acompañamientos variados para complementar el plato principal',
//           'included': true,
//         },
//         {
//           'title': 'Bebidas',
//           'description': 'Agua, jugos naturales y refrescos',
//           'included': true,
//         },
//         {
//           'title': 'Postres',
//           'description': 'Selección de postres elegantes para finalizar la comida',
//           'included': true,
//         },
//         {
//           'title': 'Café y Té',
//           'description': 'Estación de café y té para después de la comida',
//           'included': true,
//         },
//       ];
//     } else if (packageTitle == 'Wedding Reception') {
//       packageDescription = 'Haga de su día especial un evento inolvidable con nuestro paquete de catering para bodas. Incluye un menú personalizado, decoración de mesas y servicio de calidad superior.';
//       menuItems = [
//         {
//           'title': 'Cocktail de Bienvenida',
//           'description': 'Selección de canapés y bebidas para recibir a los invitados',
//           'included': true,
//         },
//         {
//           'title': 'Entrada',
//           'description': 'Elegante primer plato para comenzar la celebración',
//           'included': true,
//         },
//         {
//           'title': 'Plato Principal',
//           'description': 'Opciones de lujo para el plato principal, adaptado a sus preferencias',
//           'included': true,
//         },
//         {
//           'title': 'Torta de Bodas',
//           'description': 'Torta personalizada diseñada según sus especificaciones',
//           'included': true,
//         },
//         {
//           'title': 'Mesa de Postres',
//           'description': 'Variedad de postres elegantes para deleitar a sus invitados',
//           'included': true,
//         },
//         {
//           'title': 'Barra de Bebidas Premium',
//           'description': 'Servicio completo de bar con opciones premium',
//           'included': true,
//         },
//         {
//           'title': 'Brindis con Champagne',
//           'description': 'Champagne de calidad para el brindis especial',
//           'included': true,
//         },
//       ];
//     } else {
//       packageDescription = 'Diseñamos un paquete totalmente personalizado basado en sus necesidades específicas, presupuesto y número de invitados. Contáctenos para una consulta detallada.';
//       menuItems = [
//         {
//           'title': 'Menú Personalizado',
//           'description': 'Diseñado específicamente para su evento y preferencias',
//           'included': true,
//         },
//         {
//           'title': 'Estaciones Temáticas',
//           'description': 'Opciones de estaciones de comida según la temática de su evento',
//           'included': true,
//         },
//         {
//           'title': 'Opciones Dietéticas Especiales',
//           'description': 'Adaptación a necesidades dietéticas y alergias',
//           'included': true,
//         },
//         {
//           'title': 'Personal de Servicio',
//           'description': 'Personal profesional adaptado al tamaño de su evento',
//           'included': true,
//         },
//         {
//           'title': 'Equipo y Mobiliario',
//           'description': 'Opciones de alquiler de equipo, vajilla y mobiliario',
//           'included': true,
//         },
//         {
//           'title': 'Decoración',
//           'description': 'Opciones de decoración personalizada',
//           'included': true,
//         },
//       ];
//     }
    
//     return ListView(
//       controller: scrollController,
//       children: [
//         // Package description
//         Text(
//           'Detalles del Paquete',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           packageDescription,
//           style: theme.textTheme.bodyLarge,
//         ),
//         const SizedBox(height: 24),
        
//         // Included items
//         Text(
//           'Menú Incluido',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: menuItems.length,
//           separatorBuilder: (context, index) => const Divider(),
//           itemBuilder: (context, index) {
//             final item = menuItems[index];
//             return ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: item['included']
//                       ? colorScheme.primaryContainer
//                       : colorScheme.surfaceVariant,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   item['included'] ? Icons.check : Icons.add,
//                   color: item['included']
//                       ? colorScheme.primary
//                       : colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               title: Text(
//                 item['title'],
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Text(
//                 item['description'],
//                 style: theme.textTheme.bodyMedium,
//               ),
//               trailing: item['included']
//                   ? null
//                   : TextButton(
//                       onPressed: () {},
//                       child: const Text('Agregar'),
//                     ),
//             );
//           },
//         ),
        
//         const Divider(height: 32),
        
//         // Additional services
//         Text(
//           'Servicios Adicionales',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             _buildAdditionalServiceChip(context, 'Servicio de DJ'),
//             _buildAdditionalServiceChip(context, 'Decoración Floral'),
//             _buildAdditionalServiceChip(context, 'Fotografía'),
//             _buildAdditionalServiceChip(context, 'Transporte'),
//             _buildAdditionalServiceChip(context, 'Barra de Postres'),
//             _buildAdditionalServiceChip(context, 'Mobiliario Extra'),
//           ],
//         ),
        
//         const SizedBox(height: 24),
        
//         // Terms and conditions
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surfaceVariant.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: colorScheme.surfaceVariant,
//               width: 1,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Términos y Condiciones',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _buildTermItem('Se requiere un depósito del 50% para confirmar la reserva'),
//               _buildTermItem('La cancelación con menos de 7 días de anticipación implica la pérdida del depósito'),
//               _buildTermItem('El número final de invitados debe confirmarse 3 días antes del evento'),
//               _buildTermItem('Los precios no incluyen IVA'),
//               _buildTermItem('Servicios adicionales sujetos a disponibilidad'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildAdditionalServiceChip(BuildContext context, String label) {
//     return FilterChip(
//       label: Text(label),
//       onSelected: (bool selected) {},
//       backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
//       checkmarkColor: Theme.of(context).colorScheme.primary,
//     );
//   }
  
//   Widget _buildTermItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('• '),
//           Expanded(
//             child: Text(text),
//           ),
//         ],
//       ),
//     );
//   }
// }