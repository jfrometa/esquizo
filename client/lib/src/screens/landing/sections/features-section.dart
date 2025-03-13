import 'package:flutter/material.dart';

/// Features section showcasing restaurant perks/values for mobile
class FeaturesSectionMobile extends StatelessWidget {
  const FeaturesSectionMobile({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    const features = [
      {
        'title': 'Ingredientes Frescos',
        'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
        'icon': Icons.person,
      },
      {
        'title': 'Ambiente Acogedor',
        'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
        'icon': Icons.home,
      },
    ];
    
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feature['description'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Features section showcasing restaurant perks/values for tablet
class FeaturesSectionTablet extends StatelessWidget {
  const FeaturesSectionTablet({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    const features = [
      {
        'title': 'Ingredientes Frescos',
        'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
        'icon': Icons.person,
      },
      {
        'title': 'Ambiente Acogedor',
        'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
        'icon': Icons.home,
      },
    ];
    
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Features section showcasing restaurant perks/values for desktop
class FeaturesSectionDesktop extends StatelessWidget {
  const FeaturesSectionDesktop({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    const features = [
      {
        'title': 'Ingredientes Frescos',
        'description': 'Seleccionamos cuidadosamente ingredientes orgánicos y frescos para garantizar el mejor sabor.',
        'icon': Icons.eco,
      },
      {
        'title': 'Presentación Exquisita',
        'description': 'Platos elaborados artísticamente para deleitar todos sus sentidos.',
        'icon': Icons.palette,
      },
      {
        'title': 'Servicio Personalizado',
        'description': 'Ofrecemos planes adaptados a sus necesidades y preferencias personales.',
        'icon': Icons.person,
      },
      {
        'title': 'Ambiente Acogedor',
        'description': 'Un entorno cálido y elegante para disfrutar de momentos inolvidables.',
        'icon': Icons.home,
      },
    ];
    
    return Container(
      color: colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      child: Column(
        children: [
          Text(
            '¿Por qué Elegirnos?',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Nos esforzamos por ofrecer experiencias gastronómicas excepcionales',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        feature['title'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['description'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
