import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/dish_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Responsive landing page for a single restaurant app.
/// Implements full responsiveness for mobile, tablet, and desktop
/// using the latest Material 3 and web design practices.
class ResponsiveLandingPage extends ConsumerStatefulWidget {
  const ResponsiveLandingPage({super.key});

  @override
  ConsumerState<ResponsiveLandingPage> createState() =>
      _ResponsiveLandingPageState();
}

class _ResponsiveLandingPageState extends ConsumerState<ResponsiveLandingPage> {
  List<Map<String, dynamic>>? randomDishes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectRandomDishes();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      body: _errorMessage != null
          ? _buildErrorView()
          : isMobile
              ? buildMobileView(context)
              : isTablet
                  ? buildTabletView(context)
                  : buildDesktopView(context),
    );
  }

  // Error view for data loading errors.
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

  // Mobile view layout.
  Widget buildMobileView(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async => _selectRandomDishes(),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const HeroSection(),
                    const PerksSectionMobile(),
                    const PlansSectionMobile(),
                    DishesSectionMobile(randomDishes: randomDishes),
                    const ContactSection(),
                    const FooterSection(),
                  ],
                ),
              ),
      ),
    );
  }

  // Tablet view layout.
  Widget buildTabletView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _selectRandomDishes(),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const HeroSection(),
                  const PerksSectionTablet(),
                  const PlansSectionTablet(),
                  DishesSectionTablet(randomDishes: randomDishes),
                  const ContactSection(),
                  const FooterSection(),
                ],
              ),
            ),
    );
  }

  // Desktop view layout.
  Widget buildDesktopView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _selectRandomDishes(),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const HeroSection(),
                  const PerksSectionDesktop(),
                  const PlansSectionDesktop(),
                  DishesSectionDesktop(randomDishes: randomDishes),
                  const ContactSection(),
                  const FooterSection(),
                ],
              ),
            ),
    );
  }
}

/// ------------------------
/// Hero Section
/// ------------------------
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    // On mobile, use a taller hero to accommodate wrapping text.
    final heroHeight = isMobile ? size.height * 0.6 : size.height * 0.5;

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.primaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Experiencia Gastronómica Saludable!',
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Disfruta de comidas exquisitas, saludables y con presentación impecable, entregadas directamente a tu puerta.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: isMobile ? 14 : 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    GoRouter.of(context).goNamed(AppRoute.home.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Explorar Menú',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------
/// Perks Sections
/// ------------------------
/// Mobile Perks Section
class PerksSectionMobile extends StatelessWidget {
  const PerksSectionMobile({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final perksHeight = screenHeight * 0.3;

    const perks = [
      {
        'title': 'Ingredientes Frescos',
        'description': 'Ingredientes orgánicos y frescos garantizan el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description': 'Platos que se ven tan bien como saben.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description': 'Planes adaptados a tus necesidades.',
        'icon': Icons.person,
      },
    ];

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: perksHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: perks.length,
              itemBuilder: (context, index) {
                final perk = perks[index];
                return PerkCard(
                  title: perk['title'] as String,
                  description: perk['description'] as String,
                  icon: perk['icon'] as IconData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet Perks Section
class PerksSectionTablet extends StatelessWidget {
  const PerksSectionTablet({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    const perks = [
      {
        'title': 'Ingredientes Frescos',
        'description': 'Ingredientes orgánicos y frescos garantizan el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description': 'Platos que se ven tan bien como saben.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description': 'Planes adaptados a tus necesidades.',
        'icon': Icons.person,
      },
    ];
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: perks.map((perk) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PerkCard(
                  title: perk['title'] as String,
                  description: perk['description'] as String,
                  icon: perk['icon'] as IconData,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

/// Desktop Perks Section
class PerksSectionDesktop extends StatelessWidget {
  const PerksSectionDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: const [
              PerkCard(
                title: 'Ingredientes Frescos',
                description: 'Ingredientes orgánicos y frescos garantizan el mejor sabor.',
                icon: Icons.eco,
              ),
              PerkCard(
                title: 'Presentación Exquisita',
                description: 'Platos que se ven tan bien como saben.',
                icon: Icons.palette,
              ),
              PerkCard(
                title: 'Servicio Personalizado',
                description: 'Planes adaptados a tus necesidades.',
                icon: Icons.person,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Perk Card widget.
class PerkCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  const PerkCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 240,
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: colorScheme.surfaceVariant,
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------
/// Plans Sections
/// ------------------------
/// Mobile Plans Section
class PlansSectionMobile extends ConsumerWidget {
  const PlansSectionMobile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Nuestros Planes',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          mealPlans.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colorScheme.secondary),
                      const SizedBox(height: 16),
                      Text('Cargando planes...', style: textTheme.bodyLarge),
                    ],
                  ),
                )
              : SizedBox(
                  height: 340,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mealPlans.length,
                    itemBuilder: (context, index) {
                      final mealPlan = mealPlans[index];
                      return PlanCard(
                        planName: mealPlan.title,
                        description: mealPlan.description,
                        price: mealPlan.price,
                        planId: mealPlan.id,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

/// Tablet Plans Section
class PlansSectionTablet extends ConsumerWidget {
  const PlansSectionTablet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Nuestros Planes',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          mealPlans.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colorScheme.secondary),
                      const SizedBox(height: 16),
                      Text('Cargando planes...', style: textTheme.bodyLarge),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: mealPlans.map((mealPlan) {
                    return PlanCard(
                      planName: mealPlan.title,
                      description: mealPlan.description,
                      price: mealPlan.price,
                      planId: mealPlan.id,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

/// Desktop Plans Section
class PlansSectionDesktop extends ConsumerWidget {
  const PlansSectionDesktop({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Text(
            'Nuestros Planes',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 40),
          mealPlans.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colorScheme.secondary),
                      const SizedBox(height: 16),
                      Text('Cargando planes...', style: textTheme.bodyLarge),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: mealPlans.map((mealPlan) {
                    return PlanCard(
                      planName: mealPlan.title,
                      description: mealPlan.description,
                      price: mealPlan.price,
                      planId: mealPlan.id,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

/// Reusable Plan Card widget.
class PlanCard extends StatelessWidget {
  final String planName;
  final String description;
  final String price;
  final String planId;
  const PlanCard({
    super.key,
    required this.planName,
    required this.description,
    required this.price,
    required this.planId,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    IconData planIcon;
    switch (planId) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage;
        break;
      case 'estandar':
        planIcon = Icons.local_cafe;
        break;
      case 'premium':
        planIcon = Icons.local_dining;
        break;
      default:
        planIcon = Icons.fastfood;
    }
    return Container(
      width: 300,
      height: 340,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: colorScheme.surfaceVariant,
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(planIcon, size: 70, color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                planName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                price,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).goNamed(
                    AppRoute.planDetails.name,
                    pathParameters: {'planId': planId},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Ver Detalles',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------
/// Dishes Sections
/// ------------------------
/// Mobile Dishes Section
/// ------------------------
/// Dishes Section for Mobile
/// ------------------------
class DishesSectionMobile extends StatelessWidget {
  final List<Map<String, dynamic>>? randomDishes;
  const DishesSectionMobile({super.key, this.randomDishes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    // Use 90% of screen width for dish card width
    final dishWidth = screenWidth * 0.9;
    // Use a flatter aspect ratio (0.8) for mobile cards
    final dishHeight = dishWidth * 0.8;

    if (randomDishes == null || randomDishes!.isEmpty) {
      return Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: colorScheme.secondary),
              const SizedBox(height: 16),
              Text('Cargando platos...', style: textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Nuestros Platos',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: dishHeight,
            child: PageView.builder(
              itemCount: randomDishes!.length,
              controller: PageController(viewportFraction: 0.9),
              itemBuilder: (context, index) {
                final dish = randomDishes![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DishItem(
                    key: Key('dish_$index'),
                    index: index,
                    img: dish['img'],
                    title: dish['title'],
                    description: dish['description'],
                    pricing: dish['pricing'],
                    ingredients: List<String>.from(dish['ingredients']),
                    isSpicy: dish['isSpicy'],
                    foodType: dish['foodType'],
                    dishData: dish,
                    hideIngredients: true,
                    fixedHeight: dishHeight,
                    showDetailsButton: true,
                    showAddButton: true,
                    useHeroAnimation: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Todos nuestros platos',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/// Tablet Dishes Section
/// ------------------------
/// Dishes Section for Tablet
/// ------------------------
class DishesSectionTablet extends StatelessWidget {
  final List<Map<String, dynamic>>? randomDishes;
  const DishesSectionTablet({super.key, this.randomDishes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (randomDishes == null || randomDishes!.isEmpty) {
      return Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: colorScheme.secondary),
              const SizedBox(height: 16),
              Text('Cargando platos...', style: textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // For tablet, we show a grid with two columns.
        final double availableWidth = constraints.maxWidth;
        const double spacing = 16.0;
        // Compute cell width for two columns.
        final double cellWidth = (availableWidth - spacing) / 2;
        // Adjust cell height based on a comfortable aspect ratio.
        final double cellHeight = cellWidth * 1.1;
        // Calculate grid height: number of rows = ceil(total items / 2).
        final int rows = (randomDishes!.length / 2).ceil();
        final double gridHeight = rows * cellHeight + (rows - 1) * spacing;

        return Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              Text(
                'Nuestros Platos',
                style: textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: cellWidth / cellHeight,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: randomDishes!.length,
                  itemBuilder: (context, index) {
                    final dish = randomDishes![index];
                    return DishItem(
                      key: Key('dish_$index'),
                      index: index,
                      img: dish['img'],
                      title: dish['title'],
                      description: dish['description'],
                      pricing: dish['pricing'],
                      ingredients: List<String>.from(dish['ingredients']),
                      isSpicy: dish['isSpicy'],
                      foodType: dish['foodType'],
                      dishData: dish,
                      hideIngredients: false,
                      useHorizontalLayout: false,
                      fixedWidth: cellWidth,
                      fixedHeight: cellHeight,
                      showDetailsButton: true,
                      showAddButton: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).goNamed(AppRoute.details.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Ver Menú Completo',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


/// ------------------------
/// Dishes Section for Desktop
/// ------------------------
class DishesSectionDesktop extends StatelessWidget {
  final List<Map<String, dynamic>>? randomDishes;
  const DishesSectionDesktop({super.key, this.randomDishes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (randomDishes == null || randomDishes!.isEmpty) {
      return Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: colorScheme.secondary),
              const SizedBox(height: 16),
              Text('Cargando platos...', style: textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Text(
            'Nuestros Platos',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 40),
          DesktopDishGridView(
            items: randomDishes!,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).goNamed(AppRoute.details.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Ver Menú Completo',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Desktop Dish Grid View
/// ------------------------
/// A custom grid view for desktop devices that displays a fixed number of columns
/// based on the available width.
class DesktopDishGridView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool hideIngredients;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  
  const DesktopDishGridView({
    super.key,
    required this.items,
    this.hideIngredients = false,
    this.padding = const EdgeInsets.all(16),
    this.scrollable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth;
      // Use fixed column counts based on width thresholds.
      int crossAxisCount;
      if (availableWidth >= 1400) {
        crossAxisCount = 4;
      } else if (availableWidth >= 1024) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 2;
      }
      const double spacing = 16.0;
      final double totalSpacing = (crossAxisCount - 1) * spacing;
      final double cellWidth = (availableWidth - totalSpacing) / crossAxisCount;
      // For desktop, use an aspect ratio that gives a balanced cell – adjust as needed.
      final double cellHeight = cellWidth * 0.75;
      final double aspectRatio = cellWidth / cellHeight;
      
      final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      );
      
      final gridView = GridView.builder(
        // shrinkWrap: true,
        physics: scrollable 
            ? const AlwaysScrollableScrollPhysics() 
            : const NeverScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        itemCount: items.length,
        padding: padding,
        itemBuilder: (context, index) {
          final item = items[index];
          return DishItem(
            img: item["img"] ?? '',
            title: item["title"] ?? 'Unknown Item',
            description: item["description"] ?? '',
            pricing: item["pricing"] ?? '0',
            offertPricing: item["offertPricing"],
            ingredients: item["ingredients"] != null 
                ? List<String>.from(item["ingredients"]) 
                : [],
            isSpicy: item["isSpicy"] ?? false,
            foodType: item["foodType"] ?? 'Regular',
            isMealPlan: item["isMealPlan"] ?? false,
            key: ValueKey('dish_item_$index'),
            index: index,
            dishData: item,
            hideIngredients: hideIngredients,
            fixedHeight: cellHeight,
          );
        },
      );
      
      final int rows = (items.length / crossAxisCount).ceil();
      final double gridHeight = rows * cellHeight + (rows - 1) * spacing;
      
      return SizedBox(
        height: gridHeight,
        child: gridView,
      );
    });
  }
}

/// ------------------------
/// Contact Section
/// ------------------------
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});
  Future<void> _sendWhatsAppHello(BuildContext context) async {
    const String phoneNumber = '+18099880275';
    final String whatsappUrlMobile =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent('Hola')}';
    final String whatsappUrlWeb =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent('Hola!')}';
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrlMobile))) {
        log('MOBILE: $whatsappUrlMobile');
        await launchUrl(Uri.parse(whatsappUrlMobile));
      } else if (await canLaunchUrl(Uri.parse(whatsappUrlWeb))) {
        await launchUrl(Uri.parse(whatsappUrlWeb));
        log('WEB: $whatsappUrlWeb');
      } else {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir WhatsApp: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Contáctanos',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Si tienes preguntas o necesitas un servicio personalizado, contáctanos.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Email: mesaredonda.rd@gmail.com',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Teléfono: +1 849 359 0832',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () => _sendWhatsAppHello(context),
            icon: Icon(Icons.message, color: colorScheme.onPrimary),
            label: Text(
              'Envíanos un Mensaje',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------
/// Footer Section
/// ------------------------
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '© 2024 Tu Cocina Digital',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary.withOpacity(0.9),
                ),
                child: Text(
                  'Política de Privacidad',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary.withOpacity(0.9),
                ),
                child: Text(
                  'Términos del Servicio',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.facebook),
                color: colorScheme.onPrimary,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.photo_camera),
                color: colorScheme.onPrimary,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.social_distance),
                color: colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}