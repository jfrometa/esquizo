// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionsRepositoryHash() =>
    r'873d8e862d2103926bb5aa3bc0d6b0541ed6f2dc';

/// See also [subscriptionsRepository].
@ProviderFor(subscriptionsRepository)
final subscriptionsRepositoryProvider =
    AutoDisposeProvider<SubscriptionsRepository>.internal(
  subscriptionsRepository,
  name: r'subscriptionsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionsRepositoryRef
    = AutoDisposeProviderRef<SubscriptionsRepository>;
String _$ordersRepositoryHash() => r'c74b8791627c220ad3e67cb3d721a989b29aa2ac';

/// See also [ordersRepository].
@ProviderFor(ordersRepository)
final ordersRepositoryProvider = AutoDisposeProvider<OrdersRepository>.internal(
  ordersRepository,
  name: r'ordersRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRepositoryRef = AutoDisposeProviderRef<OrdersRepository>;
String _$subscriptionsPaginationHash() =>
    r'ab98b43891c5e202a4721f03814fba64b5148a59';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SubscriptionsPagination
    extends BuildlessAutoDisposeNotifier<PaginationState<Subscription>> {
  late final String userId;

  PaginationState<Subscription> build(
    String userId,
  );
}

/// See also [SubscriptionsPagination].
@ProviderFor(SubscriptionsPagination)
const subscriptionsPaginationProvider = SubscriptionsPaginationFamily();

/// See also [SubscriptionsPagination].
class SubscriptionsPaginationFamily
    extends Family<PaginationState<Subscription>> {
  /// See also [SubscriptionsPagination].
  const SubscriptionsPaginationFamily();

  /// See also [SubscriptionsPagination].
  SubscriptionsPaginationProvider call(
    String userId,
  ) {
    return SubscriptionsPaginationProvider(
      userId,
    );
  }

  @override
  SubscriptionsPaginationProvider getProviderOverride(
    covariant SubscriptionsPaginationProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subscriptionsPaginationProvider';
}

/// See also [SubscriptionsPagination].
class SubscriptionsPaginationProvider extends AutoDisposeNotifierProviderImpl<
    SubscriptionsPagination, PaginationState<Subscription>> {
  /// See also [SubscriptionsPagination].
  SubscriptionsPaginationProvider(
    String userId,
  ) : this._internal(
          () => SubscriptionsPagination()..userId = userId,
          from: subscriptionsPaginationProvider,
          name: r'subscriptionsPaginationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subscriptionsPaginationHash,
          dependencies: SubscriptionsPaginationFamily._dependencies,
          allTransitiveDependencies:
              SubscriptionsPaginationFamily._allTransitiveDependencies,
          userId: userId,
        );

  SubscriptionsPaginationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  PaginationState<Subscription> runNotifierBuild(
    covariant SubscriptionsPagination notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(SubscriptionsPagination Function() create) {
    return ProviderOverride(
      origin: this,
      override: SubscriptionsPaginationProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SubscriptionsPagination,
      PaginationState<Subscription>> createElement() {
    return _SubscriptionsPaginationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionsPaginationProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubscriptionsPaginationRef
    on AutoDisposeNotifierProviderRef<PaginationState<Subscription>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _SubscriptionsPaginationProviderElement
    extends AutoDisposeNotifierProviderElement<SubscriptionsPagination,
        PaginationState<Subscription>> with SubscriptionsPaginationRef {
  _SubscriptionsPaginationProviderElement(super.provider);

  @override
  String get userId => (origin as SubscriptionsPaginationProvider).userId;
}

String _$ordersPaginationHash() => r'fa8bc4a818aabc832233da243c94795eba97d713';

abstract class _$OrdersPagination
    extends BuildlessAutoDisposeNotifier<PaginationState<auth_models.Order>> {
  late final String userId;

  PaginationState<auth_models.Order> build(
    String userId,
  );
}

/// See also [OrdersPagination].
@ProviderFor(OrdersPagination)
const ordersPaginationProvider = OrdersPaginationFamily();

/// See also [OrdersPagination].
class OrdersPaginationFamily
    extends Family<PaginationState<auth_models.Order>> {
  /// See also [OrdersPagination].
  const OrdersPaginationFamily();

  /// See also [OrdersPagination].
  OrdersPaginationProvider call(
    String userId,
  ) {
    return OrdersPaginationProvider(
      userId,
    );
  }

  @override
  OrdersPaginationProvider getProviderOverride(
    covariant OrdersPaginationProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ordersPaginationProvider';
}

/// See also [OrdersPagination].
class OrdersPaginationProvider extends AutoDisposeNotifierProviderImpl<
    OrdersPagination, PaginationState<auth_models.Order>> {
  /// See also [OrdersPagination].
  OrdersPaginationProvider(
    String userId,
  ) : this._internal(
          () => OrdersPagination()..userId = userId,
          from: ordersPaginationProvider,
          name: r'ordersPaginationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersPaginationHash,
          dependencies: OrdersPaginationFamily._dependencies,
          allTransitiveDependencies:
              OrdersPaginationFamily._allTransitiveDependencies,
          userId: userId,
        );

  OrdersPaginationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  PaginationState<auth_models.Order> runNotifierBuild(
    covariant OrdersPagination notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(OrdersPagination Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrdersPaginationProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<OrdersPagination,
      PaginationState<auth_models.Order>> createElement() {
    return _OrdersPaginationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersPaginationProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersPaginationRef
    on AutoDisposeNotifierProviderRef<PaginationState<auth_models.Order>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _OrdersPaginationProviderElement
    extends AutoDisposeNotifierProviderElement<OrdersPagination,
        PaginationState<auth_models.Order>> with OrdersPaginationRef {
  _OrdersPaginationProviderElement(super.provider);

  @override
  String get userId => (origin as OrdersPaginationProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
