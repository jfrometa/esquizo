// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$validationHash() => r'edb74e13de33c2f00328c6725bb5f9375469bc28';

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

abstract class _$Validation
    extends BuildlessAutoDisposeNotifier<Map<String, bool>> {
  late final String type;

  Map<String, bool> build(
    String type,
  );
}

/// See also [Validation].
@ProviderFor(Validation)
const validationProvider = ValidationFamily();

/// See also [Validation].
class ValidationFamily extends Family<Map<String, bool>> {
  /// See also [Validation].
  const ValidationFamily();

  /// See also [Validation].
  ValidationProvider call(
    String type,
  ) {
    return ValidationProvider(
      type,
    );
  }

  @override
  ValidationProvider getProviderOverride(
    covariant ValidationProvider provider,
  ) {
    return call(
      provider.type,
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
  String? get name => r'validationProvider';
}

/// See also [Validation].
class ValidationProvider
    extends AutoDisposeNotifierProviderImpl<Validation, Map<String, bool>> {
  /// See also [Validation].
  ValidationProvider(
    String type,
  ) : this._internal(
          () => Validation()..type = type,
          from: validationProvider,
          name: r'validationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$validationHash,
          dependencies: ValidationFamily._dependencies,
          allTransitiveDependencies:
              ValidationFamily._allTransitiveDependencies,
          type: type,
        );

  ValidationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String type;

  @override
  Map<String, bool> runNotifierBuild(
    covariant Validation notifier,
  ) {
    return notifier.build(
      type,
    );
  }

  @override
  Override overrideWith(Validation Function() create) {
    return ProviderOverride(
      origin: this,
      override: ValidationProvider._internal(
        () => create()..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<Validation, Map<String, bool>>
      createElement() {
    return _ValidationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ValidationProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ValidationRef on AutoDisposeNotifierProviderRef<Map<String, bool>> {
  /// The parameter `type` of this provider.
  String get type;
}

class _ValidationProviderElement
    extends AutoDisposeNotifierProviderElement<Validation, Map<String, bool>>
    with ValidationRef {
  _ValidationProviderElement(super.provider);

  @override
  String get type => (origin as ValidationProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
