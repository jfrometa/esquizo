import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/analytics/analytics_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/charts/active_hours_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/charts/category_breakdown_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/charts/stats_summary_chart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/sales_chart.dart';
 


class AnalyticsDashboard extends ConsumerStatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  ConsumerState<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends ConsumerState<AnalyticsDashboard> {
  // Date range for analytics
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    // Analytics data based on the selected date range
    final analyticsData = ref.watch(analyticsDataProvider(
      AnalyticsDateRange(
        startDate: _startDate,
        endDate: _endDate,
      ),
    ));

    return Scaffold(
      body: analyticsData.when(
        data: (data) => _buildDashboard(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDashboard(AnalyticsData data) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date range selector
          _buildHeader(),
          const SizedBox(height: 24),

          // Stats summary cards
          isDesktop
              ? _buildStatsCardsDesktop(data)
              : _buildStatsCardsMobile(data),
          const SizedBox(height: 24),

          // Sales chart
          Text(
            'Sales Trend',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SalesChart(
              salesData: data.salesByDate,
              dateFormat: _getDateFormat(),
            ),
          ),
          const SizedBox(height: 24),

          // Category breakdown and active hours
          if (isDesktop) ...[
            // For desktop, show category and hours side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCategoryBreakdown(data),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActiveHours(data),
                ),
              ],
            ),
          ] else ...[
            // For mobile/tablet, stack them vertically
            _buildCategoryBreakdown(data),
            const SizedBox(height: 24),
            _buildActiveHours(data),
          ],
          const SizedBox(height: 24),

          // Additional visualizations
          Text(
            'Additional Insights',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          isDesktop || isTablet
              ? _buildInsightsGridView(data)
              : _buildInsightsListView(data),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Date range selector
                _buildDateRangeSelector(),

                // Period selector
                _buildPeriodSelector(),

                // Export button
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Report'),
                  onPressed: () {
                    _exportReport();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final dateFormat = DateFormat.yMMMd();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Date Range:'),
        const SizedBox(width: 8),
        TextButton.icon(
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
          ),
          onPressed: () {
            _selectDateRange(context);
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: 'week',
          label: Text('Week'),
        ),
        ButtonSegment<String>(
          value: 'month',
          label: Text('Month'),
        ),
        ButtonSegment<String>(
          value: 'quarter',
          label: Text('Quarter'),
        ),
        ButtonSegment<String>(
          value: 'year',
          label: Text('Year'),
        ),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _selectedPeriod = selection.first;
          _updateDateRange();
        });
      },
    );
  }

  Widget _buildStatsCardsDesktop(AnalyticsData data) {
    return SizedBox(
      height: 120, // Set a fixed height for the row
      child: Row(
        children: [
          Expanded(
            child: StatsSummaryCard(
              title: 'Total Sales',
              value: '\$${data.totalSales.toStringAsFixed(2)}',
              icon: Icons.monetization_on,
              color: Colors.green,
              trend: data.salesTrend,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsSummaryCard(
              title: 'Orders',
              value: '${data.totalOrders}',
              icon: Icons.receipt_long,
              color: Colors.blue,
              trend: data.ordersTrend,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsSummaryCard(
              title: 'Avg. Order Value',
              value: '\$${data.avgOrderValue.toStringAsFixed(2)}',
              icon: Icons.shopping_cart,
              color: Colors.purple,
              trend: data.avgOrderTrend,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsSummaryCard(
              title: 'Customers',
              value: '${data.uniqueCustomers}',
              icon: Icons.people,
              color: Colors.orange,
              trend: data.customersTrend,
            ),
          ),
        ],
      ),);
  }

  Widget _buildStatsCardsMobile(AnalyticsData data) {
    return SizedBox(
      height: 240, // Set a fixed height for the column (double the desktop height)
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Total Sales',
                    value: '\$${data.totalSales.toStringAsFixed(2)}',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                    trend: data.salesTrend,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Orders',
                    value: '${data.totalOrders}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    trend: data.ordersTrend,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Avg. Order Value',
                    value: '\$${data.avgOrderValue.toStringAsFixed(2)}',
                    icon: Icons.shopping_cart,
                    color: Colors.purple,
                    trend: data.avgOrderTrend,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatsSummaryCard(
                    title: 'Customers',
                    value: '${data.uniqueCustomers}',
                    icon: Icons.people,
                    color: Colors.orange,
                    trend: data.customersTrend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(AnalyticsData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: CategoryBreakdownChart(
                categoryData: data.salesByCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveHours(AnalyticsData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders by Hour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ActiveHoursChart(
                hourlyData: data.ordersByHour,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsGridView(AnalyticsData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveLayout.isDesktop(context) ? 3 : 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildInsightCard(
          title: 'Most Popular Item',
          value: data.topSellingItem?.name ?? 'N/A',
          subtitle: data.topSellingItem != null
              ? '${data.topSellingItem!.quantity} sold'
              : '',
          icon: Icons.star,
          color: Colors.amber,
        ),
        _buildInsightCard(
          title: 'Busiest Day',
          value: data.busiestDay.isNotEmpty
              ? data.busiestDay
              : 'N/A',
          subtitle: data.busiestDayOrders > 0
              ? '${data.busiestDayOrders} orders'
              : '',
          icon: Icons.calendar_today,
          color: Colors.cyan,
        ),
        _buildInsightCard(
          title: 'Order Completion Rate',
          value: '${(data.orderCompletionRate * 100).toStringAsFixed(1)}%',
          subtitle: '${data.completedOrders} of ${data.totalOrders} orders',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildInsightCard(
          title: 'Avg. Preparation Time',
          value: '${data.avgPrepTime.toStringAsFixed(1)} min',
          subtitle: 'From order to ready',
          icon: Icons.timer,
          color: Colors.orange,
        ),
        _buildInsightCard(
          title: 'Customer Retention',
          value: '${(data.returnCustomerRate * 100).toStringAsFixed(1)}%',
          subtitle: '${data.returningCustomers} returning customers',
          icon: Icons.repeat,
          color: Colors.purple,
        ),
        _buildInsightCard(
          title: 'Avg. Table Turnover',
          value: '${data.avgTableTurnover.toStringAsFixed(1)}x',
          subtitle: 'Per day',
          icon: Icons.table_chart,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildInsightsListView(AnalyticsData data) {
    final insights = [
      {
        'title': 'Most Popular Item',
        'value': data.topSellingItem?.name ?? 'N/A',
        'subtitle': data.topSellingItem != null
            ? '${data.topSellingItem!.quantity} sold'
            : '',
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'title': 'Busiest Day',
        'value': data.busiestDay.isNotEmpty ? data.busiestDay : 'N/A',
        'subtitle': data.busiestDayOrders > 0
            ? '${data.busiestDayOrders} orders'
            : '',
        'icon': Icons.calendar_today,
        'color': Colors.cyan,
      },
      {
        'title': 'Order Completion Rate',
        'value': '${(data.orderCompletionRate * 100).toStringAsFixed(1)}%',
        'subtitle': '${data.completedOrders} of ${data.totalOrders} orders',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Avg. Preparation Time',
        'value': '${data.avgPrepTime.toStringAsFixed(1)} min',
        'subtitle': 'From order to ready',
        'icon': Icons.timer,
        'color': Colors.orange,
      },
      {
        'title': 'Customer Retention',
        'value': '${(data.returnCustomerRate * 100).toStringAsFixed(1)}%',
        'subtitle': '${data.returningCustomers} returning customers',
        'icon': Icons.repeat,
        'color': Colors.purple,
      },
      {
        'title': 'Avg. Table Turnover',
        'value': '${data.avgTableTurnover.toStringAsFixed(1)}x',
        'subtitle': 'Per day',
        'icon': Icons.table_chart,
        'color': Colors.indigo,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final insight = insights[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (insight['color'] as Color).withOpacity(0.2),
              child: Icon(
                insight['icon'] as IconData,
                color: insight['color'] as Color,
              ),
            ),
            title: Text(insight['title'] as String),
            subtitle: Text(insight['subtitle'] as String),
            trailing: Text(
              insight['value'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate,
      end: _endDate,
    );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
        // Reset period to custom
        _selectedPeriod = 'custom';
      });
    }
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
      case 'quarter':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = now;
        break;
      case 'year':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        _endDate = now;
        break;
      case 'custom':
        // Keep existing range
        break;
    }
  }

  DateFormat _getDateFormat() {
    final daysDifference = _endDate.difference(_startDate).inDays;
    
    if (daysDifference <= 14) {
      return DateFormat.MMMd(); // Sep 14
    } else if (daysDifference <= 90) {
      return DateFormat.MMMd(); // Sep 14
    } else {
      return DateFormat.yMMMd(); // Sep 14, 2023
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting report... (not implemented)'),
      ),
    );
  }
}

// Models for analytics data
class AnalyticsDateRange {
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsDateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class AnalyticsData {
  final double totalSales;
  final int totalOrders;
  final double avgOrderValue;
  final int uniqueCustomers;
  final double salesTrend;
  final double ordersTrend;
  final double avgOrderTrend;
  final double customersTrend;
  final List<SalesDataPoint> salesByDate;
  final List<CategoryDataPoint> salesByCategory;
  final List<HourlyDataPoint> ordersByHour;
  final TopSellingItem? topSellingItem;
  final String busiestDay;
  final int busiestDayOrders;
  final double orderCompletionRate;
  final int completedOrders;
  final double avgPrepTime;
  final double returnCustomerRate;
  final int returningCustomers;
  final double avgTableTurnover;

  AnalyticsData({
    required this.totalSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.uniqueCustomers,
    required this.salesTrend,
    required this.ordersTrend,
    required this.avgOrderTrend,
    required this.customersTrend,
    required this.salesByDate,
    required this.salesByCategory,
    required this.ordersByHour,
    this.topSellingItem,
    required this.busiestDay,
    required this.busiestDayOrders,
    required this.orderCompletionRate,
    required this.completedOrders,
    required this.avgPrepTime,
    required this.returnCustomerRate,
    required this.returningCustomers,
    required this.avgTableTurnover,
  });
}

class SalesDataPoint {
  final DateTime date;
  final double sales;
  final int orders;

  SalesDataPoint({
    required this.date,
    required this.sales,
    required this.orders,
  });
}

class CategoryDataPoint {
  final String category;
  final double sales;
  final int orders;
  final Color color;

  CategoryDataPoint({
    required this.category,
    required this.sales,
    required this.orders,
    required this.color,
  });
}

class HourlyDataPoint {
  final int hour;
  final int orders;

  HourlyDataPoint({
    required this.hour,
    required this.orders,
  });
}

class TopSellingItem {
  final String name;
  final int quantity;
  final double revenue;

  TopSellingItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}
