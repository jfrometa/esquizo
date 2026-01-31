import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_items_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_analytics_screen.dart';

// This class is used to integrate meal plan functionality with your existing admin panel
class MealPlanAdminSection extends ConsumerStatefulWidget {
  const MealPlanAdminSection({super.key});

  @override
  ConsumerState<MealPlanAdminSection> createState() =>
      _MealPlanAdminSectionState();
}

class _MealPlanAdminSectionState extends ConsumerState<MealPlanAdminSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Meal Plans'),
            Tab(text: 'Items'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => context.go('/admin/meal-plans/export'),
            tooltip: 'Export Reports',
          ),
          // QR Scanner button
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.go('/admin/meal-plans/scanner'),
            tooltip: 'QR Scanner',
          ),
          // POS interface button
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            onPressed: () => context.go('/admin/meal-plans/pos'),
            tooltip: 'POS Interface',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MealPlanManagementScreen(),
          MealPlanItemsScreen(),
          MealPlanAnalyticsScreen(),
        ],
      ),
    );
  }
}

// This method adds meal plan section to the admin panel navigation
// It should be called in your AdminPanelScreen to add meal plans to the sidebar menu
void addMealPlanToAdminPanel(List<Widget> screens, List<String> screenTitles) {
  // Add the meal plan section to the admin panel screens
  screens.add(const MealPlanAdminSection());

  // Add the title to the screen titles list
  screenTitles.add('Meal Plans');
}

// Add this widget to your SidebarMenu's _buildMenuItem method calls
Widget buildMealPlanMenuItem({
  required BuildContext context,
  required int index,
  required int selectedIndex,
  required Function(int) onItemSelected,
  bool isExpanded = true,
}) {
  final theme = Theme.of(context);
  final isSelected = index == selectedIndex;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color:
          isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: Icon(
        Icons.restaurant_menu,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      title: isExpanded
          ? Text(
              'Meal Plans',
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      minLeadingWidth: 20,
      contentPadding: isExpanded
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      dense: !isExpanded,
      horizontalTitleGap: 8,
      onTap: () {
        onItemSelected(index);
        context.go('/admin/meal-plans');
      },
      selected: isSelected,
    ),
  );
}

// Navigation helper methods
void navigateToMealPlanManagement(BuildContext context) {
  context.go('/admin/meal-plans/management');
}

void navigateToMealPlanItems(BuildContext context) {
  context.go('/admin/meal-plans/items');
}

void navigateToMealPlanAnalytics(BuildContext context) {
  context.go('/admin/meal-plans/analytics');
}

void navigateToMealPlanQRCode(BuildContext context, String planId) {
  context.go('/admin/meal-plans/qr/$planId');
}

void navigateToMealPlanScanner(BuildContext context) {
  context.go('/admin/meal-plans/scanner');
}

void navigateToMealPlanPOS(BuildContext context) {
  context.go('/admin/meal-plans/pos');
}

void navigateToMealPlanExport(BuildContext context) {
  context.go('/admin/meal-plans/export');
}
