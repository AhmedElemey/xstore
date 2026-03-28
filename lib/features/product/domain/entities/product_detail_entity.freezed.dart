// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_detail_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductDetailEntity {
  ListingEntity get listing => throw _privateConstructorUsedError;
  double? get compareAtPrice => throw _privateConstructorUsedError;
  int get stockQuantity => throw _privateConstructorUsedError;
  String get locationLine => throw _privateConstructorUsedError;
  ProductSellerEntity? get seller => throw _privateConstructorUsedError;
  Map<String, String> get specifications => throw _privateConstructorUsedError;
  ReviewSummaryEntity? get reviewSummary => throw _privateConstructorUsedError;
  List<ProductReviewEntity> get reviews => throw _privateConstructorUsedError;
  List<DealEntity> get similarProducts => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProductDetailEntityCopyWith<ProductDetailEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductDetailEntityCopyWith<$Res> {
  factory $ProductDetailEntityCopyWith(
          ProductDetailEntity value, $Res Function(ProductDetailEntity) then) =
      _$ProductDetailEntityCopyWithImpl<$Res, ProductDetailEntity>;
  @useResult
  $Res call(
      {ListingEntity listing,
      double? compareAtPrice,
      int stockQuantity,
      String locationLine,
      ProductSellerEntity? seller,
      Map<String, String> specifications,
      ReviewSummaryEntity? reviewSummary,
      List<ProductReviewEntity> reviews,
      List<DealEntity> similarProducts});

  $ListingEntityCopyWith<$Res> get listing;
  $ProductSellerEntityCopyWith<$Res>? get seller;
  $ReviewSummaryEntityCopyWith<$Res>? get reviewSummary;
}

/// @nodoc
class _$ProductDetailEntityCopyWithImpl<$Res, $Val extends ProductDetailEntity>
    implements $ProductDetailEntityCopyWith<$Res> {
  _$ProductDetailEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? compareAtPrice = freezed,
    Object? stockQuantity = null,
    Object? locationLine = null,
    Object? seller = freezed,
    Object? specifications = null,
    Object? reviewSummary = freezed,
    Object? reviews = null,
    Object? similarProducts = null,
  }) {
    return _then(_value.copyWith(
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as ListingEntity,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      locationLine: null == locationLine
          ? _value.locationLine
          : locationLine // ignore: cast_nullable_to_non_nullable
              as String,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as ProductSellerEntity?,
      specifications: null == specifications
          ? _value.specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      reviewSummary: freezed == reviewSummary
          ? _value.reviewSummary
          : reviewSummary // ignore: cast_nullable_to_non_nullable
              as ReviewSummaryEntity?,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ProductReviewEntity>,
      similarProducts: null == similarProducts
          ? _value.similarProducts
          : similarProducts // ignore: cast_nullable_to_non_nullable
              as List<DealEntity>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ListingEntityCopyWith<$Res> get listing {
    return $ListingEntityCopyWith<$Res>(_value.listing, (value) {
      return _then(_value.copyWith(listing: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductSellerEntityCopyWith<$Res>? get seller {
    if (_value.seller == null) {
      return null;
    }

    return $ProductSellerEntityCopyWith<$Res>(_value.seller!, (value) {
      return _then(_value.copyWith(seller: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ReviewSummaryEntityCopyWith<$Res>? get reviewSummary {
    if (_value.reviewSummary == null) {
      return null;
    }

    return $ReviewSummaryEntityCopyWith<$Res>(_value.reviewSummary!, (value) {
      return _then(_value.copyWith(reviewSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductDetailEntityImplCopyWith<$Res>
    implements $ProductDetailEntityCopyWith<$Res> {
  factory _$$ProductDetailEntityImplCopyWith(_$ProductDetailEntityImpl value,
          $Res Function(_$ProductDetailEntityImpl) then) =
      __$$ProductDetailEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ListingEntity listing,
      double? compareAtPrice,
      int stockQuantity,
      String locationLine,
      ProductSellerEntity? seller,
      Map<String, String> specifications,
      ReviewSummaryEntity? reviewSummary,
      List<ProductReviewEntity> reviews,
      List<DealEntity> similarProducts});

  @override
  $ListingEntityCopyWith<$Res> get listing;
  @override
  $ProductSellerEntityCopyWith<$Res>? get seller;
  @override
  $ReviewSummaryEntityCopyWith<$Res>? get reviewSummary;
}

/// @nodoc
class __$$ProductDetailEntityImplCopyWithImpl<$Res>
    extends _$ProductDetailEntityCopyWithImpl<$Res, _$ProductDetailEntityImpl>
    implements _$$ProductDetailEntityImplCopyWith<$Res> {
  __$$ProductDetailEntityImplCopyWithImpl(_$ProductDetailEntityImpl _value,
      $Res Function(_$ProductDetailEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? compareAtPrice = freezed,
    Object? stockQuantity = null,
    Object? locationLine = null,
    Object? seller = freezed,
    Object? specifications = null,
    Object? reviewSummary = freezed,
    Object? reviews = null,
    Object? similarProducts = null,
  }) {
    return _then(_$ProductDetailEntityImpl(
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as ListingEntity,
      compareAtPrice: freezed == compareAtPrice
          ? _value.compareAtPrice
          : compareAtPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      locationLine: null == locationLine
          ? _value.locationLine
          : locationLine // ignore: cast_nullable_to_non_nullable
              as String,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as ProductSellerEntity?,
      specifications: null == specifications
          ? _value._specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      reviewSummary: freezed == reviewSummary
          ? _value.reviewSummary
          : reviewSummary // ignore: cast_nullable_to_non_nullable
              as ReviewSummaryEntity?,
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ProductReviewEntity>,
      similarProducts: null == similarProducts
          ? _value._similarProducts
          : similarProducts // ignore: cast_nullable_to_non_nullable
              as List<DealEntity>,
    ));
  }
}

/// @nodoc

class _$ProductDetailEntityImpl implements _ProductDetailEntity {
  const _$ProductDetailEntityImpl(
      {required this.listing,
      this.compareAtPrice,
      this.stockQuantity = 99,
      this.locationLine = '',
      this.seller,
      final Map<String, String> specifications = const {},
      this.reviewSummary,
      final List<ProductReviewEntity> reviews = const <ProductReviewEntity>[],
      final List<DealEntity> similarProducts = const <DealEntity>[]})
      : _specifications = specifications,
        _reviews = reviews,
        _similarProducts = similarProducts;

  @override
  final ListingEntity listing;
  @override
  final double? compareAtPrice;
  @override
  @JsonKey()
  final int stockQuantity;
  @override
  @JsonKey()
  final String locationLine;
  @override
  final ProductSellerEntity? seller;
  final Map<String, String> _specifications;
  @override
  @JsonKey()
  Map<String, String> get specifications {
    if (_specifications is EqualUnmodifiableMapView) return _specifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_specifications);
  }

  @override
  final ReviewSummaryEntity? reviewSummary;
  final List<ProductReviewEntity> _reviews;
  @override
  @JsonKey()
  List<ProductReviewEntity> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  final List<DealEntity> _similarProducts;
  @override
  @JsonKey()
  List<DealEntity> get similarProducts {
    if (_similarProducts is EqualUnmodifiableListView) return _similarProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similarProducts);
  }

  @override
  String toString() {
    return 'ProductDetailEntity(listing: $listing, compareAtPrice: $compareAtPrice, stockQuantity: $stockQuantity, locationLine: $locationLine, seller: $seller, specifications: $specifications, reviewSummary: $reviewSummary, reviews: $reviews, similarProducts: $similarProducts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductDetailEntityImpl &&
            (identical(other.listing, listing) || other.listing == listing) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.locationLine, locationLine) ||
                other.locationLine == locationLine) &&
            (identical(other.seller, seller) || other.seller == seller) &&
            const DeepCollectionEquality()
                .equals(other._specifications, _specifications) &&
            (identical(other.reviewSummary, reviewSummary) ||
                other.reviewSummary == reviewSummary) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            const DeepCollectionEquality()
                .equals(other._similarProducts, _similarProducts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      listing,
      compareAtPrice,
      stockQuantity,
      locationLine,
      seller,
      const DeepCollectionEquality().hash(_specifications),
      reviewSummary,
      const DeepCollectionEquality().hash(_reviews),
      const DeepCollectionEquality().hash(_similarProducts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductDetailEntityImplCopyWith<_$ProductDetailEntityImpl> get copyWith =>
      __$$ProductDetailEntityImplCopyWithImpl<_$ProductDetailEntityImpl>(
          this, _$identity);
}

abstract class _ProductDetailEntity implements ProductDetailEntity {
  const factory _ProductDetailEntity(
      {required final ListingEntity listing,
      final double? compareAtPrice,
      final int stockQuantity,
      final String locationLine,
      final ProductSellerEntity? seller,
      final Map<String, String> specifications,
      final ReviewSummaryEntity? reviewSummary,
      final List<ProductReviewEntity> reviews,
      final List<DealEntity> similarProducts}) = _$ProductDetailEntityImpl;

  @override
  ListingEntity get listing;
  @override
  double? get compareAtPrice;
  @override
  int get stockQuantity;
  @override
  String get locationLine;
  @override
  ProductSellerEntity? get seller;
  @override
  Map<String, String> get specifications;
  @override
  ReviewSummaryEntity? get reviewSummary;
  @override
  List<ProductReviewEntity> get reviews;
  @override
  List<DealEntity> get similarProducts;
  @override
  @JsonKey(ignore: true)
  _$$ProductDetailEntityImplCopyWith<_$ProductDetailEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
