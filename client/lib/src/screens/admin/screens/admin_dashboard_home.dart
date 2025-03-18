import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/admin_panel/admin_stats_provider.dart';

import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
 import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
 import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/dashboard_status_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

// Home screen of the admin dashboard

// Home screen of the admin dashboard
class AdminDashboardHome extends ConsumerStatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  ConsumerState<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends ConsumerState<AdminDashboardHome> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1200;
    final isTablet = width > 600 && width <= 1200;
    
    // Watch necessary providers
    final businessConfig = ref.watch(businessConfigProvider);
    final orderStats = ref.watch(orderStatsProvider);
    final salesStats = ref.watch(salesStatsProvider);
    final tableStats = ref.watch(tableStatsProvider);
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Overview Card
            businessConfig.when(
              data: (config) => _buildBusinessOverview(config),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Error loading business information'),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            Text(
              'Business Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              childAspectRatio: isDesktop ? 1.5 : 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Orders Stats
                orderStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Orders',
                    primaryStat: '${data.totalOrders}',
                    secondaryStat: '${data.pendingOrders} pending',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    onTap: () => _navigateToSection(context, 2), // Orders screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Orders',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Orders',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                
                // Sales Stats
                salesStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Sales',
                    primaryStat: '\$${data.totalSales.toStringAsFixed(2)}',
                    secondaryStat: 'Today: \$${data.todaySales.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () => {

                      _navigateToSection(context, 6)
                      }, // Analytics screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Sales',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Sales',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                
                // Tables Stats
                tableStats.when(
                  data: (data) => DashboardStatsCard(
                    title: 'Tables',
                    primaryStat: '${data.occupiedTables}/${data.totalTables}',
                    secondaryStat: '${data.occupiedTables} tables occupied',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                    onTap: () => _navigateToSection(context, 3), // Tables screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Tables',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Tables',
                    icon: Icons.table_chart,
                    color: Colors.orange,
                  ),
                ),
                
                // Products Stats
                ref.watch(productStatsProvider).when(
                  data: (data) => DashboardStatsCard(
                    title: 'Products',
                    primaryStat: '${data.totalProducts}',
                    secondaryStat: '${data.categories} categories',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                    onTap: () => _navigateToSection(context, 1), // Products screen
                  ),
                  loading: () => const DashboardStatsCard.loading(
                    title: 'Products',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                  ),
                  error: (_, __) => const DashboardStatsCard.error(
                    title: 'Products',
                    icon: Icons.restaurant_menu,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View All'),
                  onPressed: () => _navigateToSection(context, 2), // Orders screen
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recent Orders List
            ref.watch(recentOrdersProvider).when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No recent orders'),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: orders.map((order) => _buildOrderCard(context, order)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Error loading recent orders'),
                ),
              ),
            ),
            
            if (isDesktop) ...[
              const SizedBox(height: 24),
              
              // Analytics Preview Section
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildAnalyticsPreview(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildQuickActions(context),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 24),
              
              _buildAnalyticsPreview(context),
              
              const SizedBox(height: 24),
              
              _buildQuickActions(context),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessOverview(BusinessConfig? config) {
    if (config == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (config.logoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  config.logoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.business,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    config.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (config.features.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: config.features.map((feature) => Chip(
                        label: Text(feature),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                      )).toList(),
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () => _navigateToSection(context, 5), // Business Settings
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getOrderStatusColor(order.status.name).withOpacity(0.2),
          child: Icon(
            Icons.receipt,
            color: _getOrderStatusColor(order.status.name),
          ),
        ),
        title: Row(
          children: [
            Text('Order #${order.id.substring(0, 6)}'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getOrderStatusText(order.status.name),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getOrderStatusColor(order.status.name),
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${order.items.length} items • Table ${order.resourceId} • \$${order.totalAmount.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => _navigateToOrderDetails(context, order.id),
        ),
        onTap: () => _navigateToOrderDetails(context, order.id),
      ),
    );
  }
  
  Widget _buildAnalyticsPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => _navigateToSection(context, 6), // Analytics
                  child: const Text('View Full Analytics'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Sales Graph Preview'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Create New Order',
              onPressed: () => _navigateToSection(context, 2), // Orders
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.add_business,
              label: 'Add Product to Menu',
              onPressed: () => _navigateToSection(context, 1), // Products
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.person_add_alt,
              label: 'Add New User',
              onPressed: () => _navigateToSection(context, 4), // Users
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.print,
              label: 'Print Reports',
              onPressed: () => _navigateToSection(context, 6), // Analytics
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Refresh providers that need real-time updates
      ref.invalidate(businessConfigProvider);
      ref.invalidate(orderStatsProvider);
      ref.invalidate(salesStatsProvider);
      ref.invalidate(tableStatsProvider);
      ref.invalidate(recentOrdersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _navigateToSection(BuildContext context, int index) {
    final parentState = context.findAncestorStateOfType<AdminPanelScreenState>();
    if (parentState != null) {
      parentState.setState(() {
        parentState.selectedIndex = index;
      });
    }
  }
  
  void _navigateToOrderDetails(BuildContext context, String orderId) {
    context.push('/admin/orders/$orderId');
  }
  
  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}