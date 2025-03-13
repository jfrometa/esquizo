import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import '../../services/restaurant/table_service.dart';
import '../catalog/catalog_provider.dart';

// Provider for restaurant ID (could use the same as business ID or be different)
final restaurantIdProvider = Provider<String>((ref) {
  return ref.watch(currentBusinessIdProvider);
});

// Provider for table service
final tableServiceProvider = Provider<TableService>((ref) {
  final restaurantId = ref.watch(restaurantIdProvider);
  return TableService(restaurantId: restaurantId);
});

// Provider for tables stream
final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesStream();
});

// Provider for table stats
final tableStatsProvider = FutureProvider<TableStats>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTableStats();
});

// Provider for active tables only
final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getActiveTablesStream();
});

// Provider for table status
final tablesStatusProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesStream();
});

// Provider for available tables (for reservations)
final availableTablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
  final allTables = await ref.watch(tablesStatusProvider.future);
  return allTables.where((table) => 
    table.status == TableStatusEnum.available || 
    table.status == TableStatusEnum.reserved
  ).toList();
});

// Provider for a single table by ID
final tableByIdProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTableById(tableId);
});