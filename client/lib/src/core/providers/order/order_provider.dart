import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_admin_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';



// Provider for orders by status
final ordersByStatusStringProvider = StreamProvider.family<List<Order>, String>((ref, status) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStringStream(status);
});

// Provider for orders by resource
final ordersByResourceProvider = StreamProvider.family<List<Order>, String>((ref, resourceId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByResourceStream(resourceId);
});

// Provider for user orders
final userOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user.value?.uid == null) {
    return Stream.value([]);
  }
  
  return orderService.getUserOrdersStream(user.value!.uid);
});

// Provider for recent orders using getRecentOrdersStream
final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getRecentOrdersStream();
});

// Provider for a specific order
final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderById(orderId);
});

// Provider for active order (currently being viewed/edited)
final activeOrderIdProvider = StateProvider<String?>((ref) => null);

// Provider for active order data
final activeOrderProvider = FutureProvider<Order?>((ref) {
  final orderId = ref.watch(activeOrderIdProvider);
  if (orderId == null) {
    return null;
  }
  
  return ref.watch(orderByIdProvider(orderId)).value;
});

