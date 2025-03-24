import 'package:flutter/material.dart';

/// A card component displaying a catering package
class CateringPackageCard extends StatelessWidget {
  /// The package data to display
  final Map<String, dynamic> package;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(colorScheme),
              const SizedBox(height: 16),
              _buildTitle(theme),
              const SizedBox(height: 8),
              _buildDescription(theme, colorScheme),
              const SizedBox(height: 8),
              _buildPrice(colorScheme),
              const SizedBox(height: 16),
              _buildActionButton(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: Icon(
        package['icon'],
        size: 36,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      package['name'],
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      package['description'],
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice(ColorScheme colorScheme) {
    final price = package['basePrice'].toString();
    return Column(
      children: [
        Text(
          'Starting from',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Select Package'),
      ),
    );
  }
}
