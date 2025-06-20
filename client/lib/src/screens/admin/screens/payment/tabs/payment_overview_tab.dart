import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';

class PaymentOverviewTab extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String searchQuery;

  const PaymentOverviewTab({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    final statsAsync = ref.watch(paymentStatisticsProvider((
      startDate: startDate,
      endDate: endDate,
    )));
    
    final serviceStatsAsync = ref.watch(serviceStatisticsProvider((
      startDate: startDate,
      endDate: endDate,
    )));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(paymentStatisticsProvider);
        ref.invalidate(serviceStatisticsProvider);
      },
      child: statsAsync.when(
        data: (stats) => serviceStatsAsync.when(
          data: (serviceStats) => _buildOverview(
            context, 
            stats, 
            serviceStats, 
            currencyFormatter, 
            colorScheme, 
            isDesktop,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    Map<String, dynamic> stats,
    Map<String, dynamic> serviceStats,
    NumberFormat formatter,
    ColorScheme colorScheme,
    bool isDesktop,
  ) {
    final cards = [
      _buildStatCard(
        'Total Revenue',
        formatter.format(stats['totalRevenue'] ?? 0),
        Icons.attach_money,
        Colors.green,
        subtitle: '${stats['totalTransactions'] ?? 0} transactions',
      ),
      _buildStatCard(
        'Average Order',
        formatter.format(stats['averageTransactionValue'] ?? 0),
        Icons.receipt,
        Colors.blue,
        subtitle: 'Per transaction',
      ),
      _buildStatCard(
        'Total Tips',
        formatter.format(serviceStats['totalTips'] ?? 0),
        Icons.volunteer_activism,
        Colors.orange,
        subtitle: 'Distributed to staff',
      ),
      _buildStatCard(
        'Service Charges',
        formatter.format(serviceStats['totalServiceCharges'] ?? 0),
        Icons.room_service,
        Colors.purple,
        subtitle: 'From dine-in orders',
      ),
      _buildStatCard(
        'Discounts Given',
        formatter.format(stats['totalDiscounts'] ?? 0),
        Icons.discount,
        Colors.red,
        subtitle: 'Total discount amount',
      ),
      _buildStatCard(
        'Reimbursements',
        formatter.format(stats['totalReimbursements'] ?? 0),
        Icons.money_off,
        Colors.amber,
        subtitle: 'Processed refunds',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              childAspectRatio: isDesktop ? 2.5 : 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          ),
          
          const SizedBox(height: 32),
          
          // Revenue by Service Type
          Text('Revenue by Service Type', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildServiceTypeRevenue(serviceStats, formatter, colorScheme),
          
          const SizedBox(height: 32),
          
          // Payment Methods Chart
          Text('Payment Methods', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildPaymentMethodsChart(stats, formatter, colorScheme),
          
          const SizedBox(height: 32),
          
          // Staff Performance
          Text('Top Performing Servers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildTopServersTable(serviceStats, formatter, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeRevenue(
    Map<String, dynamic> serviceStats,
    NumberFormat formatter,
    ColorScheme colorScheme,
  ) {
    final revenue = serviceStats['serviceTypeRevenue'] as Map<String, dynamic>? ?? {};
    final counts = serviceStats['serviceTypeCounts'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: ServiceType.values.map((type) {
            final typeRevenue = revenue[type.name] ?? 0.0;
            final typeCount = counts[type.name] ?? 0;
            final percentage = revenue.isNotEmpty 
                ? (typeRevenue / revenue.values.fold(0.0, (a, b) => a + b) * 100)
                : 0.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(_getServiceTypeIcon(type), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getServiceTypeName(type)),
                        Text(
                          '$typeCount orders',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.format(typeRevenue),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart(
    Map<String, dynamic> stats,
    NumberFormat formatter,
    ColorScheme colorScheme,
  ) {
    final revenueByMethod = stats['revenueByMethod'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: revenueByMethod.entries.map((entry) {
            final method = entry.key;
            final revenue = entry.value as double;
            final percentage = revenueByMethod.isNotEmpty
                ? (revenue / revenueByMethod.values.fold(0.0, (a, b) => a + b) * 100)
                : 0.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatPaymentMethod(method)),
                      Text(formatter.format(revenue)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    color: _getPaymentMethodColor(method),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopServersTable(
    Map<String, dynamic> serviceStats,
    NumberFormat formatter,
    ColorScheme colorScheme,
  ) {
    final serverStats = serviceStats['serverStatistics'] as Map<String, dynamic>? ?? {};
    final revenue = serverStats['revenue'] as Map<String, dynamic>? ?? {};
    final orderCount = serverStats['orderCount'] as Map<String, dynamic>? ?? {};
    
    final sortedServers = revenue.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: Text('Server', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Avg Order', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            ...sortedServers.take(10).map((entry) {
              final serverId = entry.key;
              final serverRevenue = entry.value as double;
              final serverOrders = orderCount[serverId] ?? 0;
              final avgOrder = serverOrders > 0 ? serverRevenue / serverOrders : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(serverId)), // Should be server name
                    Expanded(child: Text(serverOrders.toString())),
                    Expanded(child: Text(formatter.format(serverRevenue))),
                    Expanded(child: Text(formatter.format(avgOrder))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getServiceTypeIcon(ServiceType type) {
    switch (type) {
      case ServiceType.dineIn:
        return Icons.restaurant;
      case ServiceType.takeout:
        return Icons.takeout_dining;
      case ServiceType.delivery:
        return Icons.delivery_dining;
      case ServiceType.pickup:
        return Icons.shopping_bag;
    }
  }

  String _getServiceTypeName(ServiceType type) {
    switch (type) {
      case ServiceType.dineIn:
        return 'Dine In';
      case ServiceType.takeout:
        return 'Takeout';
      case ServiceType.delivery:
        return 'Delivery';
      case ServiceType.pickup:
        return 'Pickup';
    }
  }

  String _formatPaymentMethod(String method) {
    return method.replaceAll('_', ' ').split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'credit_card':
      case 'creditcard':
        return Colors.blue;
      case 'debit_card':
      case 'debitcard':
        return Colors.orange;
      case 'digital_wallet':
      case 'digitalwallet':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
