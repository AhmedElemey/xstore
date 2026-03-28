// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDetailHash() => r'15b77b41a72205cbc0d627596b01821710e95c08';

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

abstract class _$ProductDetail
    extends BuildlessAutoDisposeAsyncNotifier<ProductDetailState> {
  late final String listingId;

  FutureOr<ProductDetailState> build(
    String listingId,
  );
}

/// See also [ProductDetail].
@ProviderFor(ProductDetail)
const productDetailProvider = ProductDetailFamily();

/// See also [ProductDetail].
class ProductDetailFamily extends Family<AsyncValue<ProductDetailState>> {
  /// See also [ProductDetail].
  const ProductDetailFamily();

  /// See also [ProductDetail].
  ProductDetailProvider call(
    String listingId,
  ) {
    return ProductDetailProvider(
      listingId,
    );
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(
      provider.listingId,
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
  String? get name => r'productDetailProvider';
}

/// See also [ProductDetail].
class ProductDetailProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProductDetail, ProductDetailState> {
  /// See also [ProductDetail].
  ProductDetailProvider(
    String listingId,
  ) : this._internal(
          () => ProductDetail()..listingId = listingId,
          from: productDetailProvider,
          name: r'productDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productDetailHash,
          dependencies: ProductDetailFamily._dependencies,
          allTransitiveDependencies:
              ProductDetailFamily._allTransitiveDependencies,
          listingId: listingId,
        );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listingId,
  }) : super.internal();

  final String listingId;

  @override
  FutureOr<ProductDetailState> runNotifierBuild(
    covariant ProductDetail notifier,
  ) {
    return notifier.build(
      listingId,
    );
  }

  @override
  Override overrideWith(ProductDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        () => create()..listingId = listingId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listingId: listingId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductDetail, ProductDetailState>
      createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.listingId == listingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductDetailRef
    on AutoDisposeAsyncNotifierProviderRef<ProductDetailState> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ProductDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductDetail,
        ProductDetailState> with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  String get listingId => (origin as ProductDetailProvider).listingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
