import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
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

/// The Home screen for the app.
class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  String _searchQuery = '';

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read the dish list from your provider.
    final dishes = ref.watch(dishProvider);
    // Filter dishes based on search query.
    final filteredDishes = _searchQuery.isEmpty
        ? dishes
        : dishes.where((dish) {
            final dishTitle = dish['title']?.toLowerCase() ?? '';
            return dishTitle.contains(_searchQuery.toLowerCase());
          }).toList();

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside.
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mesa Redonda"),
          forceMaterialTransparency: true,
          elevation: 3,
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            HomeSearchSection(onChanged: _updateSearchQuery),
            const SizedBox(height: 10.0),
            Expanded(
              child: _searchQuery.isEmpty
                  ? const _MainHomeView()
                  : HomeSearchResults(filteredDishes: filteredDishes),
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
    
    // Use a SingleChildScrollView wrapped in ScrollConfiguration (with custom behavior)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        children: const [
          HomeCategoriesSection(),
          SizedBox(height: 30),
          HomeDishesSection(), // This widget can internally decide between ListView or GridView.
          SizedBox(height: 30),
        ],
      ),
    );
  }
}