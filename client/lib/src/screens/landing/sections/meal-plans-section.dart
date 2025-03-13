import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/widget/plan-card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

/// Meal plans section
class MealPlansSection extends ConsumerWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  
  const MealPlansSection({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mealPlans = ref.watch(mealPlansProvider);
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Planes de Comida',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descubra nuestros planes de comida semanales, diseñados para adaptarse a su estilo de vida y preferencias',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          if (mealPlans.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando planes...',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
          else
            // Meal plans grid
            if (isMobile) 
              _buildMobileMealPlansGrid(context, mealPlans)
            else if (isTablet) 
              _buildTabletMealPlansGrid(context, mealPlans)
            else 
              _buildDesktopMealPlansGrid(context, mealPlans),
              
          const SizedBox(height: 32),
          
          // Subscription benefits
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.secondaryContainer,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beneficios de Suscripción',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildBenefitItem(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Entrega Gratuita',
                      description: 'Todos los planes incluyen entrega a domicilio sin costo adicional',
                    ),
                    _buildBenefitItem(
                      context,
                      icon: Icons.sync,
                      title: 'Flexibilidad',
                      description: 'Pausa, reactiva o cambia tu plan en cualquier momento',
                    ),
                    _buildBenefitItem(
                      context,
                      icon: Icons.menu_book,
                      title: 'Menú Personalizado',
                      description: 'Selecciona tus platos favoritos cada semana',
                    ),
                    _buildBenefitItem(
                      context,
                      icon: Icons.eco,
                      title: 'Sostenibilidad',
                      description: 'Envases eco-amigables y prácticas sustentables',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: isMobile ? double.infinity : isTablet ? 220 : 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final mealPlan = mealPlans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PlanCard(
            planName: mealPlan.title,
            description: mealPlan.description,
            price: mealPlan.price,
            planId: mealPlan.id,
          ),
        );
      },
    );
  }
  
  Widget _buildTabletMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // childAspectRatio: 0.85,
        // crossAxisSpacing: 16,
        // mainAxisSpacing: 16,
      ),
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
    );
  }
  
  Widget _buildDesktopMealPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // childAspectRatio: 0.85,
        // crossAxisSpacing: 20,
        // mainAxisSpacing: 20,
      ),
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
    );
  }
}
