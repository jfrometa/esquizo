import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/screens/guided_tour/guided_tour_step_four_widget.dart';
import 'package:starter_architecture_flutter_firebase/screens/guided_tour/guided_tour_step_one_widget.dart';
import 'package:starter_architecture_flutter_firebase/screens/guided_tour/guided_tour_step_three_widget.dart';
import 'package:starter_architecture_flutter_firebase/screens/guided_tour/guided_tour_step_two_widget.dart';
import 'package:starter_architecture_flutter_firebase/screens/guided_tour/guided_tour_tab_page_selector.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class GuidedTourWizardScreen extends ConsumerStatefulWidget {
  const GuidedTourWizardScreen({
    super.key,
  });

  @override
  ConsumerState<GuidedTourWizardScreen> createState() =>
      _GuidedTourWizardScreenState();
}

class _GuidedTourWizardScreenState extends ConsumerState<GuidedTourWizardScreen>
    with SingleTickerProviderStateMixin {
  late TabController guidedTourTabController;

  @override
  void initState() {
    super.initState();
    guidedTourTabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        title: 'guide_tour.header.title'.t(),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: guidedTourTabController,
              children: const [
                ResponsiveWidget(
                  mobileScreen: GuidedTourStepOneWidget(),
                  desktopScreen:
                      GuidedTourStepOneWidget(), //TODO: build desktop screen
                ),
                ResponsiveWidget(
                  mobileScreen: GuidedTourStepTwoWidget(),
                  desktopScreen:
                      GuidedTourStepTwoWidget(), //TODO: build desktop screen
                ),
                ResponsiveWidget(
                  mobileScreen: GuidedTourStepThreeWidget(),
                  desktopScreen:
                      GuidedTourStepThreeWidget(), //TODO: build desktop screen
                ),
                ResponsiveWidget(
                  mobileScreen: GuidedTourStepFourWidget(),
                  desktopScreen:
                      GuidedTourStepFourWidget(), //TODO: build desktop screen
                ),
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            color: customAppTheme.colorsPalette.white,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: GuidedTourTabPageSelector(
                controller: guidedTourTabController,
                color: customAppTheme.colorsPalette.primary7,
                indicatorSize: 8,
                selectedColor: customAppTheme.colorsPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
