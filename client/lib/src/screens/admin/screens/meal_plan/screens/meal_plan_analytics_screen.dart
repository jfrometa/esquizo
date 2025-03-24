import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
 
import 'package:fl_chart/fl_chart.dart';

// Date range provider
final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month - 1, now.day),
    end: now,
  );
});

// Analytics data model
class MealPlanAnalyticsData {
  final int totalMealPlans;
  final int activeMealPlans;
  final int totalMealsUsed;
  final double totalMealPlanValue;
  final Map<String, int> usageByCategory;
  final List<MapEntry<DateTime, int>> usageByDate;
  final List<MapEntry<String, int>> topMealPlans;
  final List<MapEntry<String, int>> topItems;
  
  MealPlanAnalyticsData({
    required this.totalMealPlans,
    required this.activeMealPlans,
    required this.totalMealsUsed,
    required this.totalMealPlanValue,
    required this.usageByCategory,
    required this.usageByDate,
    required this.topMealPlans,
    required this.topItems,
  });
}

// Provider for analytics data
final mealPlanAnalyticsProvider = FutureProvider<MealPlanAnalyticsData>((ref) async {
  final service = ref.watch(mealPlanServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);
  
  // Get all meal plans
  final allPlans = await service.getAllMealPlansStream().first;
  
  // Active plans
  final activePlans = allPlans.where((plan) => plan.isActive).toList();
  
  // Get all consumed items
  final allConsumedItems = <ConsumedItem>[];
  for (final plan in allPlans) {
    final items = await service.getConsumedItemsStream(plan.id).first;
    allConsumedItems.addAll(items);
  }
  
  // Filter by date range
  final filteredItems = allConsumedItems.where((item) {
    return item.consumedAt.isAfter(dateRange.start) && 
           item.consumedAt.isBefore(dateRange.end.add(const Duration(days: 1)));
  }).toList();
  
  // Calculate total value
  double totalValue = 0;
  for (final plan in allPlans) {
    final price = double.tryParse(plan.price) ?? 0.0;
    totalValue += price;
  }
  
  // Usage by category
  final usageByCategory = <String, int>{};
  for (final item in filteredItems) {
    final plan = allPlans.firstWhere(
      (p) => p.id == item.mealPlanId,
      orElse: () => MealPlan(
        title: 'Unknown',
        price: '0',
        features: [],
        description: '',
        longDescription: '',
        howItWorks: '',
        totalMeals: 0,
        mealsRemaining: 0,
        categoryName: 'Unknown',
      ),
    );
    
    final category = plan.categoryName;
    usageByCategory[category] = (usageByCategory[category] ?? 0) + 1;
  }
  
  // Usage by date
  final usageByDate = <DateTime, int>{};
  for (final item in filteredItems) {
    final date = DateTime(
      item.consumedAt.year,
      item.consumedAt.month,
      item.consumedAt.day,
    );
    usageByDate[date] = (usageByDate[date] ?? 0) + 1;
  }
  
  // Top meal plans
  final planUsage = <String, int>{};
  for (final item in filteredItems) {
    planUsage[item.mealPlanId] = (planUsage[item.mealPlanId] ?? 0) + 1;
  }
  
  final topPlanIds = planUsage.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final topMealPlans = <MapEntry<String, int>>[];
  for (final entry in topPlanIds.take(5)) {
    final plan = allPlans.firstWhere(
      (p) => p.id == entry.key,
      orElse: () => MealPlan(
        title: 'Unknown',
        price: '0',
        features: [],
        description: '',
        longDescription: '',
        howItWorks: '',
        totalMeals: 0,
        mealsRemaining: 0,
      ),
    );
    
    topMealPlans.add(MapEntry(plan.title, entry.value));
  }
  
  // Top items
  final itemUsage = <String, int>{};
  for (final item in filteredItems) {
    itemUsage[item.itemName] = (itemUsage[item.itemName] ?? 0) + 1;
  }
  
  final topItems = itemUsage.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  return MealPlanAnalyticsData(
    totalMealPlans: allPlans.length,
    activeMealPlans: activePlans.length,
    totalMealsUsed: filteredItems.length,
    totalMealPlanValue: totalValue,
    usageByCategory: usageByCategory,
    usageByDate: usageByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)),
    topMealPlans: topMealPlans,
    topItems: topItems.take(5).toList(),
  );
});

class MealPlanAnalyticsScreen extends ConsumerWidget {
  const MealPlanAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateRange = ref.watch(dateRangeProvider);
    final analyticsAsync = ref.watch(mealPlanAnalyticsProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Analytics'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
            ),
            onPressed: () => _selectDateRange(context, ref),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: analyticsAsync.when(
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                isDesktop
                    ? _buildSummaryCardsDesktop(context, data)
                    : _buildSummaryCardsMobile(context, data),
                
                const SizedBox(height: 24),
                
                // Usage over time chart
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usage Over Time',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: _buildUsageChart(context, data),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Usage by category and top items
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCategoryBreakdown(context, data),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTopItems(context, data),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCategoryBreakdown(context, data),
                          const SizedBox(height: 16),
                          _buildTopItems(context, data),
                        ],
                      ),
                
                const SizedBox(height: 24),
                
                // Top meal plans
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Meal Plans',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...data.topMealPlans.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(entry.key),
                              ),
                              Container(
                                width: 60,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${entry.value}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(dateRangeProvider);
    
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (newRange != null) {
      ref.read(dateRangeProvider.notifier).state = newRange;
    }
  }
  
  Widget _buildSummaryCardsDesktop(BuildContext context, MealPlanAnalyticsData data) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Total Meal Plans',
            value: data.totalMealPlans.toString(),
            icon: Icons.assignment,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Active Plans',
            value: data.activeMealPlans.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Meals Used',
            value: data.totalMealsUsed.toString(),
            icon: Icons.restaurant,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Total Value',
            value: '\$${data.totalMealPlanValue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCardsMobile(BuildContext context, MealPlanAnalyticsData data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Total Meal Plans',
                value: data.totalMealPlans.toString(),
                icon: Icons.assignment,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Active Plans',
                value: data.activeMealPlans.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Meals Used',
                value: data.totalMealsUsed.toString(),
                icon: Icons.restaurant,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Total Value',
                value: '\$${data.totalMealPlanValue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUsageChart(BuildContext context, MealPlanAnalyticsData data) {
    final theme = Theme.of(context);
    
    if (data.usageByDate.isEmpty) {
      return const Center(
        child: Text('No data available for the selected date range.'),
      );
    }
    
    // Prepare line chart data
    final spots = data.usageByDate.map((entry) {
      final date = entry.key;
      final count = entry.value;
      
      // Convert date to x value (days since start date)
      final daysSinceStart = date.difference(data.usageByDate.first.key).inDays.toDouble();
      
      return FlSpot(daysSinceStart, count.toDouble());
    }).toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5, // Show every 5 days
              getTitlesWidget: (value, meta) {
                if (value % 5 != 0 && value != 0) {
                  return const SizedBox.shrink();
                }
                
                // Convert back to date
                final date = data.usageByDate.first.key.add(Duration(days: value.toInt()));
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.MMMd().format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        minX: 0,
        maxX: data.usageByDate.length > 1
            ? data.usageByDate.last.key.difference(data.usageByDate.first.key).inDays.toDouble()
            : 1,
        minY: 0,
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = data.usageByDate.first.key.add(Duration(days: spot.x.toInt()));
                return LineTooltipItem(
                  '${DateFormat.yMMMd().format(date)}\n',
                  const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${spot.y.toInt()} meals used',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryBreakdown(BuildContext context, MealPlanAnalyticsData data) {
    final theme = Theme.of(context);
    
    if (data.usageByCategory.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage by Category',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No data available for the selected date range.'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Calculate total for percentages
    final total = data.usageByCategory.values.fold(0, (sum, item) => sum + item);
    
    // Sort by usage (descending)
    final sortedCategories = data.usageByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage by Category',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopItems(BuildContext context, MealPlanAnalyticsData data) {
    final theme = Theme.of(context);
    
    if (data.topItems.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Items',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No data available for the selected date range.'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Items',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...data.topItems.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          'Used ${entry.value} times',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        entry.value.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}