import 'package:starter_architecture_flutter_firebase/src/features/prompt/application/prompt_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/presentation/widgets/recipe_fullscreen_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/recepies_widgets/filter_chip_selection_input.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/recepies_widgets/highlight_border_on_hover_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/recepies_widgets/marketplace_button_widget.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../util/filter_chip_enums.dart';

import 'widgets/full_prompt_dialog_widget.dart';
import 'widgets/image_input_widget.dart';

const double kAvatarSize = 50;
const double collapsedHeight = 100;
const double expandedHeight = 300;
const double elementPadding = MarketplaceTheme.spacing7;

class PromptScreen extends ConsumerStatefulWidget {
  const PromptScreen({super.key, required this.canScroll});

  final bool canScroll;

  @override
  ConsumerState<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends ConsumerState<PromptScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(promptNotifierProvider.notifier);
    final state = ref.watch(promptNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: widget.canScroll
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Container(
            padding: constraints.isMobile
                ? const EdgeInsets.only(
                    left: MarketplaceTheme.spacing7,
                    right: MarketplaceTheme.spacing7,
                    bottom: MarketplaceTheme.spacing7,
                    top: MarketplaceTheme.spacing7,
                  )
                : const EdgeInsets.only(
                    left: MarketplaceTheme.spacing7,
                    right: MarketplaceTheme.spacing7,
                    bottom: MarketplaceTheme.spacing1,
                    top: MarketplaceTheme.spacing7,
                  ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MarketplaceTheme.borderColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(50),
                  bottomRight:
                      Radius.circular(MarketplaceTheme.defaultBorderRadius),
                  bottomLeft:
                      Radius.circular(MarketplaceTheme.defaultBorderRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(elementPadding + 10),
                    child: Text(
                      'Create a recipe:',
                      style: MarketplaceTheme.dossierParagraph.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      elementPadding,
                    ),
                    child: SizedBox(
                      height: constraints.isMobile ? 140 : 250,
                      child: AddImageToPromptWidget(
                        height: constraints.isMobile ? 100 : 200,
                        width: constraints.isMobile ? 100 : 200,
                      ),
                    ),
                  ),
                  if (constraints.isMobile)
                    Padding(
                      padding: const EdgeInsets.all(elementPadding),
                      child: _FilterChipSection(
                        label: "I also have these staple ingredients: ",
                        child: FilterChipSelectionInput<BasicIngredientsFilter>(
                          onChipSelected: (selected) {
                            viewModel.addBasicIngredients(
                                selected as Set<BasicIngredientsFilter>);
                          },
                          allValues: BasicIngredientsFilter.values,
                          selectedValues:
                              state.userPrompt.selectedBasicIngredients,
                        ),
                      ),
                    ),
                  if (constraints.isMobile)
                    Padding(
                      padding: const EdgeInsets.all(elementPadding),
                      child: _FilterChipSection(
                        label: "I'm in the mood for: ",
                        child: FilterChipSelectionInput<CuisineFilter>(
                          onChipSelected: (selected) {
                            viewModel.addCategoryFilters(
                                selected as Set<CuisineFilter>);
                          },
                          allValues: CuisineFilter.values,
                          selectedValues: state.userPrompt.selectedCuisines,
                        ),
                      ),
                    ),
                  if (constraints.isMobile)
                    Padding(
                      padding: const EdgeInsets.all(elementPadding),
                      child: _FilterChipSection(
                        label: "I have the following dietary restrictions:",
                        child:
                            FilterChipSelectionInput<DietaryRestrictionsFilter>(
                          onChipSelected: (selected) {
                            viewModel.addDietaryRestrictionFilter(
                                selected as Set<DietaryRestrictionsFilter>);
                          },
                          allValues: DietaryRestrictionsFilter.values,
                          selectedValues:
                              state.userPrompt.selectedDietaryRestrictions,
                        ),
                      ),
                    ),
                  if (!constraints.isMobile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(elementPadding),
                            child: _FilterChipSection(
                              label: "I'm in the mood for: ",
                              child: FilterChipSelectionInput<CuisineFilter>(
                                onChipSelected: (selected) {
                                  viewModel.addCategoryFilters(
                                      selected as Set<CuisineFilter>);
                                },
                                allValues: CuisineFilter.values,
                                selectedValues:
                                    state.userPrompt.selectedCuisines,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(elementPadding),
                            child: _FilterChipSection(
                              label: "I also have these staple ingredients: ",
                              child: FilterChipSelectionInput<
                                  BasicIngredientsFilter>(
                                onChipSelected: (selected) {
                                  viewModel.addBasicIngredients(
                                      selected as Set<BasicIngredientsFilter>);
                                },
                                allValues: BasicIngredientsFilter.values,
                                selectedValues:
                                    state.userPrompt.selectedBasicIngredients,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(elementPadding),
                            child: _FilterChipSection(
                              label:
                                  "I have the following dietary restrictions:",
                              child: FilterChipSelectionInput<
                                  DietaryRestrictionsFilter>(
                                onChipSelected: (selected) {
                                  viewModel.addDietaryRestrictionFilter(selected
                                      as Set<DietaryRestrictionsFilter>);
                                },
                                allValues: DietaryRestrictionsFilter.values,
                                selectedValues: state
                                    .userPrompt.selectedDietaryRestrictions,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(elementPadding),
                    child: _TextField(
                      controller: viewModel.promptTextController,
                      onChanged: (value) {
                        state.userPrompt.textInput = (value);
                        // viewModel..notify();
                        // setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: MarketplaceTheme.spacing4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!constraints.isMobile) const Spacer(flex: 1),
                        if (!constraints.isMobile)
                          Expanded(
                            flex: 3,
                            child: MarketplaceButton(
                              onPressed: viewModel.resetPrompt,
                              buttonText: 'Reset prompt',
                              icon: Symbols.restart_alt,
                              iconColor: Colors.black45,
                              buttonBackgroundColor: Colors.transparent,
                              hoverColor:
                                  MarketplaceTheme.secondary.withOpacity(.1),
                            ),
                          ),
                        const Spacer(flex: 1),
                        Expanded(
                          flex: constraints.isMobile ? 10 : 3,
                          child: MarketplaceButton(
                            onPressed: () {
                              final promptData = viewModel.buildPrompt();
                              showDialog<Null>(
                                context: context,
                                builder: (context) {
                                  return FullPromptDialog(
                                    promptData: promptData,
                                  );
                                },
                              );
                            },
                            buttonText: 'Full prompt',
                            icon: Symbols.info_rounded,
                          ),
                        ),
                        const Spacer(flex: 1),
                        Expanded(
                          flex: constraints.isMobile ? 10 : 3,
                          child: MarketplaceButton(
                            onPressed: () async {
                              await viewModel.submitPrompt().then((_) async {
                                if (!context.mounted) return;

                                if (ref.watch(promptNotifierProvider).recipe !=
                                    null) {
                                  bool? shouldSave = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => RecipeDialogScreen(
                                      recipe: ref
                                          .watch(promptNotifierProvider)
                                          .recipe!,
                                      actions: [
                                        MarketplaceButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                            // context.pop(true);
                                          },
                                          buttonText: "Save Recipe",
                                          icon: Symbols.save,
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldSave != null && shouldSave) {
                                    viewModel.saveRecipe();
                                  }
                                } else {
                                  final snackBar = SnackBar(
                                    /// need to set following properties for best effect of awesome_snackbar_content
                                    elevation: 0,
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    content: AwesomeSnackbarContent(
                                      title: 'On Snap!',
                                      message: state.geminiFailureResponse ??
                                          'Error message',
                                      contentType: ContentType.failure,
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(snackBar);
                                }
                              });
                            },
                            buttonText: 'Submit prompt',
                            icon: Symbols.send,
                          ),
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                  if (constraints.isMobile)
                    Align(
                      alignment: Alignment.center,
                      child: MarketplaceButton(
                        onPressed: viewModel.resetPrompt,
                        buttonText: 'Reset prompt',
                        icon: Symbols.restart_alt,
                        iconColor: Colors.black45,
                        buttonBackgroundColor: Colors.transparent,
                        hoverColor: MarketplaceTheme.secondary.withOpacity(.1),
                      ),
                    ),
                  const SizedBox(height: 200.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChipSection extends StatelessWidget {
  const _FilterChipSection({
    required this.child,
    required this.label,
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return HighlightBorderOnHoverWidget(
      borderRadius: BorderRadius.zero,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).splashColor.withOpacity(.1),
          border: Border.all(
            color: MarketplaceTheme.borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(MarketplaceTheme.spacing7),
              child: Text(
                label,
                style: MarketplaceTheme.dossierParagraph,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final Null Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      scrollPadding: const EdgeInsets.only(bottom: 150),
      maxLines: null,
      onChanged: onChanged,
      minLines: 3,
      controller: controller,
      style: WidgetStateTextStyle.resolveWith(
          (states) => MarketplaceTheme.dossierParagraph),
      decoration: InputDecoration(
        fillColor: Theme.of(context).splashColor,
        hintText: "Add additional context...",
        hintStyle: WidgetStateTextStyle.resolveWith(
          (states) => MarketplaceTheme.dossierParagraph,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.black45),
        ),
        filled: true,
      ),
    );
  }
}
