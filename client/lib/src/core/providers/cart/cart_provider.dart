import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/cart_service.dart';

// Provider for cart service
final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

// Provider for cart state
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return CartNotifier(cartService);
});

// Cart notifier
class CartNotifier extends StateNotifier<Cart> {
  final CartService _cartService;
  
  CartNotifier(this._cartService) : super(_cartService.cart);
  
  void addItem(CartItem item) {
    _cartService.addItem(item);
    state = _cartService.cart;
  }
  
  void removeItem(int index) {
    _cartService.removeItem(index);
    state = _cartService.cart;
  }
  
  void updateItemQuantity(int index, int quantity) {
    _cartService.updateItemQuantity(index, quantity);
    state = _cartService.cart;
  }
  
  void clearCart() {
    _cartService.clearCart();
    state = _cartService.cart;
  }
  
  void updateSpecialInstructions(String? instructions) {
    _cartService.updateSpecialInstructions(instructions);
    state = _cartService.cart;
  }
  
  void updateResourceId(String? resourceId) {
    _cartService.updateResourceId(resourceId);
    state = _cartService.cart;
  }
  
  void updateDeliveryOption(bool isDelivery) {
    _cartService.updateDeliveryOption(isDelivery);
    state = _cartService.cart;
  }
  
  void updatePeopleCount(int count) {
    _cartService.updatePeopleCount(count);
    state = _cartService.cart;
  }
}

// Provider for cart item count
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
});

// Provider for cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
});

// Provider for cart total
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.total;
});