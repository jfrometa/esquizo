import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/trending.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/friends.dart';
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
              buildSearchBar(context),
              const SizedBox(height: 20.0),
              buildRestaurantRow('Trending Restaurants', context),
              const SizedBox(height: 10.0),
              buildRestaurantList(context),
              const SizedBox(height: 10.0),
              buildCategoryRow('Category', context),
              const SizedBox(height: 10.0),
              buildCategoryList(context),
              const SizedBox(height: 20.0),
              buildCategoryRow('Friends', context),
              // const SizedBox(height: 10.0),
              // buildFriendsList(),
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Text(
            restaurant,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10.0),
          TextButton(
            child: Text(
              "See all (9)",
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Text(
            category,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10.0),
          TextButton(
            child: Text(
              "See all (9)",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const Categories();
                  },
                ),
              );
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
        child: ListView.builder(
          primary: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            Map cat = categories[index];

            return CategoryItem(
              cat: cat,
            );
          },
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
        // Determine the number of items to show based on screen width
        int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 2; // Large screens
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 2; // Tablets
        } else {
          crossAxisCount = 1; // Small screens
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height / 2.4,
          width: MediaQuery.of(context).size.width,
          child: Focus(
            child: GridView.builder(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              controller: ScrollController(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Always 1 row
                childAspectRatio: constraints.maxWidth /
                    (constraints.maxWidth >= 1200 ? 2.0 : 1 / crossAxisCount),
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: restaurants.length,
              itemBuilder: (BuildContext context, int index) {
                Map restaurant = restaurants[index];

                return SlideItem(
                  img: restaurant["img"],
                  title: restaurant["title"],
                  address: restaurant["address"],
                  rating: restaurant["rating"],
                  key: Key('restaurant_$index'),
                );
              },
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
  // Widget buildFriendsList() {
  //   return SizedBox(
  //     height: 50.0,
  //     child: Focus(
  //       child: ListView.builder(
  //         primary: false,
  //         scrollDirection: Axis.horizontal,
  //         shrinkWrap: true,
  //         itemCount: friends.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           String img = friends[index];

  //           return Padding(
  //             padding: const EdgeInsets.only(right: 5.0),
  //             child: CircleAvatar(
  //               backgroundImage: AssetImage(
  //                 img,
  //               ),
  //               radius: 25.0,
  //             ),
  //           );
  //         },
  //       ),
  //       onKeyEvent: (FocusNode node, KeyEvent event) {
  //         if (event is KeyDownEvent) {
  //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //             node.nextFocus();
  //             return KeyEventResult.handled;
  //           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //             node.previousFocus();
  //             return KeyEventResult.handled;
  //           }
  //         }
  //         return KeyEventResult.ignored;
  //       },
  //     ),
  //   );
  // }
}
