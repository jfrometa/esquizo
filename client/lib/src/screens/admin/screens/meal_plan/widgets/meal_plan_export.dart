import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/subscriptions/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

// Date range provider
final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month - 1, now.day),
    end: now,
  );
});

// Report type
enum ReportType { mealPlans, mealUsage, customerUsage }

// Provider for loading data for reports
final reportDataProvider =
    FutureProvider.family<List<dynamic>, ReportType>((ref, reportType) async {
  final service = ref.watch(mealPlanServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  switch (reportType) {
    case ReportType.mealPlans:
      // Get all meal plans
      final allPlans = await service.getAllMealPlansStream().first;
      return allPlans;

    case ReportType.mealUsage:
      // Get all consumed items within date range
      final allPlans = await service.getAllMealPlansStream().first;

      final allConsumedItems = <ConsumedItem>[];
      for (final plan in allPlans) {
        final items = await service.getConsumedItemsStream(plan.id).first;
        allConsumedItems.addAll(items);
      }

      // Filter by date range
      return allConsumedItems.where((item) {
        return item.consumedAt.isAfter(dateRange.start) &&
            item.consumedAt
                .isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();

    case ReportType.customerUsage:
      // Get all meal plans
      final allPlans = await service.getAllMealPlansStream().first;

      // Group by customer
      final customerUsage = <String, List<MealPlan>>{};

      for (final plan in allPlans) {
        if (plan.ownerId.isEmpty) continue; // Skip plans without owner

        if (!customerUsage.containsKey(plan.ownerId)) {
          customerUsage[plan.ownerId] = [];
        }

        customerUsage[plan.ownerId]!.add(plan);
      }

      // Convert to list
      final result = <Map<String, dynamic>>[];

      for (final entry in customerUsage.entries) {
        final customerId = entry.key;
        final plans = entry.value;

        final customerName = plans.first.ownerName;
        double totalMeals = 0;
        double usedMeals = 0;
        double totalValue = 0;

        for (final plan in plans) {
          totalMeals += plan.totalMeals;
          usedMeals += plan.totalMeals - plan.mealsRemaining;
          totalValue += double.tryParse(plan.price) ?? 0.0;
        }

        result.add({
          'customerId': customerId,
          'customerName': customerName,
          'totalPlans': plans.length,
          'totalMeals': totalMeals,
          'usedMeals': usedMeals,
          'remainingMeals': totalMeals - usedMeals,
          'totalValue': totalValue,
        });
      }

      return result;
  }
});

class MealPlanExportScreen extends ConsumerStatefulWidget {
  const MealPlanExportScreen({super.key});

  @override
  ConsumerState<MealPlanExportScreen> createState() =>
      _MealPlanExportScreenState();
}

class _MealPlanExportScreenState extends ConsumerState<MealPlanExportScreen> {
  ReportType _selectedReportType = ReportType.mealPlans;
  String _exportFormat = 'CSV';
  bool _isExporting = false;
  String? _exportError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Export Reports'),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () => context.go('/admin/meal-plans'),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report configuration card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Configuration',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // Report type
                    Text(
                      'Report Type',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ReportType>(
                      segments: const [
                        ButtonSegment(
                          value: ReportType.mealPlans,
                          label: Text('Meal Plans'),
                          icon: Icon(Icons.assignment),
                        ),
                        ButtonSegment(
                          value: ReportType.mealUsage,
                          label: Text('Usage'),
                          icon: Icon(Icons.restaurant),
                        ),
                        ButtonSegment(
                          value: ReportType.customerUsage,
                          label: Text('Customer'),
                          icon: Icon(Icons.people),
                        ),
                      ],
                      selected: {_selectedReportType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedReportType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Date range
                    Text(
                      'Date Range',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
                            ),
                            onPressed: () => _selectDateRange(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Export format
                    Text(
                      'Format',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'CSV',
                          label: Text('CSV'),
                          icon: Icon(Icons.table_chart),
                        ),
                        ButtonSegment(
                          value: 'PDF',
                          label: Text('PDF'),
                          icon: Icon(Icons.picture_as_pdf),
                        ),
                      ],
                      selected: {_exportFormat},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _exportFormat = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Report preview
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Preview',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildReportPreview(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
                onPressed: _isExporting ? null : _exportReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            if (_exportError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _exportError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    final reportDataAsync = ref.watch(reportDataProvider(_selectedReportType));

    return reportDataAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('No data available for the selected date range.'),
            ),
          );
        }

        switch (_selectedReportType) {
          case ReportType.mealPlans:
            return _buildMealPlansPreview(data.cast<MealPlan>());
          case ReportType.mealUsage:
            return _buildMealUsagePreview(data.cast<ConsumedItem>());
          case ReportType.customerUsage:
            return _buildCustomerUsagePreview(
                data.cast<Map<String, dynamic>>());
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) {
        // Debug print the error and stack trace for troubleshooting
        debugPrint('Error loading report data: $error');
        debugPrint('Stack trace: $stack');
        return Center(
          child: Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildMealPlansPreview(List<MealPlan> plans) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: plans.length > 5 ? 5 : plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];

          return ListTile(
            title: Text(plan.title),
            subtitle: Text(
                'Owner: ${plan.ownerName.isNotEmpty ? plan.ownerName : "N/A"} • ' 'Meals: ${plan.mealsRemaining}/${plan.totalMeals}'),
            trailing: Text('\$${plan.price}'),
          );
        },
      ),
    );
  }

  Widget _buildMealUsagePreview(List<ConsumedItem> items) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: items.length > 5 ? 5 : items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            title: Text(item.itemName),
            subtitle: Text(
                'Date: ${DateFormat.yMMMd().add_jm().format(item.consumedAt)}${item.notes.isNotEmpty ? ' • Notes: ${item.notes}' : ''}'),
            trailing: Text('Plan ID: ${item.mealPlanId.substring(0, 6)}...'),
          );
        },
      ),
    );
  }

  Widget _buildCustomerUsagePreview(List<Map<String, dynamic>> customerData) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: customerData.length > 5 ? 5 : customerData.length,
        itemBuilder: (context, index) {
          final customer = customerData[index];

          return ListTile(
            title: Text(customer['customerName'] ?? 'Unknown'),
            subtitle: Text('Plans: ${customer['totalPlans']} • ' 'Meals: ${customer['usedMeals']}/${customer['totalMeals']}'),
            trailing: Text('\$${customer['totalValue'].toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
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

  Future<void> _exportReport() async {
    setState(() {
      _isExporting = true;
      _exportError = null;
    });

    try {
      final reportData =
          await ref.read(reportDataProvider(_selectedReportType).future);

      if (reportData.isEmpty) {
        throw Exception('No data to export');
      }

      // In a real implementation, this would actually create and download the exports
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_selectedReportType.name} report exported successfully as $_exportFormat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _exportError = e.toString();
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _getReportTitle() {
    switch (_selectedReportType) {
      case ReportType.mealPlans:
        return 'Meal Plans Report';
      case ReportType.mealUsage:
        return 'Meal Usage Report';
      case ReportType.customerUsage:
        return 'Customer Usage Report';
    }
  }
}
