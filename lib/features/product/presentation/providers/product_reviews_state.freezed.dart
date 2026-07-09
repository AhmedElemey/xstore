// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_reviews_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductReviewsState {
  List<ReviewEntity> get reviews => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProductReviewsStateCopyWith<ProductReviewsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductReviewsStateCopyWith<$Res> {
  factory $ProductReviewsStateCopyWith(
          ProductReviewsState value, $Res Function(ProductReviewsState) then) =
      _$ProductReviewsStateCopyWithImpl<$Res, ProductReviewsState>;
  @useResult
  $Res call(
      {List<ReviewEntity> reviews,
      int page,
      bool hasMore,
      bool isLoading,
      bool isLoadingMore,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class _$ProductReviewsStateCopyWithImpl<$Res, $Val extends ProductReviewsState>
    implements $ProductReviewsStateCopyWith<$Res> {
  _$ProductReviewsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviews = null,
    Object? page = null,
    Object? hasMore = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ReviewEntity>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductReviewsStateImplCopyWith<$Res>
    implements $ProductReviewsStateCopyWith<$Res> {
  factory _$$ProductReviewsStateImplCopyWith(_$ProductReviewsStateImpl value,
          $Res Function(_$ProductReviewsStateImpl) then) =
      __$$ProductReviewsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ReviewEntity> reviews,
      int page,
      bool hasMore,
      bool isLoading,
      bool isLoadingMore,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class __$$ProductReviewsStateImplCopyWithImpl<$Res>
    extends _$ProductReviewsStateCopyWithImpl<$Res, _$ProductReviewsStateImpl>
    implements _$$ProductReviewsStateImplCopyWith<$Res> {
  __$$ProductReviewsStateImplCopyWithImpl(_$ProductReviewsStateImpl _value,
      $Res Function(_$ProductReviewsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reviews = null,
    Object? page = null,
    Object? hasMore = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_$ProductReviewsStateImpl(
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<ReviewEntity>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProductReviewsStateImpl implements _ProductReviewsState {
  const _$ProductReviewsStateImpl(
      {final List<ReviewEntity> reviews = const <ReviewEntity>[],
      this.page = 0,
      this.hasMore = true,
      this.isLoading = false,
      this.isLoadingMore = false,
      this.isSubmitting = false,
      this.error})
      : _reviews = reviews;

  final List<ReviewEntity> _reviews;
  @override
  @JsonKey()
  List<ReviewEntity> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  @override
  String toString() {
    return 'ProductReviewsState(reviews: $reviews, page: $page, hasMore: $hasMore, isLoading: $isLoading, isLoadingMore: $isLoadingMore, isSubmitting: $isSubmitting, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductReviewsStateImpl &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_reviews),
      page,
      hasMore,
      isLoading,
      isLoadingMore,
      isSubmitting,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductReviewsStateImplCopyWith<_$ProductReviewsStateImpl> get copyWith =>
      __$$ProductReviewsStateImplCopyWithImpl<_$ProductReviewsStateImpl>(
          this, _$identity);
}

abstract class _ProductReviewsState implements ProductReviewsState {
  const factory _ProductReviewsState(
      {final List<ReviewEntity> reviews,
      final int page,
      final bool hasMore,
      final bool isLoading,
      final bool isLoadingMore,
      final bool isSubmitting,
      final String? error}) = _$ProductReviewsStateImpl;

  @override
  List<ReviewEntity> get reviews;
  @override
  int get page;
  @override
  bool get hasMore;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get isSubmitting;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ProductReviewsStateImplCopyWith<_$ProductReviewsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
