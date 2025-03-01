import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/home/provider/recent_search_notifier.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/category_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/search_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/home_search_section.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/home_categories_section.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/home_dishes_section.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/home_search_results.dart';

// Create a provider for recent searches
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

/// The Home screen for the app.
class MenuHome extends ConsumerStatefulWidget {
  const MenuHome({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<MenuHome> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanges);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanges);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchChanges() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _handleSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      // Save to recent searches
      ref.read(recentSearchesProvider.notifier).addSearch(query);
      // Update search state
      setState(() {
        _searchQuery = query;
        _isSearching = true;
      });
      // Close keyboard
      FocusScope.of(context).unfocus();
      // Provide haptic feedback for submission
      HapticFeedback.mediumImpact();
    }
  }

  void _handleRecentSearchTap(String search) {
    _searchController.text = search;
    _handleSearchSubmitted(search);
  }

  void _handleFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read the dish list from your provider.
    final dishes = ref.watch(dishProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    // Filter dishes based on search query.
    final filteredDishes = _searchQuery.isEmpty
        ? dishes
        : dishes.where((dish) {
            final dishTitle = dish['title']?.toLowerCase() ?? '';
            final dishDescription = dish['description']?.toLowerCase() ?? '';
            final dishCategory = dish['category']?.toLowerCase() ?? '';

            final query = _searchQuery.toLowerCase();
            return dishTitle.contains(query) ||
                dishDescription.contains(query) ||
                dishCategory.contains(query);
          }).toList();

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside.
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kako"),
          forceMaterialTransparency: true,
          elevation: 3,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                context.pushNamed(AppRoute.homecart.name);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            HomeSearchSection(
              onSearch: _updateSearchQuery,
              recentSearches: recentSearches,
              onRecentSearchTap: _handleRecentSearchTap,
              onFilterTap: _handleFilterTap,
              showRecentSearches: true,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _isSearching
                  ? HomeSearchResults(
                      filteredDishes: filteredDishes,
                      searchQuery: _searchQuery,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    )
                  : const _MainHomeView(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the main home view when no search query is active.
class _MainHomeView extends ConsumerWidget {
  const _MainHomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh data logic
          ref.refresh(dishProvider);
          HapticFeedback.mediumImpact();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeCategoriesSection(),
              const SizedBox(height: 30),

              // Featured section
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Platillos destacados',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      
                      onPressed: () {
                         context.goNamed(AppRoute.allDishes.name);
                        HapticFeedback.selectionClick();
                      },
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ),

              const HomeDishesSection(),

              // Popular caterers/restaurants section
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurantes populares',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to see all restaurants
                        HapticFeedback.selectionClick();
                      },
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ),

              // Restaurants list (placeholder)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Container(
                                height: 100,
                                color: Colors.grey[300],
                                // Replace with actual restaurant image
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Restaurante ${index + 1}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16, color: Colors.amber),
                                      Text(' 4.${5 + index} ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      Text('• Categoría',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ],
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter bottom sheet for advanced search functionality
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  double _priceRange = 100.0;
  List<String> _selectedCategories = [];
  bool _onlyVegetarian = false;

  final List<String> _cuisineTypes = [
    'Peruana',
    'Italiana',
    'Japonesa',
    'Mexicana',
    'China',
    'Tailandesa'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtros', style: theme.textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Rango de precio', style: theme.textTheme.titleMedium),
          Slider(
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
          const SizedBox(height: 24),
          Text('Tipo de cocina', style: theme.textTheme.titleMedium),
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
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Solo vegetariano'),
            value: _onlyVegetarian,
            onChanged: (value) {
              setState(() {
                _onlyVegetarian = value;
              });
              HapticFeedback.selectionClick();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters and close sheet
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: ColorsPaletteRedonda.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aplicar filtros'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Reset filters
                setState(() {
                  _priceRange = 100.0;
                  _selectedCategories = [];
                  _onlyVegetarian = false;
                });
                HapticFeedback.lightImpact();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Restablecer filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
