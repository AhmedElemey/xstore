// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vendorCommissionSnapshotHash() =>
    r'92d2187fa1746041ac162aabd2729351e4c6b5a3';

/// The vendor's commission fee + wallet-alert flags.
///
/// The admin-configured source of truth is `SystemSetting`
/// (`commissionValueOnOrder`/`warnThresholdEgp`/`pauseThresholdEgp`) and
/// the vendor's own `VendorCommissionWallet` row — but both are only
/// exposed through `PUT/GET /api/admin/system-settings` and
/// `PUT /api/users/{id}/commission/settle`, which are
/// `[Authorize(Roles = "ADMINISTRATOR, SUPERADMIN")]` (confirmed against
/// backend source 2026-08-15) — a vendor session cannot call either. The
/// only vendor-accessible echo of these values is the
/// `GET /api/vendor/orders` envelope (`OrderStatsEntity`), so this reuses
/// the existing vendor-order-stats fetch rather than adding a dead-on-arrival
/// call to the admin routes. Plain autoDispose (not cached) — the
/// exceeds-threshold flags can change mid-session (e.g. a new delivered
/// order pushes the vendor over the pause limit) and gate listing
/// publishing, so staleness here is a correctness risk, not just a UX one.
///
/// Copied from [vendorCommissionSnapshot].
@ProviderFor(vendorCommissionSnapshot)
final vendorCommissionSnapshotProvider =
    AutoDisposeFutureProvider<OrderStatsEntity?>.internal(
  vendorCommissionSnapshot,
  name: r'vendorCommissionSnapshotProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vendorCommissionSnapshotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VendorCommissionSnapshotRef
    = AutoDisposeFutureProviderRef<OrderStatsEntity?>;
String _$commissionFeeEgpForCategoryHash() =>
    r'6181922e16ad90070037b84e4961f464bec7e8a7';

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

/// See also [commissionFeeEgpForCategory].
@ProviderFor(commissionFeeEgpForCategory)
const commissionFeeEgpForCategoryProvider = CommissionFeeEgpForCategoryFamily();

/// See also [commissionFeeEgpForCategory].
class CommissionFeeEgpForCategoryFamily extends Family<double> {
  /// See also [commissionFeeEgpForCategory].
  const CommissionFeeEgpForCategoryFamily();

  /// See also [commissionFeeEgpForCategory].
  CommissionFeeEgpForCategoryProvider call(
    int? categoryId,
  ) {
    return CommissionFeeEgpForCategoryProvider(
      categoryId,
    );
  }

  @override
  CommissionFeeEgpForCategoryProvider getProviderOverride(
    covariant CommissionFeeEgpForCategoryProvider provider,
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
  String? get name => r'commissionFeeEgpForCategoryProvider';
}

/// See also [commissionFeeEgpForCategory].
class CommissionFeeEgpForCategoryProvider extends AutoDisposeProvider<double> {
  /// See also [commissionFeeEgpForCategory].
  CommissionFeeEgpForCategoryProvider(
    int? categoryId,
  ) : this._internal(
          (ref) => commissionFeeEgpForCategory(
            ref as CommissionFeeEgpForCategoryRef,
            categoryId,
          ),
          from: commissionFeeEgpForCategoryProvider,
          name: r'commissionFeeEgpForCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commissionFeeEgpForCategoryHash,
          dependencies: CommissionFeeEgpForCategoryFamily._dependencies,
          allTransitiveDependencies:
              CommissionFeeEgpForCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CommissionFeeEgpForCategoryProvider._internal(
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
    double Function(CommissionFeeEgpForCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommissionFeeEgpForCategoryProvider._internal(
        (ref) => create(ref as CommissionFeeEgpForCategoryRef),
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
    return _CommissionFeeEgpForCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommissionFeeEgpForCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CommissionFeeEgpForCategoryRef on AutoDisposeProviderRef<double> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _CommissionFeeEgpForCategoryProviderElement
    extends AutoDisposeProviderElement<double>
    with CommissionFeeEgpForCategoryRef {
  _CommissionFeeEgpForCategoryProviderElement(super.provider);

  @override
  int? get categoryId =>
      (origin as CommissionFeeEgpForCategoryProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
