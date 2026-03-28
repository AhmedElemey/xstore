// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_review_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReviewSummaryEntity {
  double get average => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  /// Index 0 = 5★ count, index 4 = 1★ count.
  List<int> get starCounts => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReviewSummaryEntityCopyWith<ReviewSummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewSummaryEntityCopyWith<$Res> {
  factory $ReviewSummaryEntityCopyWith(
          ReviewSummaryEntity value, $Res Function(ReviewSummaryEntity) then) =
      _$ReviewSummaryEntityCopyWithImpl<$Res, ReviewSummaryEntity>;
  @useResult
  $Res call({double average, int totalCount, List<int> starCounts});
}

/// @nodoc
class _$ReviewSummaryEntityCopyWithImpl<$Res, $Val extends ReviewSummaryEntity>
    implements $ReviewSummaryEntityCopyWith<$Res> {
  _$ReviewSummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? totalCount = null,
    Object? starCounts = null,
  }) {
    return _then(_value.copyWith(
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      starCounts: null == starCounts
          ? _value.starCounts
          : starCounts // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewSummaryEntityImplCopyWith<$Res>
    implements $ReviewSummaryEntityCopyWith<$Res> {
  factory _$$ReviewSummaryEntityImplCopyWith(_$ReviewSummaryEntityImpl value,
          $Res Function(_$ReviewSummaryEntityImpl) then) =
      __$$ReviewSummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double average, int totalCount, List<int> starCounts});
}

/// @nodoc
class __$$ReviewSummaryEntityImplCopyWithImpl<$Res>
    extends _$ReviewSummaryEntityCopyWithImpl<$Res, _$ReviewSummaryEntityImpl>
    implements _$$ReviewSummaryEntityImplCopyWith<$Res> {
  __$$ReviewSummaryEntityImplCopyWithImpl(_$ReviewSummaryEntityImpl _value,
      $Res Function(_$ReviewSummaryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? totalCount = null,
    Object? starCounts = null,
  }) {
    return _then(_$ReviewSummaryEntityImpl(
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      starCounts: null == starCounts
          ? _value._starCounts
          : starCounts // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$ReviewSummaryEntityImpl implements _ReviewSummaryEntity {
  const _$ReviewSummaryEntityImpl(
      {required this.average,
      required this.totalCount,
      final List<int> starCounts = const [0, 0, 0, 0, 0]})
      : _starCounts = starCounts;

  @override
  final double average;
  @override
  final int totalCount;

  /// Index 0 = 5★ count, index 4 = 1★ count.
  final List<int> _starCounts;

  /// Index 0 = 5★ count, index 4 = 1★ count.
  @override
  @JsonKey()
  List<int> get starCounts {
    if (_starCounts is EqualUnmodifiableListView) return _starCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_starCounts);
  }

  @override
  String toString() {
    return 'ReviewSummaryEntity(average: $average, totalCount: $totalCount, starCounts: $starCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewSummaryEntityImpl &&
            (identical(other.average, average) || other.average == average) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            const DeepCollectionEquality()
                .equals(other._starCounts, _starCounts));
  }

  @override
  int get hashCode => Object.hash(runtimeType, average, totalCount,
      const DeepCollectionEquality().hash(_starCounts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewSummaryEntityImplCopyWith<_$ReviewSummaryEntityImpl> get copyWith =>
      __$$ReviewSummaryEntityImplCopyWithImpl<_$ReviewSummaryEntityImpl>(
          this, _$identity);
}

abstract class _ReviewSummaryEntity implements ReviewSummaryEntity {
  const factory _ReviewSummaryEntity(
      {required final double average,
      required final int totalCount,
      final List<int> starCounts}) = _$ReviewSummaryEntityImpl;

  @override
  double get average;
  @override
  int get totalCount;
  @override

  /// Index 0 = 5★ count, index 4 = 1★ count.
  List<int> get starCounts;
  @override
  @JsonKey(ignore: true)
  _$$ReviewSummaryEntityImplCopyWith<_$ReviewSummaryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductReviewEntity {
  String get id => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatarUrl => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get stars => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  int get helpfulCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProductReviewEntityCopyWith<ProductReviewEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductReviewEntityCopyWith<$Res> {
  factory $ProductReviewEntityCopyWith(
          ProductReviewEntity value, $Res Function(ProductReviewEntity) then) =
      _$ProductReviewEntityCopyWithImpl<$Res, ProductReviewEntity>;
  @useResult
  $Res call(
      {String id,
      String userName,
      String? userAvatarUrl,
      DateTime date,
      double stars,
      String text,
      int helpfulCount});
}

/// @nodoc
class _$ProductReviewEntityCopyWithImpl<$Res, $Val extends ProductReviewEntity>
    implements $ProductReviewEntityCopyWith<$Res> {
  _$ProductReviewEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? date = null,
    Object? stars = null,
    Object? text = null,
    Object? helpfulCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as double,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductReviewEntityImplCopyWith<$Res>
    implements $ProductReviewEntityCopyWith<$Res> {
  factory _$$ProductReviewEntityImplCopyWith(_$ProductReviewEntityImpl value,
          $Res Function(_$ProductReviewEntityImpl) then) =
      __$$ProductReviewEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userName,
      String? userAvatarUrl,
      DateTime date,
      double stars,
      String text,
      int helpfulCount});
}

/// @nodoc
class __$$ProductReviewEntityImplCopyWithImpl<$Res>
    extends _$ProductReviewEntityCopyWithImpl<$Res, _$ProductReviewEntityImpl>
    implements _$$ProductReviewEntityImplCopyWith<$Res> {
  __$$ProductReviewEntityImplCopyWithImpl(_$ProductReviewEntityImpl _value,
      $Res Function(_$ProductReviewEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? date = null,
    Object? stars = null,
    Object? text = null,
    Object? helpfulCount = null,
  }) {
    return _then(_$ProductReviewEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as double,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProductReviewEntityImpl implements _ProductReviewEntity {
  const _$ProductReviewEntityImpl(
      {required this.id,
      required this.userName,
      this.userAvatarUrl,
      required this.date,
      required this.stars,
      required this.text,
      this.helpfulCount = 0});

  @override
  final String id;
  @override
  final String userName;
  @override
  final String? userAvatarUrl;
  @override
  final DateTime date;
  @override
  final double stars;
  @override
  final String text;
  @override
  @JsonKey()
  final int helpfulCount;

  @override
  String toString() {
    return 'ProductReviewEntity(id: $id, userName: $userName, userAvatarUrl: $userAvatarUrl, date: $date, stars: $stars, text: $text, helpfulCount: $helpfulCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductReviewEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatarUrl, userAvatarUrl) ||
                other.userAvatarUrl == userAvatarUrl) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, userName, userAvatarUrl,
      date, stars, text, helpfulCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductReviewEntityImplCopyWith<_$ProductReviewEntityImpl> get copyWith =>
      __$$ProductReviewEntityImplCopyWithImpl<_$ProductReviewEntityImpl>(
          this, _$identity);
}

abstract class _ProductReviewEntity implements ProductReviewEntity {
  const factory _ProductReviewEntity(
      {required final String id,
      required final String userName,
      final String? userAvatarUrl,
      required final DateTime date,
      required final double stars,
      required final String text,
      final int helpfulCount}) = _$ProductReviewEntityImpl;

  @override
  String get id;
  @override
  String get userName;
  @override
  String? get userAvatarUrl;
  @override
  DateTime get date;
  @override
  double get stars;
  @override
  String get text;
  @override
  int get helpfulCount;
  @override
  @JsonKey(ignore: true)
  _$$ProductReviewEntityImplCopyWith<_$ProductReviewEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
