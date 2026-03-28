// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_line_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartLineEntity {
  String get listingId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartLineEntityCopyWith<CartLineEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartLineEntityCopyWith<$Res> {
  factory $CartLineEntityCopyWith(
          CartLineEntity value, $Res Function(CartLineEntity) then) =
      _$CartLineEntityCopyWithImpl<$Res, CartLineEntity>;
  @useResult
  $Res call(
      {String listingId,
      String title,
      double unitPrice,
      String? imageUrl,
      int quantity});
}

/// @nodoc
class _$CartLineEntityCopyWithImpl<$Res, $Val extends CartLineEntity>
    implements $CartLineEntityCopyWith<$Res> {
  _$CartLineEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listingId = null,
    Object? title = null,
    Object? unitPrice = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      listingId: null == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartLineEntityImplCopyWith<$Res>
    implements $CartLineEntityCopyWith<$Res> {
  factory _$$CartLineEntityImplCopyWith(_$CartLineEntityImpl value,
          $Res Function(_$CartLineEntityImpl) then) =
      __$$CartLineEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String listingId,
      String title,
      double unitPrice,
      String? imageUrl,
      int quantity});
}

/// @nodoc
class __$$CartLineEntityImplCopyWithImpl<$Res>
    extends _$CartLineEntityCopyWithImpl<$Res, _$CartLineEntityImpl>
    implements _$$CartLineEntityImplCopyWith<$Res> {
  __$$CartLineEntityImplCopyWithImpl(
      _$CartLineEntityImpl _value, $Res Function(_$CartLineEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listingId = null,
    Object? title = null,
    Object? unitPrice = null,
    Object? imageUrl = freezed,
    Object? quantity = null,
  }) {
    return _then(_$CartLineEntityImpl(
      listingId: null == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CartLineEntityImpl implements _CartLineEntity {
  const _$CartLineEntityImpl(
      {required this.listingId,
      required this.title,
      required this.unitPrice,
      this.imageUrl,
      this.quantity = 1});

  @override
  final String listingId;
  @override
  final String title;
  @override
  final double unitPrice;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final int quantity;

  @override
  String toString() {
    return 'CartLineEntity(listingId: $listingId, title: $title, unitPrice: $unitPrice, imageUrl: $imageUrl, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartLineEntityImpl &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, listingId, title, unitPrice, imageUrl, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartLineEntityImplCopyWith<_$CartLineEntityImpl> get copyWith =>
      __$$CartLineEntityImplCopyWithImpl<_$CartLineEntityImpl>(
          this, _$identity);
}

abstract class _CartLineEntity implements CartLineEntity {
  const factory _CartLineEntity(
      {required final String listingId,
      required final String title,
      required final double unitPrice,
      final String? imageUrl,
      final int quantity}) = _$CartLineEntityImpl;

  @override
  String get listingId;
  @override
  String get title;
  @override
  double get unitPrice;
  @override
  String? get imageUrl;
  @override
  int get quantity;
  @override
  @JsonKey(ignore: true)
  _$$CartLineEntityImplCopyWith<_$CartLineEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
