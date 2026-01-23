import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// FILTER BOTTOM SHEET
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
// ... previous code ...

  double _priceRange = 100.0;
  List<String> _selectedCategories = [];
  List<String> _selectedDietaryOptions = [];
  bool _onlySpecialOffers = false;

  final List<String> _cuisineTypes = [
    'Peruvian',
    'Italian',
    'Japanese',
    'Mexican',
    'Chinese',
    'Thai'
  ];

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Low-Carb'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQueryInset = MediaQuery.viewInsetsOf(context);
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // Ensure the bottom sheet doesn't overlap with the keyboard
        bottom: 24 + mediaQueryInset.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Make the bottom sheet scrollable for smaller screens
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const SizedBox(height: 24),

            // Price range filter
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

            const SizedBox(height: 24),

            // Cuisine type filter
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
              children: _cuisineTypes.map((cuisine) {
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

            const SizedBox(height: 24),

            // Dietary restrictions filter
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
              children: _dietaryOptions.map((option) {
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

            const SizedBox(height: 16),

            // Special offers switch
            SwitchListTile(
              title: const Text('Special Offers Only'),
              value: _onlySpecialOffers,
              onChanged: (value) {
                setState(() {
                  _onlySpecialOffers = value;
                });
                HapticFeedback.selectionClick();
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
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
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters and close sheet
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
