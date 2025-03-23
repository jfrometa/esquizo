import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_order_details.dart';
 
class CateringDashboardScreen extends ConsumerWidget {
  const CateringDashboardScreen({super.key});


  // Helper method to extract values from the statistics order
  dynamic _getStatValue(CateringOrder stats, String key) {
    // The statistics are stored in the adicionales field as JSON
    try {
      final Map<String, dynamic> statsData = 
          stats.items.isNotEmpty && stats.items.first.adicionales.isNotEmpty
              ? Map<String, dynamic>.from(json.decode(stats.items.first.adicionales))
              : {};
      return statsData[key] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  // Helper method to extract map values from the statistics order
  Map<String, dynamic> _getStatMap(CateringOrder stats, String key) {
    try {
      final Map<String, dynamic> statsData = 
          stats.items.isNotEmpty && stats.items.first.adicionales.isNotEmpty
              ? Map<String, dynamic>.from(json.decode(stats.items.first.adicionales))
              : {};
      return Map<String, dynamic>.from(statsData[key] ?? {});
    } catch (e) {
      return {};
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardSummaryAsync = ref.watch(cateringDashboardSummaryProvider);
    final statisticsAsync = ref.watch(cateringOrderStatisticsProvider);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(cateringDashboardSummaryProvider);
              ref.invalidate(cateringOrderStatisticsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cateringDashboardSummaryProvider);
          ref.invalidate(cateringOrderStatisticsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                _buildDesktopDashboard(context, ref, dashboardSummaryAsync, statisticsAsync, colorScheme)
              else
                _buildMobileDashboard(context, ref, dashboardSummaryAsync, statisticsAsync, colorScheme, isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create new catering order
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
  
    Widget _buildDesktopDashboard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> dashboardSummaryAsync,
    AsyncValue<CateringOrder> statisticsAsync,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats cards row
        SizedBox(
          height: 120,
          child: statisticsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Total Orders',
                    stats.guestCount.toString(),
                    'All Time',
                    Icons.receipt_long,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Upcoming Events',
                    _getStatValue(stats, 'upcomingOrders').toString(),
                    'Scheduled',
                    Icons.event,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Monthly Revenue',
                    '\$${NumberFormat('#,##0.00').format(_getStatValue(stats, 'thisMonthRevenue'))}',
                    'This Month',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Today\'s Events',
                    _getStatValue(stats, 'todayOrders').toString(),
                    'Today',
                    Icons.today,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Main content - split into two columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - 2/3 width
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Events
                  _buildSectionHeader(context, 'Today\'s Events', 'Events scheduled for today'),
                  const SizedBox(height: 8),
                  dashboardSummaryAsync.when(
                    data: (summary) => _buildTodayEventsSection(context, ref, summary, colorScheme),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Upcoming Events
                  _buildSectionHeader(context, 'Upcoming Events', 'Next scheduled events'),
                  const SizedBox(height: 8),
                  dashboardSummaryAsync.when(
                    data: (summary) => _buildUpcomingEventsSection(context, ref, summary, colorScheme),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Right column - 1/3 width
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildSectionHeader(context, 'Quick Actions', 'Common tasks'),
                  const SizedBox(height: 8),
                  _buildQuickActionsSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Order Status Overview
                  _buildSectionHeader(context, 'Order Status Overview', 'Current order distribution'),
                  const SizedBox(height: 8),
                  statisticsAsync.when(
                    data: (stats) => _buildStatusOverviewSection(context, stats, colorScheme),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Orders
                  _buildSectionHeader(context, 'Recent Orders', 'Latest catering orders'),
                  const SizedBox(height: 8),
                  dashboardSummaryAsync.when(
                    data: (summary) => _buildRecentOrdersSection(context, ref, summary, colorScheme),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
    Widget _buildMobileDashboard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> dashboardSummaryAsync,
    AsyncValue<CateringOrder> statisticsAsync,
    ColorScheme colorScheme,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats cards
        statisticsAsync.when(
          data: (stats) => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 2 : 1,
            childAspectRatio: isTablet ? 2.5 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatsCard(
                context,
                'Total Orders',
                stats.guestCount.toString(),
                'All Time',
                Icons.receipt_long,
                colorScheme.primary,
              ),
              _buildStatsCard(
                context,
                'Upcoming Events',
                _getStatValue(stats, 'upcomingOrders').toString(),
                'Scheduled',
                Icons.event,
                colorScheme.secondary,
              ),
              _buildStatsCard(
                context,
                'Monthly Revenue',
                '\$${NumberFormat('#,##0.00').format(_getStatValue(stats, 'thisMonthRevenue'))}',
                'This Month',
                Icons.attach_money,
                Colors.green,
              ),
              _buildStatsCard(
                context,
                'Today\'s Events',
                _getStatValue(stats, 'todayOrders').toString(),
                'Today',
                Icons.today,
                Colors.orange,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),

        const SizedBox(height: 24),
        
        // Quick Actions
        _buildSectionHeader(context, 'Quick Actions', 'Common tasks'),
        const SizedBox(height: 8),
        _buildQuickActionsSection(context),
                  
        const SizedBox(height: 24),
        
        // Today's Events
        _buildSectionHeader(context, 'Today\'s Events', 'Events scheduled for today'),
        const SizedBox(height: 8),
        dashboardSummaryAsync.when(
          data: (summary) => _buildTodayEventsSection(context, ref, summary, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        
        const SizedBox(height: 24),
        
        // Upcoming Events
        _buildSectionHeader(context, 'Upcoming Events', 'Next scheduled events'),
        const SizedBox(height: 8),
        dashboardSummaryAsync.when(
          data: (summary) => _buildUpcomingEventsSection(context, ref, summary, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        
        const SizedBox(height: 24),
        
        // Order Status Overview
        _buildSectionHeader(context, 'Order Status Overview', 'Current order distribution'),
        const SizedBox(height: 8),
        statisticsAsync.when(
          data: (stats) => _buildStatusOverviewSection(context, stats, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        
        const SizedBox(height: 24),
        
        // Recent Orders
        _buildSectionHeader(context, 'Recent Orders', 'Latest catering orders'),
        const SizedBox(height: 8),
        dashboardSummaryAsync.when(
          data: (summary) => _buildRecentOrdersSection(context, ref, summary, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }
  
  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to full section view
              },
              child: const Text('View All'),
            ),
          ],
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTodayEventsSection(
    BuildContext context, 
    WidgetRef ref,
    Map<String, dynamic> summary,
    ColorScheme colorScheme,
  ) {
    final todayEvents = summary['todayEvents'] as int;
    
    if (todayEvents == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'No events scheduled for today',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Get today's orders
    return Consumer(
      builder: (context, ref, child) {
        final ordersAsync = ref.watch(todayCateringOrdersProvider);
        
        return ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No events scheduled for today',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: orders.map((order) => 
                _buildEventCard(context, order, colorScheme),
              ).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
  
  Widget _buildUpcomingEventsSection(
    BuildContext context, 
    WidgetRef ref,
    Map<String, dynamic> summary,
    ColorScheme colorScheme,
  ) {
    final upcomingEvents = summary['upcomingEvents'] as List<CateringOrder>;
    
    if (upcomingEvents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'No upcoming events scheduled',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: upcomingEvents.map((order) => 
        _buildEventCard(context, order, colorScheme),
      ).toList(),
    );
  }
  
  Widget _buildEventCard(
    BuildContext context,
    CateringOrder order,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = order.eventDate.day == now.day && 
                    order.eventDate.month == now.month && 
                    order.eventDate.year == now.year;
    
    // Format event time
    final eventTimeStr = DateFormat('h:mm a').format(order.eventDate);
    
    // Format event date if not today
    final eventDateStr = isToday 
        ? 'Today' 
        : DateFormat('EEE, MMM d').format(order.eventDate);
    
    final countdown = order.eventDate.difference(now);
    final urgencyColor = countdown.inHours < 3 
        ? Colors.red 
        : (countdown.inHours < 24 ? Colors.orange : colorScheme.primary);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CateringOrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date/time column
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isToday ? urgencyColor : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      eventDateStr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventTimeStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: urgencyColor,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatCountdown(countdown),
                      style: TextStyle(
                        fontSize: 12,
                        color: urgencyColor,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.customerName.isNotEmpty 
                                ? order.customerName 
                                : 'Customer #${order.customerId.substring(0, min(6, order.customerId.length))}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: order.status.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: order.status.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.eventType.isNotEmpty 
                          ? order.eventType 
                          : 'Catering Event',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${order.guestCount} Guests',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (order.hasChef) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.restaurant,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chef Service',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (order.eventAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.eventAddress,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Price column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.assignedStaffId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Assigned',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.add_circle_outline,
              label: 'Create New Order',
              color: colorScheme.primary,
              onPressed: () {
                // Navigate to create order screen
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context: context,
              icon: Icons.event,
              label: 'View Today\'s Events',
              color: Colors.orange,
              onPressed: () {
                // Navigate to today's events screen
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context: context,
              icon: Icons.notifications_active,
              label: 'Pending Confirmations',
              color: Colors.amber,
              onPressed: () {
                // Navigate to pending confirmations screen
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context: context,
              icon: Icons.menu_book,
              label: 'Manage Menu Items',
              color: Colors.green,
              onPressed: () {
                // Navigate to menu items screen
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
  
    Widget _buildStatusOverviewSection(
    BuildContext context,
    CateringOrder stats,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final statusCounts = _getStatMap(stats, 'statusCounts');
    final total = stats.guestCount;
    
    // Filter out statuses with zero orders
    final activeStatuses = CateringOrderStatus.values
        .where((status) => (statusCounts[status.name] ?? 0) > 0)
        .toList();
    
    if (activeStatuses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'No order data available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }
  
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: activeStatuses.map((status) {
            final count = statusCounts[status.name] ?? 0;
            final percentage = total > 0 ? (count / total * 100) : 0;
            
            return Column(
              children: [
                Row(
                  children: [
                    Icon(
                      status.icon,
                      size: 16,
                      color: status.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.displayName,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(status.color),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildRecentOrdersSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> summary,
    ColorScheme colorScheme,
  ) {
    final recentOrders = summary['recentOrders'] as List<CateringOrder>;
    final theme = Theme.of(context);
    
    if (recentOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'No orders available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentOrders.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final order = recentOrders[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: order.status.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                order.status.icon,
                color: order.status.color,
                size: 20,
              ),
            ),
            title: Text(
              order.customerName.isNotEmpty
                  ? order.customerName
                  : 'Order #${order.id.substring(0, min(6, order.id.length))}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${DateFormat('MMM d, h:mm a').format(order.orderDate)} • ${order.eventType.isNotEmpty ? order.eventType : 'Catering'}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: order.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CateringOrderDetailsScreen(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  String _formatCountdown(Duration duration) {
    if (duration.isNegative) {
      // Already past the event time
      return 'Happening now';
    }
    
    if (duration.inDays > 0) {
      return 'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours} hr${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return 'in ${duration.inMinutes} min';
    } else {
      return 'Starting now';
    }
  }
}