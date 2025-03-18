import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';

class SidebarMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isExpanded;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessConfig = ref.watch(businessConfigProvider).value;
    final isAdmin = ref.watch(hasRoleProvider('admin'));
    final theme = Theme.of(context);
    
    return Container(
      width: isExpanded ? 240 : 80,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context, businessConfig),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                ),
                _buildMenuItem(
                  context,
                  index: 1,
                  icon: Icons.restaurant_menu,
                  title: 'Products & Menu',
                ),
                _buildMenuItem(
                  context,
                  index: 2,
                  icon: Icons.receipt_long,
                  title: 'Orders',
                ),
                _buildMenuItem(
                  context,
                  index: 3,
                  icon: Icons.table_chart,
                  title: 'Tables',
                ),
                if (isAdmin) ...[
                  _buildMenuItem(
                    context,
                    index: 4,
                    icon: Icons.people,
                    title: 'Users & Staff',
                  ),
                  _buildMenuItem(
                    context,
                    index: 5,
                    icon: Icons.settings,
                    title: 'Business Settings',
                  ),
                ],
                _buildMenuItem(
                  context,
                  index: 6,
                  icon: Icons.bar_chart,
                  title: 'Analytics',
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  index: -1, // Special index for profile
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () => Navigator.pushNamed(context, '/admin/profile'),
                ),
                _buildMenuItem(
                  context,
                  index: -2, // Special index for help
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.pushNamed(context, '/admin/help'),
                ),
              ],
            ),
          ),
          _buildFooter(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BusinessConfig? config) {
    if (!isExpanded) {
      return Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: config?.logoUrl != null && config!.logoUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  config.logoUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business),
                ),
              )
            : const Icon(Icons.business),
      );
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (config?.logoUrl != null && config!.logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                config.logoUrl,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.business),
              ),
            )
          else
            const Icon(Icons.business),
          if (isExpanded) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config?.name ?? 'Business',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    config?.type ?? 'Admin Panel',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isSelected = index == selectedIndex;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
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

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: isExpanded
          ? ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              dense: true,
              minLeadingWidth: 20,
              onTap: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            )
          : IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              tooltip: 'Logout',
            ),
    );
  }
}