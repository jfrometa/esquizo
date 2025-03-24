import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';

/// A horizontal card component displaying a catering package
class CateringPackageCard extends StatelessWidget {
  /// The package data to display
  final CateringPackage package;

  /// Callback when the card is tapped
  final Function(CateringPackage)? onTap;

  /// Whether this package is currently selected
  final bool isSelected;

  const CateringPackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract package details
    final String title = package.name;
    final String description = package.description;
    final String price = 'S/ ${package.basePrice.toStringAsFixed(2)}';
    final bool isPromoted = package.isPromoted;

    // Get unique item categories from package items
    final List<String> includedCategories = package.items
        .map((item) => item.category)
        .toSet() // Get unique categories
        .toList();

    // Get icon from code point or use a default icon
    IconData packageIcon = Icons.restaurant;
    if (package.iconCodePoint != null && package.iconFontFamily != null) {
      packageIcon = IconData(
        package.iconCodePoint!,
        fontFamily: package.iconFontFamily,
      );
    }

    return Card(
      elevation: isSelected ? 3 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(package) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Icon and price
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Package icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        packageIcon,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Price section
                    Column(
                      children: [
                        Text(
                          'Starting at',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 130,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: colorScheme.outline.withOpacity(0.2),
              ),

              // Right side: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and badge row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isPromoted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Popular',
                              style: TextStyle(
                                color: colorScheme.onTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (includedCategories.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      // Included items section
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Includes:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Included items chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: includedCategories
                                .take(3)
                                .map((category) =>
                                    _buildItemChip(category, colorScheme))
                                .toList() +
                            [
                              if (includedCategories.length > 3)
                                _buildItemChip(
                                    '+${includedCategories.length - 3} more',
                                    colorScheme,
                                    isMore: true)
                            ],
                      ),
                    ],

                    const Spacer(),

                    // Button row
                    Row(
                      children: [
                        // View details button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showDetailsScreen(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text('Details'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Select button
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                onTap != null ? () => onTap!(package) : null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Select'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build item chips with consistent styling
  Widget _buildItemChip(String text, ColorScheme colorScheme,
      {bool isMore = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMore
            ? colorScheme.surfaceVariant.withOpacity(0.7)
            : colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant,
          fontWeight: isMore ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Show detailed information in a new screen
  void _showDetailsScreen(BuildContext context) {
    // Track view in analytics (optional)
    AnalyticsService.instance.logViewItem(
      itemId: package.id,
      itemName: package.name,
      price: package.basePrice,
      itemCategory: 'Catering',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CateringPackageDetailScreen(
          package: package,
          onSelect: onTap != null ? () => onTap!(package) : null,
        ),
      ),
    );
  }
}

/// Detail screen for displaying comprehensive catering package information
class CateringPackageDetailScreen extends StatelessWidget {
  final CateringPackage package;
  final VoidCallback? onSelect;

  const CateringPackageDetailScreen({
    super.key,
    required this.package,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get icon from code point or use a default icon
    IconData packageIcon = Icons.restaurant;
    if (package.iconCodePoint != null && package.iconFontFamily != null) {
      packageIcon = IconData(
        package.iconCodePoint!,
        fontFamily: package.iconFontFamily,
      );
    }

    // Group items by category
    final Map<String, List<PackageItem>> itemsByCategory = {};
    for (var item in package.items) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    // Extract category names for "package includes" section
    final List<String> categories = itemsByCategory.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(package.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with package overview
            Container(
              width: double.infinity,
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Package icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      packageIcon,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Package title
                  Text(
                    package.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    package.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Price badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'S/ ${package.basePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Capacity information
                  if (package.minPeople > 0 || package.maxPeople > 0) ...[
                    _buildSectionTitle('Capacity', Icons.people, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'This package is suitable for ${package.minPeople > 0 ? 'a minimum of ${package.minPeople}' : ''} ${package.minPeople > 0 && package.maxPeople > 0 ? ' to ' : ''} ${package.maxPeople > 0 ? 'a maximum of ${package.maxPeople}' : ''} guests.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Package includes section
                  if (categories.isNotEmpty) ...[
                    _buildSectionTitle(
                        'Package Includes', Icons.check_circle, colorScheme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .map((category) =>
                              _buildFeatureChip(category, colorScheme))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sample menu section
                  if (package.items.isNotEmpty) ...[
                    _buildSectionTitle(
                        'Menu Items', Icons.restaurant_menu, colorScheme),
                    const SizedBox(height: 8),

                    // Group and display menu items by category
                    ...itemsByCategory.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              entry.key,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          ...entry.value.map((item) => Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• '),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name),
                                          if (item.description != null &&
                                              item.description!.isNotEmpty)
                                            Text(
                                              item.description!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (item.price > 0)
                                      Text(
                                        'S/ ${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),

                    const SizedBox(height: 24),
                  ],

                  // Features and benefits section
                  _buildSectionTitle(
                      'Features & Benefits', Icons.star, colorScheme),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      _buildFeatureItem('Professional staff', colorScheme),
                      _buildFeatureItem(
                          'Setup & cleanup included', colorScheme),
                      _buildFeatureItem(
                          'Custom menu options available', colorScheme),
                      if (package.minPeople > 0 || package.maxPeople > 0)
                        _buildFeatureItem(
                            '${package.minPeople}-${package.maxPeople} guests',
                            colorScheme),
                      _buildFeatureItem('Free consultation', colorScheme),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Call to action button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onSelect,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Select This Package'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent section titles
  Widget _buildSectionTitle(
      String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Helper for feature items
  Widget _buildFeatureItem(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  // Helper for feature chips
  Widget _buildFeatureChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
