import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_form_sheet.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/catering_prackages_view.dart'; 

/// A view displaying available catering packages
class CateringPackagesView extends ConsumerWidget {
  /// Scroll controller for the list view
  final ScrollController scrollController;
  
  /// Callback when a package is selected
  final Function(Map<String, dynamic>)? onPackageSelected;
  
  /// Callback to create a custom quote
  final VoidCallback? onCreateCustomQuote;

  const CateringPackagesView({
    super.key,
    required this.scrollController,
    this.onPackageSelected,
    this.onCreateCustomQuote,
  });

  // Catering packages data
  static const List<Map<String, dynamic>> _cateringPackages = [
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Text(
          'Catering Services',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Perfect for events, parties, and corporate meetings',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        
        // Catering packages grid
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: screenWidth > 600 ? 0.85 : 1.2,
              ),
              itemCount: _cateringPackages.length,
              itemBuilder: (context, index) {
                final package = _cateringPackages[index];
                
                return CateringPackageCard(
                  package: package,
                  onTap: () => _showCateringForm(context, ref, package),
                );
              },
            );
          }
        ),
        
        const SizedBox(height: 30),
        
        // Custom catering form teaser
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Something Custom?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your event and we\'ll create the perfect menu',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onCreateCustomQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Create Custom Quote'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _showCateringForm(BuildContext context, WidgetRef ref, Map<String, dynamic> package) {
    showCateringFormSheet(
      context: context,
      ref: ref,
      title: 'Detalles del ${package['title']}',
      package: package,
      onSuccess: (updatedPackage) {
        if (onPackageSelected != null) {
          onPackageSelected!(updatedPackage);
        }
      },
    );
  }
}