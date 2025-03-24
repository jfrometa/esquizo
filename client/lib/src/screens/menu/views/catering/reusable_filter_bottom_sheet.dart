import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data model for filter options
class FilterOptions {
  final double priceRange;
  final List<String> selectedCategories;
  final List<String> selectedDietaryOptions;
  final bool onlySpecialOffers;

  FilterOptions({
    this.priceRange = 100.0,
    this.selectedCategories = const [],
    this.selectedDietaryOptions = const [],
    this.onlySpecialOffers = false,
  });

  /// Create a copy with updated fields
  FilterOptions copyWith({
    double? priceRange,
    List<String>? selectedCategories,
    List<String>? selectedDietaryOptions,
    bool? onlySpecialOffers,
  }) {
    return FilterOptions(
      priceRange: priceRange ?? this.priceRange,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedDietaryOptions: selectedDietaryOptions ?? this.selectedDietaryOptions,
      onlySpecialOffers: onlySpecialOffers ?? this.onlySpecialOffers,
    );
  }
}

/// A reusable bottom sheet for filtering items
class FilterBottomSheet extends StatefulWidget {
  /// Initial filter options
  final FilterOptions initialOptions;
  
  /// Available cuisine types to filter
  final List<String> cuisineTypes;
  
  /// Available dietary options to filter
  final List<String> dietaryOptions;
  
  /// Callback when filters are applied
  final Function(FilterOptions) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.initialOptions,
    required this.cuisineTypes,
    required this.dietaryOptions,
    required this.onApplyFilters,
  });
  
  /// Show the filter bottom sheet
  static Future<void> show({
    required BuildContext context,
    required FilterOptions initialOptions,
    required List<String> cuisineTypes,
    required List<String> dietaryOptions,
    required Function(FilterOptions) onApplyFilters,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialOptions: initialOptions,
        cuisineTypes: cuisineTypes,
        dietaryOptions: dietaryOptions,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _priceRange;
  late List<String> _selectedCategories;
  late List<String> _selectedDietaryOptions;
  late bool _onlySpecialOffers;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided initial options
    _priceRange = widget.initialOptions.priceRange;
    _selectedCategories = List.from(widget.initialOptions.selectedCategories);
    _selectedDietaryOptions = List.from(widget.initialOptions.selectedDietaryOptions);
    _onlySpecialOffers = widget.initialOptions.onlySpecialOffers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    final mediaQueryInset = MediaQuery.viewInsetsOf(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // Ensure the bottom sheet doesn't overlap with the keyboard
        bottom: 24 + mediaQueryInset.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // Make the bottom sheet scrollable for smaller screens
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildPriceRangeSection(theme),
            const SizedBox(height: 24),
            _buildCuisineTypeSection(theme),
            const SizedBox(height: 24),
            _buildDietaryRestrictionsSection(theme),
            const SizedBox(height: 16),
            _buildSpecialOffersSwitch(theme),
            const SizedBox(height: 24),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter Menu Items',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
      ],
    );
  }
  
  Widget _buildPriceRangeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Text('S/ 0'),
            Expanded(
              child: Slider(
                value: _priceRange,
                min: 0,
                max: 200,
                divisions: 20,
                label: 'S/ ${_priceRange.round()}',
                onChanged: (value) {
                  setState(() {
                    _priceRange = value;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            Text('S/ 200'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCuisineTypeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuisine Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.cuisineTypes.map((cuisine) {
            final isSelected = _selectedCategories.contains(cuisine);
            return FilterChip(
              label: Text(cuisine),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(cuisine);
                  } else {
                    _selectedCategories.remove(cuisine);
                  }
                });
                HapticFeedback.selectionClick();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDietaryRestrictionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Restrictions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.dietaryOptions.map((option) {
            final isSelected = _selectedDietaryOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDietaryOptions.add(option);
                  } else {
                    _selectedDietaryOptions.remove(option);
                  }
                });
                HapticFeedback.selectionClick();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSpecialOffersSwitch(ThemeData theme) {
    return SwitchListTile(
      title: const Text('Special Offers Only'),
      value: _onlySpecialOffers,
      onChanged: (value) {
        setState(() {
          _onlySpecialOffers = value;
        });
        HapticFeedback.selectionClick();
      },
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Widget _buildActionButtons(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Reset filters
              setState(() {
                _priceRange = 100.0;
                _selectedCategories = [];
                _selectedDietaryOptions = [];
                _onlySpecialOffers = false;
              });
              HapticFeedback.lightImpact();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reset Filters'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: () {
              // Apply filters and close sheet
              widget.onApplyFilters(FilterOptions(
                priceRange: _priceRange,
                selectedCategories: _selectedCategories,
                selectedDietaryOptions: _selectedDietaryOptions,
                onlySpecialOffers: _onlySpecialOffers,
              ));
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}