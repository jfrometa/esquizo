// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartServiceHash() => r'406b398594a39b21f55680ff14e67ae1b6801b89';

/// Provider for cart service
///
/// Copied from [cartService].
@ProviderFor(cartService)
final cartServiceProvider = AutoDisposeProvider<CartService>.internal(
  cartService,
  name: r'cartServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartServiceRef = AutoDisposeProviderRef<CartService>;
String _$cartItemCountHash() => r'8ed42034e9aa1d8dc2475c3143c93cac4de1c11b';

/// Helper providers for accessing cart properties
/// Provider for cart item count
///
/// Copied from [cartItemCount].
@ProviderFor(cartItemCount)
final cartItemCountProvider = AutoDisposeProvider<int>.internal(
  cartItemCount,
  name: r'cartItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemCountRef = AutoDisposeProviderRef<int>;
String _$cartSubtotalHash() => r'016903b9df508053369436fd95c62d4ce7524103';

/// Provider for cart subtotal
///
/// Copied from [cartSubtotal].
@ProviderFor(cartSubtotal)
final cartSubtotalProvider = AutoDisposeProvider<double>.internal(
  cartSubtotal,
  name: r'cartSubtotalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartSubtotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartSubtotalRef = AutoDisposeProviderRef<double>;
String _$cartTotalHash() => r'0a929cbc9fb70b577bc9ad18164cbf592e516897';

/// Provider for cart total
///
/// Copied from [cartTotal].
@ProviderFor(cartTotal)
final cartTotalProvider = AutoDisposeProvider<double>.internal(
  cartTotal,
  name: r'cartTotalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartTotalRef = AutoDisposeProviderRef<double>;
String _$cartMealPlansHash() => r'602eb8b7291bb1a5eb3f4dd96e3e51b3608308a5';

/// Provider for meal plans in cart
///
/// Copied from [cartMealPlans].
@ProviderFor(cartMealPlans)
final cartMealPlansProvider = AutoDisposeProvider<List<CartItem>>.internal(
  cartMealPlans,
  name: r'cartMealPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartMealPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartMealPlansRef = AutoDisposeProviderRef<List<CartItem>>;
String _$cartCateringItemsHash() => r'a5264f245255f7e528d7571380da195ad988c3c4';

/// Provider for catering items in cart
///
/// Copied from [cartCateringItems].
@ProviderFor(cartCateringItems)
final cartCateringItemsProvider = AutoDisposeProvider<List<CartItem>>.internal(
  cartCateringItems,
  name: r'cartCateringItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartCateringItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartCateringItemsRef = AutoDisposeProviderRef<List<CartItem>>;
String _$cartRegularItemsHash() => r'c3e7c3f2a9e453488ef9c8cdacb9ba18cea200d5';

/// Provider for regular items in cart
///
/// Copied from [cartRegularItems].
@ProviderFor(cartRegularItems)
final cartRegularItemsProvider = AutoDisposeProvider<List<CartItem>>.internal(
  cartRegularItems,
  name: r'cartRegularItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartRegularItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartRegularItemsRef = AutoDisposeProviderRef<List<CartItem>>;
String _$cartMealPlanDishesHash() =>
    r'6dae2a7a82733116a838ac675e05b31fbbbadd1c';

/// Provider for meal plan dishes in cart
///
/// Copied from [cartMealPlanDishes].
@ProviderFor(cartMealPlanDishes)
final cartMealPlanDishesProvider = AutoDisposeProvider<List<CartItem>>.internal(
  cartMealPlanDishes,
  name: r'cartMealPlanDishesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartMealPlanDishesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartMealPlanDishesRef = AutoDisposeProviderRef<List<CartItem>>;
String _$cartNotifierHash() => r'2b963c2c0113bce5d1dda862591b359a4c4d22ff';

/// Notifier for cart state
///
/// Copied from [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider = NotifierProvider<CartNotifier, Cart>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = Notifier<Cart>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
