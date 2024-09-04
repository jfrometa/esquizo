import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/category_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/search_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
              buildCategoryRow('Servicios', context),
              const SizedBox(height: 10.0),
              buildCategoryList(context),
              const SizedBox(height: 30.0),
              buildRestaurantRow('Los Mas Populares', context),
              const SizedBox(height: 10.0),
              buildRestaurantList(context),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRestaurantRow(String restaurant, BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            restaurant,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
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

  Widget buildCategoryRow(String category, BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            category,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
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

  Widget buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: SearchCard(),
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

  Widget buildRestaurantList(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2.4,
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
                  Map restaurant = plans[index];

                  return GestureDetector(
                    onTap: () {
                      context.goNamed(
                        AppRoute.addToOrder.name,
                        pathParameters: {
                          // "detailItemId": plans[index].toString(),
                          "itemId": plans[index].toString(),
                        },
                        extra: restaurant,
                      );
                    },
                    child: SlideItem(
                      img: restaurant["img"],
                      title: restaurant["title"],
                      address: restaurant["address"],
                      rating: restaurant["rating"],
                      key: Key('restaurant_$index'),
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
}
