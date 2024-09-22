import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart'; // Assuming this contains dishes data
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/category_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/search_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 30.0),
              buildSearchBar(context),
              const SizedBox(height: 30.0),
              _searchQuery.isEmpty
                  ? Column(
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
                    )
                  : buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
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
      height: MediaQuery.of(context).size.height / 6,
      child: Focus(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            primary: false,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = MediaQuery.of(context).size.height / 2.4;
        height = height * 2 / 3; // Reduce by 1/3

        return SizedBox(
          height: height,
          width: MediaQuery.of(context).size.width,
          child: Focus(
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: GridView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                controller: ScrollController(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Always 1 row
                  childAspectRatio: constraints.maxWidth /
                      ((constraints.maxWidth >= 1200
                              ? 1200
                              : constraints.maxWidth) /
                          1),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: plans.length,
                itemBuilder: (BuildContext context, int index) {
                  Map dish = plans[index];

                  return GestureDetector(
                    onTap: () {
                      context.goNamed(
                        AppRoute.addToOrder.name,
                        pathParameters: {
                          "itemId": plans[index].toString(),
                        },
                        extra: dish,
                      );
                    },
                    child: SlideItem(
                      img: dish["img"],
                      title: dish["title"],
                      address: dish["address"],
                      rating: dish["rating"],
                      key: Key('dish_$index'),
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
      },
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = _filteredDishes[index];
        return buildDishItem(dish);
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
        dish['address'] ?? '',
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

// widgets_mesa_redonda/search_card.dart
class SearchCard extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchCard({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar platos...',
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey),
        prefixIcon:
            Icon(Icons.search, color: Theme.of(context).iconTheme.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
