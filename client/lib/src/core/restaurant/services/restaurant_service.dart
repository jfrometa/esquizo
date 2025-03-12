 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/providers/table_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/product_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart'; 

import 'dart:async';

 import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/product_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/staff_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/table_service.dart';


final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderById(orderId) as FutureOr<Order?>;
});

final ordersByTableProvider = StreamProvider.family<List<Order>, String>((ref, tableId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByTableStream(tableId);
});

final pendingOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.pending)  ;
});

final preparingOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.preparing) ;
});

final readyOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.readyForDelivery)  ;
});

// Menu-related providers
// final menuCategoriesProvider = FutureProvider<List<MenuCategory>>((ref) {
//   final productService = ref.watch(productServiceProvider);
//   return productService.getCategories() as FutureOr<List<MenuCategory>>;
// });

// final menuProductsProvider = FutureProvider<List<MenuItem>>((ref) {
//   final productService = ref.watch(productServiceProvider);
//   return productService.getProducts() as FutureOr<List<MenuItem>>;
// });

final productsByCategoryProvider = FutureProvider.family<List<MenuItem>, String>((ref, categoryId) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsByCategory(categoryId) as FutureOr<List<MenuItem>>;
});

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

class OrderStats {
  final int pendingOrders;
  final int preparingOrders;
  final int readyOrders;
  final double dailySales;
  final int averageServiceTime;
  final int totalOrders;
  final int completedOrders;

  OrderStats({
    required this.pendingOrders,
    required this.preparingOrders,
    required this.readyOrders,
    required this.dailySales,
    required this.averageServiceTime,
    required this.totalOrders,
    required this.completedOrders,
  });
}

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
  });
}