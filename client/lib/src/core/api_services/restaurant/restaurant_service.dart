import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/restaurant/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

import 'dart:async';

import 'package:starter_architecture_flutter_firebase/src/core/api_services/staff/staff_service.dart';

// final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrderById(orderId) as FutureOr<Order?>;
// });

// final ordersByTableProvider =
//     StreamProvider.family<List<Order>, String>((ref, tableId) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByTableStream(tableId);
// });

// final pendingOrdersProvider = StreamProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByStatusStream(OrderStatus.pending);
// });

// final preparingOrdersProvider = StreamProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByStatusStream(OrderStatus.preparing);
// });

// final readyOrdersProvider = StreamProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByStatusStream(OrderStatus.readyForDelivery);
// });

// final productsByCategoryProvider =
//     FutureProvider.family<List<MenuItem>, String>((ref, categoryId) {
//   final productService = ref.watch(productServiceProvider);
//   return productService.getProductsByCategory(categoryId)
//       as FutureOr<List<MenuItem>>;
// });

// Restaurant stats provider
final restaurantStatsProvider = FutureProvider<RestaurantStats>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  final orderService = ref.watch(orderServiceProvider);

  return Future.wait([
    tableService.getTableStats(),
    orderService.getOrderStats(),
  ]).then((results) {
    final tableStats = results[0] as TableStats;
    final orderStats = results[1] as OrderStats;

    // Calculate derived stats
    final availableTables = tableStats.totalTables -
        tableStats.occupiedTables -
        tableStats.cleaningTables -
        tableStats.reservedTables;
    final occupancyRate = tableStats.totalTables > 0
        ? tableStats.occupiedTables / tableStats.totalTables * 100
        : 0.0;
    final turnoverRate =
        orderStats.totalOrders > 0 && tableStats.totalTables > 0
            ? orderStats.completedOrders / tableStats.totalTables
            : 0.0;

    return RestaurantStats(
      totalTables: tableStats.totalTables,
      occupiedTables: tableStats.occupiedTables,
      cleaningTables: tableStats.cleaningTables,
      reservedTables: tableStats.reservedTables,
      pendingOrders: orderStats.pendingOrders,
      preparingOrders: orderStats.preparingOrders,
      readyOrders: orderStats.readyOrders,
      dailySales: orderStats.dailySales,
      averageServiceTime: orderStats.averageServiceTime,
      totalOrders: orderStats.totalOrders,
      completedOrders: orderStats.completedOrders,
      availableTables: availableTables,
      occupancyRate: occupancyRate,
      turnoverRate: turnoverRate,
    );
  });
});

// Staff providers
final currentStaffProvider = StreamProvider<StaffMember?>((ref) {
  final staffService = ref.watch(staffServiceProvider);
  return staffService.getCurrentStaffStream();
});

final waitersProvider = FutureProvider<List<StaffMember>>((ref) {
  final staffService = ref.watch(staffServiceProvider);
  return staffService.getStaffByRole(StaffRole.waiter);
});

final cashiersProvider = FutureProvider<List<StaffMember>>((ref) {
  final staffService = ref.watch(staffServiceProvider);
  return staffService.getStaffByRole(StaffRole.cashier);
});

class RestaurantStats {
  final int totalTables;
  final int occupiedTables;
  final int reservedTables;
  final int cleaningTables;
  final int pendingOrders;
  final int preparingOrders;
  final int readyOrders;
  final double dailySales;
  final int averageServiceTime;
  final int totalOrders;
  final int completedOrders;
  final int availableTables;
  final double occupancyRate;
  final double turnoverRate;

  RestaurantStats({
    required this.totalTables,
    required this.occupiedTables,
    required this.reservedTables,
    required this.cleaningTables,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.readyOrders,
    required this.dailySales,
    required this.averageServiceTime,
    required this.totalOrders,
    required this.completedOrders,
    required this.availableTables,
    required this.occupancyRate,
    required this.turnoverRate,
  });
}
