// Provider for analytics data based on date range
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart';

// Provider for analytics data based on date range
final analyticsDataProvider =
    FutureProvider.family<AnalyticsData, AnalyticsDateRange>(
        (ref, dateRange) async {
  // This would typically call a method on the order service to get analytics data,
  // but for this example, we'll mock the data
  await Future.delayed(const Duration(seconds: 1)); // Simulate API call

  // Mock data for demonstration
  return _generateMockAnalyticsData(dateRange);
});

// Generate mock data for demonstration
AnalyticsData _generateMockAnalyticsData(AnalyticsDateRange dateRange) {
  final random = DateTime.now().millisecondsSinceEpoch;
  final daysDifference =
      dateRange.endDate.difference(dateRange.startDate).inDays;

  // Generate sales data points
  final salesByDate = <SalesDataPoint>[];
  for (int i = 0; i <= daysDifference; i++) {
    final date = dateRange.startDate.add(Duration(days: i));
    final sales = 500.0 +
        (random % 1000) +
        (i * 10); // Some random sales with an upward trend
    final orders = 10 +
        (random % 20) +
        (i ~/ 3); // Some random orders with a slight upward trend
    salesByDate.add(SalesDataPoint(
      date: date,
      sales: sales,
      orders: orders,
    ));
  }

  // Calculate totals
  final totalSales = salesByDate.fold(0.0, (sum, data) => sum + data.sales);
  final totalOrders = salesByDate.fold(0, (sum, data) => sum + data.orders);
  final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;
  final uniqueCustomers =
      (totalOrders * 0.8).round(); // Assume 80% unique customers

  // Generate category data
  final categories = ['Food', 'Beverages', 'Desserts', 'Others'];
  final categoryColors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
  final salesByCategory = <CategoryDataPoint>[];

  double totalCategorySales = 0;
  for (int i = 0; i < categories.length; i++) {
    final categorySales = totalSales *
        (0.1 + (i * 0.15 + (random % 20) / 100)); // Random distribution
    totalCategorySales += categorySales;
    salesByCategory.add(CategoryDataPoint(
      category: categories[i],
      sales: categorySales,
      orders: (totalOrders * (0.1 + (i * 0.15 + (random % 20) / 100))).round(),
      color: categoryColors[i],
    ));
  }

  // Normalize to match the total sales
  final scaleFactor = totalSales / totalCategorySales;
  for (int i = 0; i < salesByCategory.length; i++) {
    final item = salesByCategory[i];
    salesByCategory[i] = CategoryDataPoint(
      category: item.category,
      sales: item.sales * scaleFactor,
      orders: item.orders,
      color: item.color,
    );
  }

  // Generate hourly data
  final ordersByHour = <HourlyDataPoint>[];
  for (int hour = 0; hour < 24; hour++) {
    // Restaurants typically have peaks around lunch and dinner
    int orders;
    if (hour >= 11 && hour <= 14) {
      // Lunch peak
      orders = 10 + (random % 15);
    } else if (hour >= 18 && hour <= 21) {
      // Dinner peak
      orders = 15 + (random % 20);
    } else if (hour >= 6 && hour <= 23) {
      // Regular hours
      orders = 2 + (random % 8);
    } else {
      // Closed or very low activity
      orders = random % 2;
    }
    ordersByHour.add(HourlyDataPoint(
      hour: hour,
      orders: orders,
    ));
  }

  // Find busiest day
  String busiestDay = '';
  int busiestDayOrders = 0;
  for (final data in salesByDate) {
    if (data.orders > busiestDayOrders) {
      busiestDayOrders = data.orders;
      busiestDay = DateFormat('EEEE').format(data.date); // Day of week name
    }
  }

  // Other metrics
  final completedOrders = (totalOrders * 0.92).round(); // 92% completion rate
  final orderCompletionRate = completedOrders / totalOrders;
  final avgPrepTime = 15.0 + (random % 10); // Average prep time in minutes
  final returningCustomers =
      (uniqueCustomers * 0.3).round(); // 30% returning customers
  final returnCustomerRate = returningCustomers / uniqueCustomers;
  final avgTableTurnover = 2.5 + (random % 15) / 10; // Average table turnover

  // Top selling item
  final topSellingItem = TopSellingItem(
    name: 'Signature Burger',
    quantity: 120 + (random % 50),
    revenue: 1200.0 + (random % 500),
  );

  // Calculate trends
  final previousPeriodSales = totalSales * (0.8 + (random % 40) / 100);
  final previousPeriodOrders = totalOrders * (0.8 + (random % 40) / 100);
  final previousPeriodAvgOrder = previousPeriodSales / previousPeriodOrders;
  final previousPeriodCustomers = uniqueCustomers * (0.8 + (random % 40) / 100);

  final salesTrend = (totalSales - previousPeriodSales) / previousPeriodSales;
  final ordersTrend =
      (totalOrders - previousPeriodOrders) / previousPeriodOrders;
  final avgOrderTrend =
      (avgOrderValue - previousPeriodAvgOrder) / previousPeriodAvgOrder;
  final customersTrend =
      (uniqueCustomers - previousPeriodCustomers) / previousPeriodCustomers;

  return AnalyticsData(
    totalSales: totalSales,
    totalOrders: totalOrders,
    avgOrderValue: avgOrderValue,
    uniqueCustomers: uniqueCustomers,
    salesTrend: salesTrend,
    ordersTrend: ordersTrend,
    avgOrderTrend: avgOrderTrend,
    customersTrend: customersTrend,
    salesByDate: salesByDate,
    salesByCategory: salesByCategory,
    ordersByHour: ordersByHour,
    topSellingItem: topSellingItem,
    busiestDay: busiestDay,
    busiestDayOrders: busiestDayOrders,
    orderCompletionRate: orderCompletionRate,
    completedOrders: completedOrders,
    avgPrepTime: avgPrepTime,
    returnCustomerRate: returnCustomerRate,
    returningCustomers: returningCustomers,
    avgTableTurnover: avgTableTurnover,
  );
}
