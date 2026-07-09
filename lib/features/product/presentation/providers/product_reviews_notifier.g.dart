// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_reviews_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productReviewsNotifierHash() =>
    r'b6280562140920f963935faab1f523915e5fe5af';

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

abstract class _$ProductReviewsNotifier
    extends BuildlessAutoDisposeNotifier<ProductReviewsState> {
  late final String listingId;

  ProductReviewsState build(
    String listingId,
  );
}

/// See also [ProductReviewsNotifier].
@ProviderFor(ProductReviewsNotifier)
const productReviewsNotifierProvider = ProductReviewsNotifierFamily();

/// See also [ProductReviewsNotifier].
class ProductReviewsNotifierFamily extends Family<ProductReviewsState> {
  /// See also [ProductReviewsNotifier].
  const ProductReviewsNotifierFamily();

  /// See also [ProductReviewsNotifier].
  ProductReviewsNotifierProvider call(
    String listingId,
  ) {
    return ProductReviewsNotifierProvider(
      listingId,
    );
  }

  @override
  ProductReviewsNotifierProvider getProviderOverride(
    covariant ProductReviewsNotifierProvider provider,
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
  String? get name => r'productReviewsNotifierProvider';
}

/// See also [ProductReviewsNotifier].
class ProductReviewsNotifierProvider extends AutoDisposeNotifierProviderImpl<
    ProductReviewsNotifier, ProductReviewsState> {
  /// See also [ProductReviewsNotifier].
  ProductReviewsNotifierProvider(
    String listingId,
  ) : this._internal(
          () => ProductReviewsNotifier()..listingId = listingId,
          from: productReviewsNotifierProvider,
          name: r'productReviewsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productReviewsNotifierHash,
          dependencies: ProductReviewsNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProductReviewsNotifierFamily._allTransitiveDependencies,
          listingId: listingId,
        );

  ProductReviewsNotifierProvider._internal(
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
  ProductReviewsState runNotifierBuild(
    covariant ProductReviewsNotifier notifier,
  ) {
    return notifier.build(
      listingId,
    );
  }

  @override
  Override overrideWith(ProductReviewsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductReviewsNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<ProductReviewsNotifier,
      ProductReviewsState> createElement() {
    return _ProductReviewsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductReviewsNotifierProvider &&
        other.listingId == listingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProductReviewsNotifierRef
    on AutoDisposeNotifierProviderRef<ProductReviewsState> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ProductReviewsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ProductReviewsNotifier,
        ProductReviewsState> with ProductReviewsNotifierRef {
  _ProductReviewsNotifierProviderElement(super.provider);

  @override
  String get listingId => (origin as ProductReviewsNotifierProvider).listingId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
