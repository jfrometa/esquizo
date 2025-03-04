import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/models/table_model.dart';
import '../QR/models/restaurant_table.dart';

final tablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  return [
    RestaurantTable(id: '1', name: 'Table 1', capacity: 2, number: 1),
    RestaurantTable(id: '2', name: 'Table 2', capacity: 4, number: 1),
    RestaurantTable(id: '3', name: 'Table 3', capacity: 6, number: 1),
    RestaurantTable(id: '4', name: 'Table 4', capacity: 2, number: 1),
    RestaurantTable(id: '5', name: 'Table 5', capacity: 8, number: 1),
  ];
});

final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);