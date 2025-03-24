import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import '../plans/plans.dart';

class PlanDetailsScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailsScreen({super.key, required this.planId});

  String cleanPrice(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.contains('.')) {
      List<String> parts = cleaned.split('.');
      cleaned = '${parts[0]}.${parts.skip(1).join('')}';
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrLarger = screenSize.width >= 600;
    
    // Watch the meal plans stream
    final mealPlansAsync = ref.watch(mealPlansProvider);
    
    // Use AsyncValue pattern to handle loading, error, and data states
    return mealPlansAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Plan Details'),
          scrolledUnderElevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load meal plan',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => ref.refresh(mealPlansProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      data: (mealPlans) {
        // Find the selected meal plan
        final mealPlan = mealPlans.firstWhere(
          (plan) => plan.id == planId,
          orElse: () => throw Exception('Plan not found'),
        );

        IconData planIcon;
        switch (mealPlan.id) {
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

        return Scaffold(
          appBar: AppBar(
            title: Text(mealPlan.title),
            scrolledUnderElevation: 0,
            actions: [
              // Add shopping cart button with badge if items are in cart
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      // Navigate to cart
                      GoRouter.of(context).push('/cart');
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final cartItems = ref.watch(mealOrderProvider);
                      if (cartItems.isEmpty) return const SizedBox.shrink();
                      
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartItems.length}',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return isTabletOrLarger 
                    ? _buildTabletLayout(ref, context, mealPlan, planIcon, theme, colorScheme)
                    : _buildMobileLayout(ref, context, mealPlan, planIcon, theme, colorScheme);
              },
            ),
          ),
          bottomNavigationBar: !isTabletOrLarger ? SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealPlan.price,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${mealPlan.totalMeals} meals included',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _addToCart(context, ref, mealPlan),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : null,
        );
      },
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, MealPlan mealPlan) {
    // Add meal plan to meal orders
    ref.read(mealOrderProvider.notifier).addMealSubscription(
      {
        'id': mealPlan.id,
        'img': mealPlan.img,
        'title': mealPlan.title,
        'description': mealPlan.description,
        'pricing': cleanPrice(mealPlan.price),
        'ingredients': <String>[],
        'isSpicy': false,
        'foodType': 'Meal Plan',
        'quantity': 1,
      },
      mealPlan.totalMeals,
    );

    // Show success message with animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Text('${mealPlan.title} añadido al carrito'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back
    GoRouter.of(context).pop();
  }

  Widget _buildMobileLayout(
    WidgetRef ref,
    BuildContext context, 
    MealPlan mealPlan, 
    IconData planIcon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with icon, title, and price
          Center(
            child: Hero(
              tag: 'plan-icon-${mealPlan.id}',
              child: Material(
                shape: const CircleBorder(),
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(
                    planIcon,
                    size: 64,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title and promo badge
          Row(
            children: [
              Expanded(
                child: Text(
                  mealPlan.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (mealPlan.isBestValue)
                Card(
                  color: colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, 
                      vertical: 6.0,
                    ),
                    child: Text(
                      'Mejor valor',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Short description
          Text(
            mealPlan.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Meal count indicator
          _buildMealCountIndicator(mealPlan, theme, colorScheme),
          const SizedBox(height: 24),
          
          // Long description section
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acerca del plan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.longDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // How it works section
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo funciona?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.howItWorks,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Features section
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Características:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...mealPlan.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // Bottom padding to clear the sticky button
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    WidgetRef ref,
    BuildContext context, 
    MealPlan mealPlan, 
    IconData planIcon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Top section with two columns
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column with icon and title
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Hero(
                                tag: 'plan-icon-${mealPlan.id}',
                                child: Material(
                                  shape: const CircleBorder(),
                                  color: colorScheme.primaryContainer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Icon(
                                      planIcon,
                                      size: 64,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (mealPlan.isBestValue)
                                      Card(
                                        color: colorScheme.secondaryContainer,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 6.0,
                                          ),
                                          child: Text(
                                            'Mejor valor',
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: colorScheme.onSecondaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mealPlan.title,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mealPlan.description,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildMealCountIndicator(mealPlan, theme, colorScheme),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            mealPlan.longDescription,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Right column with info box
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalles del Plan',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                mealPlan.price,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                '${mealPlan.totalMeals} meals included',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              
                              // Features quick summary
                              ...mealPlan.features.take(4).map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              
                              if (mealPlan.features.length > 4)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '+ ${mealPlan.features.length - 4} more features',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _addToCart(context, ref, mealPlan),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Agregar al carrito',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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
              
              const SizedBox(height: 32),
              
              // Bottom sections
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // How it works section
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Cómo funciona?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              mealPlan.howItWorks,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Features section
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Todas las Características',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...mealPlan.features.map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
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
    );
  }

  Widget _buildMealCountIndicator(MealPlan mealPlan, ThemeData theme, ColorScheme colorScheme) {
    // Calculate percentage of meals remaining
    final remainingPercentage = mealPlan.mealsRemaining / mealPlan.totalMeals;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total meals: ${mealPlan.totalMeals}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: remainingPercentage,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${mealPlan.mealsRemaining} meals remaining',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}