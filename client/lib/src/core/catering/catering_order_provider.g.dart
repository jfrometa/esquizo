// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catering_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingCateringOrdersHash() =>
    r'14502c53318dc0b2503c79e1be354b1c32c0fb00';

/// See also [upcomingCateringOrders].
@ProviderFor(upcomingCateringOrders)
final upcomingCateringOrdersProvider =
    StreamProvider<List<model.CateringOrder>>.internal(
  upcomingCateringOrders,
  name: r'upcomingCateringOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingCateringOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingCateringOrdersRef
    = StreamProviderRef<List<model.CateringOrder>>;
String _$allCateringOrdersHash() => r'7ca1f08e23333b17b50be875cfa521c7588dcea2';

/// See also [allCateringOrders].
@ProviderFor(allCateringOrders)
final allCateringOrdersProvider =
    StreamProvider<List<model.CateringOrder>>.internal(
  allCateringOrders,
  name: r'allCateringOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCateringOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCateringOrdersRef = StreamProviderRef<List<model.CateringOrder>>;
String _$todayCateringOrdersHash() =>
    r'48fb9080f514ddd31af4e19b163137548b8a24a2';

/// See also [todayCateringOrders].
@ProviderFor(todayCateringOrders)
final todayCateringOrdersProvider =
    StreamProvider<List<model.CateringOrder>>.internal(
  todayCateringOrders,
  name: r'todayCateringOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayCateringOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayCateringOrdersRef = StreamProviderRef<List<model.CateringOrder>>;
String _$ordersByStatusHash() => r'07caf1d99e93615c5308108d210fe832fe947e86';

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

/// See also [ordersByStatus].
@ProviderFor(ordersByStatus)
const ordersByStatusProvider = OrdersByStatusFamily();

/// See also [ordersByStatus].
class OrdersByStatusFamily
    extends Family<AsyncValue<List<model.CateringOrder>>> {
  /// See also [ordersByStatus].
  const OrdersByStatusFamily();

  /// See also [ordersByStatus].
  OrdersByStatusProvider call(
    CateringOrderStatus status,
  ) {
    return OrdersByStatusProvider(
      status,
    );
  }

  @override
  OrdersByStatusProvider getProviderOverride(
    covariant OrdersByStatusProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'ordersByStatusProvider';
}

/// See also [ordersByStatus].
class OrdersByStatusProvider
    extends AutoDisposeStreamProvider<List<model.CateringOrder>> {
  /// See also [ordersByStatus].
  OrdersByStatusProvider(
    CateringOrderStatus status,
  ) : this._internal(
          (ref) => ordersByStatus(
            ref as OrdersByStatusRef,
            status,
          ),
          from: ordersByStatusProvider,
          name: r'ordersByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersByStatusHash,
          dependencies: OrdersByStatusFamily._dependencies,
          allTransitiveDependencies:
              OrdersByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  OrdersByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final CateringOrderStatus status;

  @override
  Override overrideWith(
    Stream<List<model.CateringOrder>> Function(OrdersByStatusRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersByStatusProvider._internal(
        (ref) => create(ref as OrdersByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<model.CateringOrder>> createElement() {
    return _OrdersByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersByStatusRef
    on AutoDisposeStreamProviderRef<List<model.CateringOrder>> {
  /// The parameter `status` of this provider.
  CateringOrderStatus get status;
}

class _OrdersByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<model.CateringOrder>>
    with OrdersByStatusRef {
  _OrdersByStatusProviderElement(super.provider);

  @override
  CateringOrderStatus get status => (origin as OrdersByStatusProvider).status;
}

String _$userCateringOrdersHash() =>
    r'dbd8f52d3fe8b2b38ef98d2f3c5249d6f43ffd7f';

/// See also [userCateringOrders].
@ProviderFor(userCateringOrders)
const userCateringOrdersProvider = UserCateringOrdersFamily();

/// See also [userCateringOrders].
class UserCateringOrdersFamily
    extends Family<AsyncValue<List<model.CateringOrder>>> {
  /// See also [userCateringOrders].
  const UserCateringOrdersFamily();

  /// See also [userCateringOrders].
  UserCateringOrdersProvider call(
    String userId,
  ) {
    return UserCateringOrdersProvider(
      userId,
    );
  }

  @override
  UserCateringOrdersProvider getProviderOverride(
    covariant UserCateringOrdersProvider provider,
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
  String? get name => r'userCateringOrdersProvider';
}

/// See also [userCateringOrders].
class UserCateringOrdersProvider
    extends AutoDisposeStreamProvider<List<model.CateringOrder>> {
  /// See also [userCateringOrders].
  UserCateringOrdersProvider(
    String userId,
  ) : this._internal(
          (ref) => userCateringOrders(
            ref as UserCateringOrdersRef,
            userId,
          ),
          from: userCateringOrdersProvider,
          name: r'userCateringOrdersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userCateringOrdersHash,
          dependencies: UserCateringOrdersFamily._dependencies,
          allTransitiveDependencies:
              UserCateringOrdersFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserCateringOrdersProvider._internal(
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
  Override overrideWith(
    Stream<List<model.CateringOrder>> Function(UserCateringOrdersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserCateringOrdersProvider._internal(
        (ref) => create(ref as UserCateringOrdersRef),
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
  AutoDisposeStreamProviderElement<List<model.CateringOrder>> createElement() {
    return _UserCateringOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCateringOrdersProvider && other.userId == userId;
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
mixin UserCateringOrdersRef
    on AutoDisposeStreamProviderRef<List<model.CateringOrder>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserCateringOrdersProviderElement
    extends AutoDisposeStreamProviderElement<List<model.CateringOrder>>
    with UserCateringOrdersRef {
  _UserCateringOrdersProviderElement(super.provider);

  @override
  String get userId => (origin as UserCateringOrdersProvider).userId;
}

String _$cateringOrderStreamHash() =>
    r'a0cd65061ced34a880247f21fb334d649d5693dc';

/// See also [cateringOrderStream].
@ProviderFor(cateringOrderStream)
const cateringOrderStreamProvider = CateringOrderStreamFamily();

/// See also [cateringOrderStream].
class CateringOrderStreamFamily
    extends Family<AsyncValue<model.CateringOrder>> {
  /// See also [cateringOrderStream].
  const CateringOrderStreamFamily();

  /// See also [cateringOrderStream].
  CateringOrderStreamProvider call(
    String orderId,
  ) {
    return CateringOrderStreamProvider(
      orderId,
    );
  }

  @override
  CateringOrderStreamProvider getProviderOverride(
    covariant CateringOrderStreamProvider provider,
  ) {
    return call(
      provider.orderId,
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
  String? get name => r'cateringOrderStreamProvider';
}

/// See also [cateringOrderStream].
class CateringOrderStreamProvider
    extends AutoDisposeStreamProvider<model.CateringOrder> {
  /// See also [cateringOrderStream].
  CateringOrderStreamProvider(
    String orderId,
  ) : this._internal(
          (ref) => cateringOrderStream(
            ref as CateringOrderStreamRef,
            orderId,
          ),
          from: cateringOrderStreamProvider,
          name: r'cateringOrderStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cateringOrderStreamHash,
          dependencies: CateringOrderStreamFamily._dependencies,
          allTransitiveDependencies:
              CateringOrderStreamFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  CateringOrderStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    Stream<model.CateringOrder> Function(CateringOrderStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CateringOrderStreamProvider._internal(
        (ref) => create(ref as CateringOrderStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<model.CateringOrder> createElement() {
    return _CateringOrderStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CateringOrderStreamProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CateringOrderStreamRef
    on AutoDisposeStreamProviderRef<model.CateringOrder> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _CateringOrderStreamProviderElement
    extends AutoDisposeStreamProviderElement<model.CateringOrder>
    with CateringOrderStreamRef {
  _CateringOrderStreamProviderElement(super.provider);

  @override
  String get orderId => (origin as CateringOrderStreamProvider).orderId;
}

String _$cateringOrderStatisticsHash() =>
    r'd9d0f58ae49acdeeb474a2f502d699cd621c48ac';

/// See also [cateringOrderStatistics].
@ProviderFor(cateringOrderStatistics)
final cateringOrderStatisticsProvider =
    AutoDisposeFutureProvider<model.CateringOrder>.internal(
  cateringOrderStatistics,
  name: r'cateringOrderStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringOrderStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CateringOrderStatisticsRef
    = AutoDisposeFutureProviderRef<model.CateringOrder>;
String _$cateringDashboardSummaryHash() =>
    r'9f156aeeb992bd432546331a32baabd22ee63a36';

/// See also [cateringDashboardSummary].
@ProviderFor(cateringDashboardSummary)
final cateringDashboardSummaryProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  cateringDashboardSummary,
  name: r'cateringDashboardSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringDashboardSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CateringDashboardSummaryRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$cateringOrderNotifierHash() =>
    r'79757a46c7b4087c07dcb76b31cbe0644ae1ead3';

/// See also [CateringOrderNotifier].
@ProviderFor(CateringOrderNotifier)
final cateringOrderNotifierProvider =
    NotifierProvider<CateringOrderNotifier, model.CateringOrderItem?>.internal(
  CateringOrderNotifier.new,
  name: r'cateringOrderNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cateringOrderNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CateringOrderNotifier = Notifier<model.CateringOrderItem?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
