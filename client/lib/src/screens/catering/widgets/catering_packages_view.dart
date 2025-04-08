import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_packages_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cateringPackagesAsync = ref.watch(activePackagesProvider);

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

        // Catering packages with loading and empty states
        cateringPackagesAsync.when(
          data: (cateringPackages) {
            if (cateringPackages.isEmpty) {
              return _buildEmptyState(theme);
            }

            // Track view in analytics (optional)
            AnalyticsService.instance.logViewItemList(
              listId: 'catering_packages',
              listName: 'Catering Packages',
              items: cateringPackages
                  .map((package) => AnalyticsEventItem(
                        itemId: package.id,
                        itemName: package.name,
                        price: package.basePrice,
                      ))
                  .toList(),
            );

            return LayoutBuilder(builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: screenWidth > 600 ? 2.7 : 2.3,
                ),
                itemCount: cateringPackages.length,
                itemBuilder: (context, index) {
                  final package = cateringPackages[index];

                  return CateringPackageCard(
                    package: package,
                    // onTap: () =>
                    //     _showCateringForm(context, ref, package.toJson()),
                  );
                },
              );
            });
          },
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) {
            // Log the error for debugging purposes
            debugPrint('Error loading catering packages: $error');
            if (kDebugMode) {
              debugPrintStack(stackTrace: stackTrace);
            }

            return _buildErrorState(theme, error);
          },
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
                    color:
                        theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
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

  // Helper method for loading state
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading catering packages...'),
        ],
      ),
    );
  }

  // Helper method for empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No catering packages available',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later or request a custom quote',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method for error state
  Widget _buildErrorState(ThemeData theme, Object error) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load catering packages',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later or contact support',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
