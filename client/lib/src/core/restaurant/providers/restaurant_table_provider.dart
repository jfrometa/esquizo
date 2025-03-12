// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/table_service.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/services/table_service.dart';
// import '../services/restaurant_table_service.dart'; 
// import '../../providers/business/business_config_provider.dart';

// // Provider for restaurant table service
// final restaurantTableServiceProvider = Provider<RestaurantTableService>((ref) {
//   final businessId = ref.watch(currentBusinessIdProvider);
//   return RestaurantTableService(businessId: businessId);
// });

// // Provider for tables stream
// final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getTablesStream();
// });

// // Provider for active tables
// final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getActiveTablesStream();
// });

// // Provider for tables by status
// final tablesByStatusProvider = StreamProvider.family<List<RestaurantTable>, TableStatus>((ref, status) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getTablesByStatusStream(status);
// });

// // Provider for available tables
// final availableTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getTablesByStatusStream(TableStatus.available);
// });

// // Provider for table by ID
// final tableByIdProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getTableById(tableId);
// });

// // Provider for table stats
// final tableStatsProvider = FutureProvider<TableStats>((ref) {
//   final tableService = ref.watch(restaurantTableServiceProvider);
//   return tableService.getTableStats();
// });