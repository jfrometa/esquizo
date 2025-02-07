import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
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
    final dishes = ref.watch(dishProvider);
    final filteredDishes = _searchQuery.isEmpty
        ? dishes
        : dishes.where((dish) {
            final dishTitle = dish['title']?.toLowerCase() ?? '';
            return dishTitle.contains(_searchQuery.toLowerCase());
          }).toList();

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
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
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                      child: Column(
                        children: [
                          const HomeCategoriesSection(),
                          const SizedBox(height: 30.0),
                          HomeDishesSection(dishes: filteredDishes),
                          const SizedBox(height: 30.0),
                        ],
                      ),
                    )
                  : HomeSearchResults(filteredDishes: filteredDishes),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SearchCard(onChanged: _updateSearchQuery),
    );
  }

  Widget buildCategoryRow(String category, BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: const Text(
              "Ver todos",
              style: TextStyle(
                color: ColorsPaletteRedonda.deepBrown1,
              ),
            ),
            onPressed: () {
              context.goNamed(AppRoute.category.name);
            },
          ),
        ],
      ),
    );
  }

  // Update this function to navigate to different screens based on the service
  Widget buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Focus(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              Map cat = categories[index];

              // Determine the navigation action based on the category name
              void navigateToCategory() {
                if (cat['name'] == 'Meal Plans') {
                  // Navigate to the Meal Plans screen
                  context.goNamed(AppRoute.mealPlan.name);
                } else if (cat['name'] == 'Catering') {
                  // Navigate to the Catering screen
                  context.goNamed(AppRoute.caterings.name);
                } else if (cat['name'] == 'Almuerzos') {
                  // Almuerzos stays the same, navigating to its usual screen

                  context.goNamed(
                    AppRoute.details.name,
                    extra: cat,
                  );
                } else {
                  // Default navigation action
                  context.goNamed(AppRoute.details.name, extra: cat);
                }
              }

              return GestureDetector(
                onTap: navigateToCategory,
                child: CategoryItem(cat: cat),
              );
            },
          ),
        ),
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              node.nextFocus();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              node.previousFocus();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }

  Widget buildDishRow(String title, BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: const Text(
              "Ver todos",
              style: TextStyle(
                color: ColorsPaletteRedonda.deepBrown1,
              ),
            ),
            onPressed: () {
              context.goNamed(AppRoute.trending.name);
            },
          ),
        ],
      ),
    );
  }

  Widget buildDishList(BuildContext context, List dishes) {
    double height = 380;

    return SizedBox(
      height: height,
      child: Focus(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (BuildContext context, int index) {
              Map dish = dishes[index];

              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    AppRoute.addToOrder.name,
                    pathParameters: {
                      "itemId": index.toString(),
                    },
                    extra: dish,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 300, // Set maximum width for the card
                      minWidth: 250, // Optional: Set a minimum width
                    ),
                    child: SlideItem(
                      key: Key('dish_$index'),
                      index: index,
                      img: dish["img"],
                      title: dish["title"],
                      description: dish["description"],
                      pricing: dish["pricing"],
                      offertPricing: dish["offertPricing"],
                      ingredients: (dish["ingredients"] as List<dynamic>).cast<
                          String>(), // Ensure ingredients are a List<String>
                      isSpicy: dish["isSpicy"],
                      foodType: dish["foodType"],
                      actionButton: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Se agregó ${dish['title']}  al carrito'),
                              backgroundColor: Colors
                                  .brown[200], // Light brown background color
                              duration: const Duration(
                                  milliseconds:
                                      500), // Display for half a second
                            ),
                          );
                          // Add the dish directly to the cart
                          ref.read(cartProvider.notifier).addToCart(
                              dish.cast<String, dynamic>(),
                              1); // Cast the dish to Map<String, dynamic>
                        },
                        child: const Text('Agregar al carrito'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              node.nextFocus();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              node.previousFocus();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }

  Widget buildSearchResults(List filteredDishes) {
    if (filteredDishes.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron platos.',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              AppRoute.addToOrder.name,
              pathParameters: {"itemId": index.toString()},
              extra: dish,
            );
          },
          child: Container(
            height: 400,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: SlideItem(
              index: index,
              img: dish["img"],
              title: dish["title"],
              description: dish["description"],
              pricing: dish["pricing"],
              offertPricing: dish["offertPricing"],
              ingredients: dish["ingredients"],
              isSpicy: dish["isSpicy"],
              foodType: dish["foodType"],
              key: Key('dish_$index'),
              actionButton: ElevatedButton(
                onPressed: () {
                  // Add the dish directly to the cart
                  ref.read(cartProvider.notifier).addToCart(
                      dish.cast<String, dynamic>(),
                      1); // Cast the dish to Map<String, dynamic>
                },
                child: const Text('Agregar al carrito'),
              ),
            ),
          ),
        );
      },
    );
  }

}
