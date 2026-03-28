// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DealEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DealEntityCopyWith<DealEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealEntityCopyWith<$Res> {
  factory $DealEntityCopyWith(
          DealEntity value, $Res Function(DealEntity) then) =
      _$DealEntityCopyWithImpl<$Res, DealEntity>;
  @useResult
  $Res call(
      {String id,
      String title,
      double price,
      String? imageUrl,
      double discountPercent});
}

/// @nodoc
class _$DealEntityCopyWithImpl<$Res, $Val extends DealEntity>
    implements $DealEntityCopyWith<$Res> {
  _$DealEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? discountPercent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealEntityImplCopyWith<$Res>
    implements $DealEntityCopyWith<$Res> {
  factory _$$DealEntityImplCopyWith(
          _$DealEntityImpl value, $Res Function(_$DealEntityImpl) then) =
      __$$DealEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double price,
      String? imageUrl,
      double discountPercent});
}

/// @nodoc
class __$$DealEntityImplCopyWithImpl<$Res>
    extends _$DealEntityCopyWithImpl<$Res, _$DealEntityImpl>
    implements _$$DealEntityImplCopyWith<$Res> {
  __$$DealEntityImplCopyWithImpl(
      _$DealEntityImpl _value, $Res Function(_$DealEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? discountPercent = null,
  }) {
    return _then(_$DealEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$DealEntityImpl implements _DealEntity {
  const _$DealEntityImpl(
      {required this.id,
      required this.title,
      required this.price,
      this.imageUrl,
      this.discountPercent = 0.0});

  @override
  final String id;
  @override
  final String title;
  @override
  final double price;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final double discountPercent;

  @override
  String toString() {
    return 'DealEntity(id: $id, title: $title, price: $price, imageUrl: $imageUrl, discountPercent: $discountPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, price, imageUrl, discountPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DealEntityImplCopyWith<_$DealEntityImpl> get copyWith =>
      __$$DealEntityImplCopyWithImpl<_$DealEntityImpl>(this, _$identity);
}

abstract class _DealEntity implements DealEntity {
  const factory _DealEntity(
      {required final String id,
      required final String title,
      required final double price,
      final String? imageUrl,
      final double discountPercent}) = _$DealEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  double get price;
  @override
  String? get imageUrl;
  @override
  double get discountPercent;
  @override
  @JsonKey(ignore: true)
  _$$DealEntityImplCopyWith<_$DealEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
