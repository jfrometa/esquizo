
// Update the providers to use OrderService instead of direct Firebase calls
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/service_factory.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';


final activeOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service to get orders by status for the specific user
  return orderService.getActiveOrdersStream();
});

// Add a provider for all active orders (no user filter)
final allActiveOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service's existing method to get all active orders
  return orderService.getActiveOrdersStream();
});

// Create a provider for completed orders pagination using OrderService
final completedOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service to get completed orders for the specific user
  return orderService.getCompletedOrdersStream(ref, userId);
});


final orderServiceProvider = Provider<OrderService>((ref) {

  // Get catalog service for menu items
  final orderService = ref.watch(
    serviceFactoryProvider.select((factory) => 
      factory.createOrderService()
    )
  );

  return orderService;
});

 