import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_items_screen.dart';
 

// This class is used to integrate meal plan functionality with your existing admin panel
class MealPlanAdminSection extends ConsumerStatefulWidget {
  const MealPlanAdminSection({super.key});

  @override
  ConsumerState<MealPlanAdminSection> createState() => _MealPlanAdminSectionState();
}

class _MealPlanAdminSectionState extends ConsumerState<MealPlanAdminSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Meal Plans'),
            Tab(text: 'Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MealPlanManagementScreen(),
          MealPlanItemsScreen(),
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
      color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
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
      onTap: () => onItemSelected(index),
      selected: isSelected,
    ),
  );
}

// Modify your admin_panel_screen.dart to add Meal Plans
// Add to your _screens list:
// const MealPlanAdminSection(),

// Add to your _screenTitles list:
// 'Meal Plans', 

// Update your SidebarMenu widgets to include:
/*
_buildMenuItem(
  context,
  index: 7, // Use the correct index
  icon: Icons.restaurant_menu,
  title: 'Meal Plans',
),
*/