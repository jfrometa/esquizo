// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/models/restaurant_table.dart';
// import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/providers/table_providers.dart';

// class TableSelectionGrid extends ConsumerWidget {
//   final Function(RestaurantTable) onTableSelected;
  
//   const TableSelectionGrid({
//     Key? key,
//     required this.onTableSelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final tablesAsync = ref.watch(tablesProvider);
    
//     return tablesAsync.when(
//       data: (tables) => GridView.builder(
//         // ... Table grid implementation ...
//       ),
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//     );
//   }
// }