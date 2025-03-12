// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialize_example_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initializeExampleDataHash() =>
    r'48a598b196c3edd39235d5b7dbff6776fb9a37bb';

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

abstract class _$InitializeExampleData
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final String businessId;
  late final String businessType;
  late final String adminEmail;

  FutureOr<void> build({
    required String businessId,
    required String businessType,
    required String adminEmail,
  });
}

/// Provider to initialize example data for a business
///
/// This provider will create sample data based on the business type.
/// It requires a businessId, businessType, and adminEmail to function.
///
/// Copied from [InitializeExampleData].
@ProviderFor(InitializeExampleData)
const initializeExampleDataProvider = InitializeExampleDataFamily();

/// Provider to initialize example data for a business
///
/// This provider will create sample data based on the business type.
/// It requires a businessId, businessType, and adminEmail to function.
///
/// Copied from [InitializeExampleData].
class InitializeExampleDataFamily extends Family<AsyncValue<void>> {
  /// Provider to initialize example data for a business
  ///
  /// This provider will create sample data based on the business type.
  /// It requires a businessId, businessType, and adminEmail to function.
  ///
  /// Copied from [InitializeExampleData].
  const InitializeExampleDataFamily();

  /// Provider to initialize example data for a business
  ///
  /// This provider will create sample data based on the business type.
  /// It requires a businessId, businessType, and adminEmail to function.
  ///
  /// Copied from [InitializeExampleData].
  InitializeExampleDataProvider call({
    required String businessId,
    required String businessType,
    required String adminEmail,
  }) {
    return InitializeExampleDataProvider(
      businessId: businessId,
      businessType: businessType,
      adminEmail: adminEmail,
    );
  }

  @override
  InitializeExampleDataProvider getProviderOverride(
    covariant InitializeExampleDataProvider provider,
  ) {
    return call(
      businessId: provider.businessId,
      businessType: provider.businessType,
      adminEmail: provider.adminEmail,
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
  String? get name => r'initializeExampleDataProvider';
}

/// Provider to initialize example data for a business
///
/// This provider will create sample data based on the business type.
/// It requires a businessId, businessType, and adminEmail to function.
///
/// Copied from [InitializeExampleData].
class InitializeExampleDataProvider
    extends AutoDisposeAsyncNotifierProviderImpl<InitializeExampleData, void> {
  /// Provider to initialize example data for a business
  ///
  /// This provider will create sample data based on the business type.
  /// It requires a businessId, businessType, and adminEmail to function.
  ///
  /// Copied from [InitializeExampleData].
  InitializeExampleDataProvider({
    required String businessId,
    required String businessType,
    required String adminEmail,
  }) : this._internal(
          () => InitializeExampleData()
            ..businessId = businessId
            ..businessType = businessType
            ..adminEmail = adminEmail,
          from: initializeExampleDataProvider,
          name: r'initializeExampleDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$initializeExampleDataHash,
          dependencies: InitializeExampleDataFamily._dependencies,
          allTransitiveDependencies:
              InitializeExampleDataFamily._allTransitiveDependencies,
          businessId: businessId,
          businessType: businessType,
          adminEmail: adminEmail,
        );

  InitializeExampleDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.businessId,
    required this.businessType,
    required this.adminEmail,
  }) : super.internal();

  final String businessId;
  final String businessType;
  final String adminEmail;

  @override
  FutureOr<void> runNotifierBuild(
    covariant InitializeExampleData notifier,
  ) {
    return notifier.build(
      businessId: businessId,
      businessType: businessType,
      adminEmail: adminEmail,
    );
  }

  @override
  Override overrideWith(InitializeExampleData Function() create) {
    return ProviderOverride(
      origin: this,
      override: InitializeExampleDataProvider._internal(
        () => create()
          ..businessId = businessId
          ..businessType = businessType
          ..adminEmail = adminEmail,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        businessId: businessId,
        businessType: businessType,
        adminEmail: adminEmail,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InitializeExampleData, void>
      createElement() {
    return _InitializeExampleDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InitializeExampleDataProvider &&
        other.businessId == businessId &&
        other.businessType == businessType &&
        other.adminEmail == adminEmail;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, businessId.hashCode);
    hash = _SystemHash.combine(hash, businessType.hashCode);
    hash = _SystemHash.combine(hash, adminEmail.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InitializeExampleDataRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `businessId` of this provider.
  String get businessId;

  /// The parameter `businessType` of this provider.
  String get businessType;

  /// The parameter `adminEmail` of this provider.
  String get adminEmail;
}

class _InitializeExampleDataProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InitializeExampleData, void>
    with InitializeExampleDataRef {
  _InitializeExampleDataProviderElement(super.provider);

  @override
  String get businessId => (origin as InitializeExampleDataProvider).businessId;
  @override
  String get businessType =>
      (origin as InitializeExampleDataProvider).businessType;
  @override
  String get adminEmail => (origin as InitializeExampleDataProvider).adminEmail;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
