// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DealModel _$DealModelFromJson(Map<String, dynamic> json) {
  return _DealModel.fromJson(json);
}

/// @nodoc
mixin _$DealModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DealModelCopyWith<DealModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealModelCopyWith<$Res> {
  factory $DealModelCopyWith(DealModel value, $Res Function(DealModel) then) =
      _$DealModelCopyWithImpl<$Res, DealModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      double price,
      String? imageUrl,
      double discountPercent});
}

/// @nodoc
class _$DealModelCopyWithImpl<$Res, $Val extends DealModel>
    implements $DealModelCopyWith<$Res> {
  _$DealModelCopyWithImpl(this._value, this._then);

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
abstract class _$$DealModelImplCopyWith<$Res>
    implements $DealModelCopyWith<$Res> {
  factory _$$DealModelImplCopyWith(
          _$DealModelImpl value, $Res Function(_$DealModelImpl) then) =
      __$$DealModelImplCopyWithImpl<$Res>;
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
class __$$DealModelImplCopyWithImpl<$Res>
    extends _$DealModelCopyWithImpl<$Res, _$DealModelImpl>
    implements _$$DealModelImplCopyWith<$Res> {
  __$$DealModelImplCopyWithImpl(
      _$DealModelImpl _value, $Res Function(_$DealModelImpl) _then)
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
    return _then(_$DealModelImpl(
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
@JsonSerializable()
class _$DealModelImpl implements _DealModel {
  const _$DealModelImpl(
      {required this.id,
      required this.title,
      required this.price,
      this.imageUrl,
      this.discountPercent = 0.0});

  factory _$DealModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealModelImplFromJson(json);

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
    return 'DealModel(id: $id, title: $title, price: $price, imageUrl: $imageUrl, discountPercent: $discountPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, price, imageUrl, discountPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DealModelImplCopyWith<_$DealModelImpl> get copyWith =>
      __$$DealModelImplCopyWithImpl<_$DealModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealModelImplToJson(
      this,
    );
  }
}

abstract class _DealModel implements DealModel {
  const factory _DealModel(
      {required final String id,
      required final String title,
      required final double price,
      final String? imageUrl,
      final double discountPercent}) = _$DealModelImpl;

  factory _DealModel.fromJson(Map<String, dynamic> json) =
      _$DealModelImpl.fromJson;

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
  _$$DealModelImplCopyWith<_$DealModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
