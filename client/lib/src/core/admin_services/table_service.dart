 
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/providers/restaurant/table_provider.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

 
// // // Provider for a single table
// // final tableProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getTable(tableId);
// // });

// // // Table-related stream providers
// // final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getTablesStream();
// // });

// // final tablesStatusProvider = FutureProvider<List<RestaurantTable>>((ref) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getAllTables();
// // });

// // final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getActiveTablesStream();
// // });

// // final availableTablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
// //   final allTables = await ref.watch(tablesStatusProvider.future);
// //   return allTables.where((table) => 
// //     table.status == TableStatusEnum.available || 
// //     table.status == TableStatusEnum.reserved
// //   ).toList();
// // });

// // final tableByIdProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getTableById(tableId);
// // });
