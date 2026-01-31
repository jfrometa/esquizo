import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/util_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/category_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryRow(context),
        const SizedBox(height: 10.0),
        _buildCategoryList(context),
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Servicios',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: const Text(
              "Ver todos",
            ),
            onPressed: () {
              context.goNamedSafe(AppRoute.category.name);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Focus(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            Map cat = categories[index];

            void navigateToCategory() {
              if (cat['name'] == 'Meal Plans') {
                context.goNamedSafe(AppRoute.mealPlan.name);
              } else if (cat['name'] == 'Catering') {
                context.goNamedSafe(AppRoute.caterings.name);
              } else if (cat['name'] == 'Almuerzos') {
                context.goNamedSafe(
                  AppRoute.details.name,
                  extra: cat,
                );
              } else {
                context.goNamedSafe(AppRoute.details.name, extra: cat);
              }
            }

            return GestureDetector(
              onTap: navigateToCategory,
              child: CategoryItem(cat: cat),
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
}
