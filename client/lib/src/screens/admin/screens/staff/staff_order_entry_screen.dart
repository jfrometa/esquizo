import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/table_and_order_management/table_and_order_management_screen.dart';

class StaffOrderEntryScreen extends ConsumerStatefulWidget {
  final String tableId;
  const StaffOrderEntryScreen({super.key, required this.tableId});

  @override
  ConsumerState<StaffOrderEntryScreen> createState() =>
      _StaffOrderEntryScreenState();
}

class _StaffOrderEntryScreenState extends ConsumerState<StaffOrderEntryScreen> {
  RestaurantTable? _table;
  Order? _existingOrder;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTableAndOrder();
  }

  Future<void> _loadTableAndOrder() async {
    try {
      final tableService = ref.read(tableServiceProvider);
      final orderService = ref.read(orderServiceProvider);

      // Try to find table by number first (tableId might be "table-1" format)
      final tableNumber = _extractTableNumber(widget.tableId);
      final tables = await tableService.getAllTables();

      _table = tables.firstWhere(
        (table) => table.number == tableNumber,
        orElse: () => throw Exception('Table not found'),
      );

      // If table has an active order, load it
      if (_table!.currentOrderId != null) {
        _existingOrder =
            await orderService.getOrderById(_table!.currentOrderId!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _extractTableNumber(String tableId) {
    // Extract number from "table-1" format or similar
    final match = RegExp(r'\d+').firstMatch(tableId);
    return match?.group(0) ?? '1';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading table: $_errorMessage',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // If table not found, show error
    if (_table == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Table ${widget.tableId} not found',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Use the comprehensive TableOrderScreen
    return TableOrderScreen(
      table: _table!,
      existingOrder: _existingOrder,
    );
  }
}
