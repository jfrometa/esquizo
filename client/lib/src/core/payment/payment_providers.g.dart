// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentServiceHash() => r'd5af472fb934828c6a9fec67ec1668f08759a33a';

/// See also [paymentService].
@ProviderFor(paymentService)
final paymentServiceProvider = Provider<PaymentService>.internal(
  paymentService,
  name: r'paymentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentServiceRef = ProviderRef<PaymentService>;
String _$paymentStatisticsHash() => r'226dd39b116d580b6f89a0d1c32feaf7f6ffb9a3';

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

/// Payment statistics provider
///
/// Copied from [paymentStatistics].
@ProviderFor(paymentStatistics)
const paymentStatisticsProvider = PaymentStatisticsFamily();

/// Payment statistics provider
///
/// Copied from [paymentStatistics].
class PaymentStatisticsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Payment statistics provider
  ///
  /// Copied from [paymentStatistics].
  const PaymentStatisticsFamily();

  /// Payment statistics provider
  ///
  /// Copied from [paymentStatistics].
  PaymentStatisticsProvider call(
    ({DateTime endDate, DateTime startDate}) params,
  ) {
    return PaymentStatisticsProvider(
      params,
    );
  }

  @override
  PaymentStatisticsProvider getProviderOverride(
    covariant PaymentStatisticsProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'paymentStatisticsProvider';
}

/// Payment statistics provider
///
/// Copied from [paymentStatistics].
class PaymentStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Payment statistics provider
  ///
  /// Copied from [paymentStatistics].
  PaymentStatisticsProvider(
    ({DateTime endDate, DateTime startDate}) params,
  ) : this._internal(
          (ref) => paymentStatistics(
            ref as PaymentStatisticsRef,
            params,
          ),
          from: paymentStatisticsProvider,
          name: r'paymentStatisticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentStatisticsHash,
          dependencies: PaymentStatisticsFamily._dependencies,
          allTransitiveDependencies:
              PaymentStatisticsFamily._allTransitiveDependencies,
          params: params,
        );

  PaymentStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({DateTime endDate, DateTime startDate}) params;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(PaymentStatisticsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentStatisticsProvider._internal(
        (ref) => create(ref as PaymentStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _PaymentStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentStatisticsProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `params` of this provider.
  ({DateTime endDate, DateTime startDate}) get params;
}

class _PaymentStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with PaymentStatisticsRef {
  _PaymentStatisticsProviderElement(super.provider);

  @override
  ({DateTime endDate, DateTime startDate}) get params =>
      (origin as PaymentStatisticsProvider).params;
}

String _$serviceStatisticsHash() => r'83550f99bb6cb6292b25fe0a7b182335ceaebc2e';

/// Service statistics provider
///
/// Copied from [serviceStatistics].
@ProviderFor(serviceStatistics)
const serviceStatisticsProvider = ServiceStatisticsFamily();

/// Service statistics provider
///
/// Copied from [serviceStatistics].
class ServiceStatisticsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Service statistics provider
  ///
  /// Copied from [serviceStatistics].
  const ServiceStatisticsFamily();

  /// Service statistics provider
  ///
  /// Copied from [serviceStatistics].
  ServiceStatisticsProvider call(
    ({DateTime endDate, DateTime startDate}) params,
  ) {
    return ServiceStatisticsProvider(
      params,
    );
  }

  @override
  ServiceStatisticsProvider getProviderOverride(
    covariant ServiceStatisticsProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'serviceStatisticsProvider';
}

/// Service statistics provider
///
/// Copied from [serviceStatistics].
class ServiceStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Service statistics provider
  ///
  /// Copied from [serviceStatistics].
  ServiceStatisticsProvider(
    ({DateTime endDate, DateTime startDate}) params,
  ) : this._internal(
          (ref) => serviceStatistics(
            ref as ServiceStatisticsRef,
            params,
          ),
          from: serviceStatisticsProvider,
          name: r'serviceStatisticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$serviceStatisticsHash,
          dependencies: ServiceStatisticsFamily._dependencies,
          allTransitiveDependencies:
              ServiceStatisticsFamily._allTransitiveDependencies,
          params: params,
        );

  ServiceStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({DateTime endDate, DateTime startDate}) params;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ServiceStatisticsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServiceStatisticsProvider._internal(
        (ref) => create(ref as ServiceStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ServiceStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceStatisticsProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServiceStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `params` of this provider.
  ({DateTime endDate, DateTime startDate}) get params;
}

class _ServiceStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ServiceStatisticsRef {
  _ServiceStatisticsProviderElement(super.provider);

  @override
  ({DateTime endDate, DateTime startDate}) get params =>
      (origin as ServiceStatisticsProvider).params;
}

String _$pendingReimbursementsHash() =>
    r'777c7a416e302cb4f3e043800529a368fc37d50d';

/// Provider for pending reimbursements
///
/// Copied from [pendingReimbursements].
@ProviderFor(pendingReimbursements)
final pendingReimbursementsProvider =
    AutoDisposeStreamProvider<List<Reimbursement>>.internal(
  pendingReimbursements,
  name: r'pendingReimbursementsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingReimbursementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingReimbursementsRef
    = AutoDisposeStreamProviderRef<List<Reimbursement>>;
String _$taxConfigurationsHash() => r'9c31976fe3b6e701786204938df8646313a9439c';

/// Provider for tax configurations
///
/// Copied from [taxConfigurations].
@ProviderFor(taxConfigurations)
final taxConfigurationsProvider =
    AutoDisposeStreamProvider<List<TaxConfiguration>>.internal(
  taxConfigurations,
  name: r'taxConfigurationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taxConfigurationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaxConfigurationsRef
    = AutoDisposeStreamProviderRef<List<TaxConfiguration>>;
String _$staffTipDistributionsHash() =>
    r'87f70487363e8ef145b0d0a9dcb7df3db3ac4dd8';

/// Provider for staff tip distributions
///
/// Copied from [staffTipDistributions].
@ProviderFor(staffTipDistributions)
const staffTipDistributionsProvider = StaffTipDistributionsFamily();

/// Provider for staff tip distributions
///
/// Copied from [staffTipDistributions].
class StaffTipDistributionsFamily
    extends Family<AsyncValue<List<TipDistribution>>> {
  /// Provider for staff tip distributions
  ///
  /// Copied from [staffTipDistributions].
  const StaffTipDistributionsFamily();

  /// Provider for staff tip distributions
  ///
  /// Copied from [staffTipDistributions].
  StaffTipDistributionsProvider call(
    ({DateTime endDate, String staffId, DateTime startDate}) params,
  ) {
    return StaffTipDistributionsProvider(
      params,
    );
  }

  @override
  StaffTipDistributionsProvider getProviderOverride(
    covariant StaffTipDistributionsProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'staffTipDistributionsProvider';
}

/// Provider for staff tip distributions
///
/// Copied from [staffTipDistributions].
class StaffTipDistributionsProvider
    extends AutoDisposeFutureProvider<List<TipDistribution>> {
  /// Provider for staff tip distributions
  ///
  /// Copied from [staffTipDistributions].
  StaffTipDistributionsProvider(
    ({DateTime endDate, String staffId, DateTime startDate}) params,
  ) : this._internal(
          (ref) => staffTipDistributions(
            ref as StaffTipDistributionsRef,
            params,
          ),
          from: staffTipDistributionsProvider,
          name: r'staffTipDistributionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$staffTipDistributionsHash,
          dependencies: StaffTipDistributionsFamily._dependencies,
          allTransitiveDependencies:
              StaffTipDistributionsFamily._allTransitiveDependencies,
          params: params,
        );

  StaffTipDistributionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({DateTime endDate, String staffId, DateTime startDate}) params;

  @override
  Override overrideWith(
    FutureOr<List<TipDistribution>> Function(StaffTipDistributionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StaffTipDistributionsProvider._internal(
        (ref) => create(ref as StaffTipDistributionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TipDistribution>> createElement() {
    return _StaffTipDistributionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffTipDistributionsProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StaffTipDistributionsRef
    on AutoDisposeFutureProviderRef<List<TipDistribution>> {
  /// The parameter `params` of this provider.
  ({DateTime endDate, String staffId, DateTime startDate}) get params;
}

class _StaffTipDistributionsProviderElement
    extends AutoDisposeFutureProviderElement<List<TipDistribution>>
    with StaffTipDistributionsRef {
  _StaffTipDistributionsProviderElement(super.provider);

  @override
  ({DateTime endDate, String staffId, DateTime startDate}) get params =>
      (origin as StaffTipDistributionsProvider).params;
}

String _$paymentByOrderIdHash() => r'2efad8a54c1abc866e2a2f42d7eeacb7e8239948';

/// Provider for payment by order ID
///
/// Copied from [paymentByOrderId].
@ProviderFor(paymentByOrderId)
const paymentByOrderIdProvider = PaymentByOrderIdFamily();

/// Provider for payment by order ID
///
/// Copied from [paymentByOrderId].
class PaymentByOrderIdFamily extends Family<AsyncValue<Payment?>> {
  /// Provider for payment by order ID
  ///
  /// Copied from [paymentByOrderId].
  const PaymentByOrderIdFamily();

  /// Provider for payment by order ID
  ///
  /// Copied from [paymentByOrderId].
  PaymentByOrderIdProvider call(
    String orderId,
  ) {
    return PaymentByOrderIdProvider(
      orderId,
    );
  }

  @override
  PaymentByOrderIdProvider getProviderOverride(
    covariant PaymentByOrderIdProvider provider,
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
  String? get name => r'paymentByOrderIdProvider';
}

/// Provider for payment by order ID
///
/// Copied from [paymentByOrderId].
class PaymentByOrderIdProvider extends AutoDisposeFutureProvider<Payment?> {
  /// Provider for payment by order ID
  ///
  /// Copied from [paymentByOrderId].
  PaymentByOrderIdProvider(
    String orderId,
  ) : this._internal(
          (ref) => paymentByOrderId(
            ref as PaymentByOrderIdRef,
            orderId,
          ),
          from: paymentByOrderIdProvider,
          name: r'paymentByOrderIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentByOrderIdHash,
          dependencies: PaymentByOrderIdFamily._dependencies,
          allTransitiveDependencies:
              PaymentByOrderIdFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  PaymentByOrderIdProvider._internal(
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
    FutureOr<Payment?> Function(PaymentByOrderIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentByOrderIdProvider._internal(
        (ref) => create(ref as PaymentByOrderIdRef),
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
  AutoDisposeFutureProviderElement<Payment?> createElement() {
    return _PaymentByOrderIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentByOrderIdProvider && other.orderId == orderId;
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
mixin PaymentByOrderIdRef on AutoDisposeFutureProviderRef<Payment?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _PaymentByOrderIdProviderElement
    extends AutoDisposeFutureProviderElement<Payment?>
    with PaymentByOrderIdRef {
  _PaymentByOrderIdProviderElement(super.provider);

  @override
  String get orderId => (origin as PaymentByOrderIdProvider).orderId;
}

String _$activeTablesHash() => r'68fddb097633c1b8292f26bdedf94c71e8143d28';

/// Provider for active tables (mock for now)
///
/// Copied from [activeTables].
@ProviderFor(activeTables)
final activeTablesProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
  activeTables,
  name: r'activeTablesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeTablesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTablesRef
    = AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$dailyServiceSummaryHash() =>
    r'e7e74b01a3c06010665f4f13b209fad31abcd5b9';

/// Provider for daily service summary
///
/// Copied from [dailyServiceSummary].
@ProviderFor(dailyServiceSummary)
final dailyServiceSummaryProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  dailyServiceSummary,
  name: r'dailyServiceSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyServiceSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyServiceSummaryRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$serverPerformanceHash() => r'ffe327c1f45b95b038b6a67a6a5f84b83839604b';

/// Provider for server performance metrics
///
/// Copied from [serverPerformance].
@ProviderFor(serverPerformance)
const serverPerformanceProvider = ServerPerformanceFamily();

/// Provider for server performance metrics
///
/// Copied from [serverPerformance].
class ServerPerformanceFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for server performance metrics
  ///
  /// Copied from [serverPerformance].
  const ServerPerformanceFamily();

  /// Provider for server performance metrics
  ///
  /// Copied from [serverPerformance].
  ServerPerformanceProvider call(
    ({DateTime endDate, String serverId, DateTime startDate}) params,
  ) {
    return ServerPerformanceProvider(
      params,
    );
  }

  @override
  ServerPerformanceProvider getProviderOverride(
    covariant ServerPerformanceProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'serverPerformanceProvider';
}

/// Provider for server performance metrics
///
/// Copied from [serverPerformance].
class ServerPerformanceProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for server performance metrics
  ///
  /// Copied from [serverPerformance].
  ServerPerformanceProvider(
    ({DateTime endDate, String serverId, DateTime startDate}) params,
  ) : this._internal(
          (ref) => serverPerformance(
            ref as ServerPerformanceRef,
            params,
          ),
          from: serverPerformanceProvider,
          name: r'serverPerformanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$serverPerformanceHash,
          dependencies: ServerPerformanceFamily._dependencies,
          allTransitiveDependencies:
              ServerPerformanceFamily._allTransitiveDependencies,
          params: params,
        );

  ServerPerformanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({DateTime endDate, String serverId, DateTime startDate}) params;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ServerPerformanceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServerPerformanceProvider._internal(
        (ref) => create(ref as ServerPerformanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ServerPerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerPerformanceProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServerPerformanceRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `params` of this provider.
  ({DateTime endDate, String serverId, DateTime startDate}) get params;
}

class _ServerPerformanceProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ServerPerformanceRef {
  _ServerPerformanceProviderElement(super.provider);

  @override
  ({DateTime endDate, String serverId, DateTime startDate}) get params =>
      (origin as ServerPerformanceProvider).params;
}

String _$paymentProcessorHash() => r'5740eac321d89229ba4ff86823842f080722ff1c';

/// Provider for managing payment processing
///
/// Copied from [PaymentProcessor].
@ProviderFor(PaymentProcessor)
final paymentProcessorProvider =
    NotifierProvider<PaymentProcessor, AsyncValue<Payment?>>.internal(
  PaymentProcessor.new,
  name: r'paymentProcessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentProcessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaymentProcessor = Notifier<AsyncValue<Payment?>>;
String _$reimbursementManagerHash() =>
    r'a42fc47bbf70b148b952bd051feaea73eafa6f39';

/// Provider for managing reimbursements
///
/// Copied from [ReimbursementManager].
@ProviderFor(ReimbursementManager)
final reimbursementManagerProvider = NotifierProvider<ReimbursementManager,
    AsyncValue<List<Reimbursement>>>.internal(
  ReimbursementManager.new,
  name: r'reimbursementManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reimbursementManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReimbursementManager = Notifier<AsyncValue<List<Reimbursement>>>;
String _$couponValidatorHash() => r'320d1b978e4f0fc743699802960882ef8a43f0c1';

/// Provider for coupon validation
///
/// Copied from [CouponValidator].
@ProviderFor(CouponValidator)
final couponValidatorProvider = AutoDisposeNotifierProvider<CouponValidator,
    AsyncValue<Discount?>>.internal(
  CouponValidator.new,
  name: r'couponValidatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$couponValidatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CouponValidator = AutoDisposeNotifier<AsyncValue<Discount?>>;
String _$appliedDiscountsHash() => r'd63af3d18fe3a13cb6a538a3c2e8685e3129557e';

/// Provider for managing applied discounts
///
/// Copied from [AppliedDiscounts].
@ProviderFor(AppliedDiscounts)
final appliedDiscountsProvider =
    NotifierProvider<AppliedDiscounts, List<Discount>>.internal(
  AppliedDiscounts.new,
  name: r'appliedDiscountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appliedDiscountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppliedDiscounts = Notifier<List<Discount>>;
String _$tipDistributionManagerHash() =>
    r'a5989d3e82132c33a85bf0f03da38b937f0f8fea';

/// Provider for managing tip distribution
///
/// Copied from [TipDistributionManager].
@ProviderFor(TipDistributionManager)
final tipDistributionManagerProvider = NotifierProvider<TipDistributionManager,
    AsyncValue<TipDistribution?>>.internal(
  TipDistributionManager.new,
  name: r'tipDistributionManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tipDistributionManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TipDistributionManager = Notifier<AsyncValue<TipDistribution?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
