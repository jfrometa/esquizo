import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart'; // Assuming this contains dishes data
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/category_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String _searchQuery = '';
  List _filteredDishes = plans; // Initialize with all dishes

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDishes = plans.where((dish) {
        final dishTitle = dish['title']?.toLowerCase() ?? '';
        return dishTitle.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mesa Redonda"),
          scrolledUnderElevation: 0.0,
          actions: const [
            // Consumer(builder: (context, ref, child) {
            //   return IconButton(
            //     onPressed: () {
            //       // ref.read(authProvider).singout();
            //     },
            //     icon: const Icon(
            //       Icons.logout,
            //     ),
            //   );
            // }),
          ],
        ),
        body: Column(
          
          children: <Widget>[
            const SizedBox(height: 10.0),
            buildSearchBar(context),
            const SizedBox(height: 10.0),
            Expanded(
              child: _searchQuery.isEmpty
                  ? SingleChildScrollView(
                    
                      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                      child: Column(
                        children: [
                          buildCategoryRow('Servicios', context),
                          const SizedBox(height: 10.0),
                          buildCategoryList(context),
                          const SizedBox(height: 30.0),
                          buildDishRow('Los Más Populares', context),
                          const SizedBox(height: 10.0),
                          buildDishList(context),
                          const SizedBox(height: 30.0),
                        ],
                      ),
                    )
                  : buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SearchCard(
        onChanged: _updateSearchQuery,
      ),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: Text(
              "Ver todos",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
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

              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    AppRoute.details.name,
                    extra: cat,
                  );
                },
                child: CategoryItem(
                  cat: cat,
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

  Widget buildDishRow(String title, BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: Text(
              "Ver todos",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
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

  Widget buildDishList(BuildContext context) {
    double height = 400 ;

    return SizedBox(
      height: height,
      child: Focus(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (BuildContext context, int index) {
              Map dish = plans[index];

              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    AppRoute.addToOrder.name,
                    pathParameters: {
                      "itemId":  index.toString(),
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
                      img: dish["img"],
                      title: dish["title"],
                      description: dish["description"],
                      pricing: dish["pricing"],
                      offertPricing: dish["offertPricing"],
                      ingredients: dish["ingredients"],
                      isSpicy: dish["isSpicy"],
                      foodType: dish["foodType"],
                      key: Key('dish_$index'),
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

  Widget buildSearchResults() {
    if (_filteredDishes.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron platos.',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: _filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = _filteredDishes[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              AppRoute.addToOrder.name,
              pathParameters: {
                "itemId": dish.toString(),
              },
              extra: dish,
            );
          },
          child: Container(
            height: 400,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: SlideItem(
              img: dish["img"],
              title: dish["title"],
              description: dish["description"],
              pricing: dish["pricing"],
              offertPricing: dish["offertPricing"],
              ingredients: dish["ingredients"],
              isSpicy: dish["isSpicy"],
              foodType: dish["foodType"],
              key: Key('dish_$index'),
            ),
          ),
        );
      },
    );
  }

  Widget buildDishItem(Map dish) {
    return ListTile(
      leading: Image.asset(
        dish['img'],
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(
        dish['title'],
        style: Theme.of(context).textTheme.displayMedium,
      ),
      subtitle: Text(
        dish['description'] ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () {
        context.goNamed(
          AppRoute.addToOrder.name,
          pathParameters: {
            "itemId": dish.toString(),
          },
          extra: dish,
        );
      },
    );
  }
}
 
class SearchCard extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchCard({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust padding as needed
      child: TextField(
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: ColorsPaletteRedonda.deepBrown, // Apply deep brown to input text color
        ),
        decoration: InputDecoration(
          suffixIconColor: ColorsPaletteRedonda.lightBrown,
          focusColor: ColorsPaletteRedonda.lightBrown,
          hintText: 'Buscar platos...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), // Lighter brown for hints
          prefixIcon: const Icon(Icons.search, color: ColorsPaletteRedonda.lightBrown),
          filled: true, // Optional: turn on filling behavior
          fillColor: theme.inputDecorationTheme.fillColor, // Use fill color from the theme if specified
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Typically borders are not visible until focused
          ),
          enabledBorder: OutlineInputBorder( // Normal state border
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder( // Border when the TextField is focused
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
          ),
        ),
      ),
    );
  }
}

