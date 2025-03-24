



// Providers for dashboard stats - FIXED
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_admin_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/service_factory.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

final orderStatsProvider = FutureProvider<OrderStats>((ref) async {
  // Using compute to avoid blocking the main thread for intensive calculations
  // This implementation avoids multiple unnecessary Firestore reads
  final pendingOrders = await ref.watch(pendingOrdersProvider.future);
  final allOrders = await ref.watch(allActiveOrdersProvider.future);

  return OrderStats(
    totalOrders: allOrders.length,
    pendingOrders: pendingOrders.length,
    preparingOrders: allOrders.where((o) => o.status == OrderStatus.preparing).length,
    completedOrders: allOrders.where((o) => o.status == OrderStatus.completed).length,
    readyOrders: allOrders.where((o) => o.status == OrderStatus.readyForDelivery).length,
    dailySales: allOrders.fold(0.0, (sum, order) => sum + order.totalAmount),
    averageServiceTime: 30, // Default value, replace with actual calculation
  );
});

final salesStatsProvider = FutureProvider<SalesStats>((ref) async {
  // Get all orders first to avoid multiple Firestore reads
   final allOrders = await ref.watch(allActiveOrdersProvider.future);
  
  // Now process the data locally
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  final totalSales = allOrders.fold(
    0.0, 
    (sum, order) => sum + (order.status != OrderStatus.cancelled ? order.totalAmount : 0)
  );
  
  final todayOrders = allOrders.where(
    (order) => order.createdAt.isAfter(startOfDay) && order.status != OrderStatus.cancelled
  );
  
  final todaySales = todayOrders.fold(
    0.0, 
    (sum, order) => sum + order.totalAmount
  );
  
  return SalesStats(
    totalSales: totalSales,
    todaySales: todaySales,
    orderCount: allOrders.length,
  );
});

final tableStatsProvider = FutureProvider<TableStats>((ref) async {
  // Use the existing table service through the resource service
  final resourceService = ref.watch(
    serviceFactoryProvider.select((factory) => 
      factory.createResourceService('table')
    )
  );
  
  // Get resource stats to avoid multiple Firestore reads
  final stats = await resourceService.getResourceStats();
  
  return TableStats(
    cleaningTables: stats.statusCounts['cleaning'] ?? 0,
    totalTables: stats.totalResources,
    occupiedTables: stats.statusCounts['occupied'] ?? 0,
    reservedTables: stats.statusCounts['reserved'] ?? 0,
  );
});

final productStatsProvider = FutureProvider<ProductStats>((ref) async {
  // Get catalog service for menu items
  final catalogService = ref.watch(
    serviceFactoryProvider.select((factory) => 
      factory.createCatalogService('menu')
    )
  );
  
  // Get all items and categories to avoid multiple Firestore reads
  final itemsStream = catalogService.getItems();
  final categoriesStream = catalogService.getCategories();
  
  final items = await itemsStream.first;
  final categories = await categoriesStream.first;
  
  return ProductStats(
    totalProducts: items.length,
    categories: categories.length,
    outOfStock: items.where((item) => !item.isAvailable).length,
  );
});

// This provider is already correctly implemented
final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  // Limit to last 5 orders for dashboard display
  return orderService.getRecentOrdersStream().map((orders) => orders.take(5).toList());
});

