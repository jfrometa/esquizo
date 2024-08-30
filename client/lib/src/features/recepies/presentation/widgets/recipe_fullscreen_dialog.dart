import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/domain/recipe_model.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/presentation/widgets/recipe_display_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/recepies_widgets/marketplace_button_widget.dart';

class RecipeDialogScreen extends StatelessWidget {
  const RecipeDialogScreen({
    super.key,
    required this.recipe,
    required this.actions,
    this.subheading,
  });

  final Recipe recipe;
  final List<Widget> actions;
  final Widget? subheading;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: RecipeDisplayWidget(
              recipe: recipe,
              subheading: subheading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: MarketplaceTheme.spacing5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MarketplaceButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  buttonText: 'Close',
                  icon: Symbols.close,
                ),
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
