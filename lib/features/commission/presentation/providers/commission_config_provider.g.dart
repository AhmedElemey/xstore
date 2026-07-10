// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commissionRateForCategoryHash() =>
    r'bba1fbead9f95a19d0a5bc8414ea47a81d726fbd';

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

/// See also [commissionRateForCategory].
@ProviderFor(commissionRateForCategory)
const commissionRateForCategoryProvider = CommissionRateForCategoryFamily();

/// See also [commissionRateForCategory].
class CommissionRateForCategoryFamily extends Family<double> {
  /// See also [commissionRateForCategory].
  const CommissionRateForCategoryFamily();

  /// See also [commissionRateForCategory].
  CommissionRateForCategoryProvider call(
    int? categoryId,
  ) {
    return CommissionRateForCategoryProvider(
      categoryId,
    );
  }

  @override
  CommissionRateForCategoryProvider getProviderOverride(
    covariant CommissionRateForCategoryProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'commissionRateForCategoryProvider';
}

/// See also [commissionRateForCategory].
class CommissionRateForCategoryProvider extends AutoDisposeProvider<double> {
  /// See also [commissionRateForCategory].
  CommissionRateForCategoryProvider(
    int? categoryId,
  ) : this._internal(
          (ref) => commissionRateForCategory(
            ref as CommissionRateForCategoryRef,
            categoryId,
          ),
          from: commissionRateForCategoryProvider,
          name: r'commissionRateForCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commissionRateForCategoryHash,
          dependencies: CommissionRateForCategoryFamily._dependencies,
          allTransitiveDependencies:
              CommissionRateForCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CommissionRateForCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int? categoryId;

  @override
  Override overrideWith(
    double Function(CommissionRateForCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommissionRateForCategoryProvider._internal(
        (ref) => create(ref as CommissionRateForCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _CommissionRateForCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommissionRateForCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CommissionRateForCategoryRef on AutoDisposeProviderRef<double> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _CommissionRateForCategoryProviderElement
    extends AutoDisposeProviderElement<double>
    with CommissionRateForCategoryRef {
  _CommissionRateForCategoryProviderElement(super.provider);

  @override
  int? get categoryId =>
      (origin as CommissionRateForCategoryProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
