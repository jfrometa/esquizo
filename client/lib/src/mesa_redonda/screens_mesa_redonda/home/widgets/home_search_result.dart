import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

import '../../../dishes/cards/dish_card.dart';

class HomeSearchResults extends StatelessWidget {
  final List<dynamic> filteredDishes;
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const HomeSearchResults({
    Key? key,
    required this.filteredDishes,
    required this.searchQuery,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filteredDishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados para "$searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (onClearSearch != null) {
                  onClearSearch!();
                  HapticFeedback.mediumImpact();
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: ColorsPaletteRedonda.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultados para "$searchQuery"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${filteredDishes.length} encontrados',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredDishes.length,
            itemBuilder: (context, index) {
              final dish = filteredDishes[index];
              return DishCard(
                dish: dish,
                onTap: () {
                  // Navigate to dish detail
                  // context.pushNamed('dish-detail', params: {'id': dish['id']});
                  HapticFeedback.selectionClick();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
