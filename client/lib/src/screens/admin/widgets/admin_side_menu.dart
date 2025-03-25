import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_admin_section.dart';

class SidebarMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<String> screenTitles;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.screenTitles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authRepositoryProvider).currentUser;

    // Check if sidebar is expanded (desktop mode) or collapsed (mobile drawer)
    final isExpanded = MediaQuery.sizeOf(context).width >= 1100;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // App title and user info
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpanded) ...[
                  Text(
                    'Admin Panel',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            user.displayName?.isNotEmpty == true
                                ? user.displayName![0]
                                : 'A',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'Admin User',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.email ?? '',
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  // Collapsed header for mobile drawer
                  Center(
                    child: Text(
                      'Admin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Dashboard item (always first)
                _buildMenuItem(
                  context: context,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isExpanded: isExpanded,
                ),

                const Divider(),

                // Build menu items for the rest of the screens
                for (int i = 1; i < screenTitles.length; i++)
                  _buildScreenMenuItem(context, i, screenTitles[i], isExpanded),

                const Divider(),

                // Settings item
                _buildMenuItem(
                  context: context,
                  index: -1, // Special index for settings
                  icon: Icons.settings,
                  title: 'Settings',
                  isExpanded: isExpanded,
                  onTap: () {
                    // Navigate to settings
                    context.go('/admin/settings');
                  },
                ),
              ],
            ),
          ),

          // Logout button at the bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(isExpanded ? 'Logout' : ''),
                onPressed: () {
                  // Sign out and navigate to sign in
                  ref.read(authServiceProvider).signOut();
                  context.go('/signIn');
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: isExpanded ? 16 : 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenMenuItem(
      BuildContext context, int index, String title, bool isExpanded) {
    // Check the title to use the appropriate icon and builder
    if (title == 'Meal Plans') {
      return buildMealPlanMenuItem(
        context: context,
        index: index,
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
        isExpanded: isExpanded,
      );
    } else if (title == 'Catering') {
      return _buildMenuItem(
        context: context,
        index: index,
        icon: Icons.restaurant,
        title: title,
        isExpanded: isExpanded,
      );
    } else {
      // Default menu item
      return _buildMenuItem(
        context: context,
        index: index,
        icon: Icons.business,
        title: title,
        isExpanded: isExpanded,
      );
    }
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    bool isExpanded = true,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == selectedIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        title: isExpanded
            ? Text(
                title,
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
        onTap: onTap ?? () => onItemSelected(index),
        selected: isSelected,
      ),
    );
  }
}
