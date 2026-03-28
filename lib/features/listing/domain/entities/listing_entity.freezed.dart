// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ListingEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  ListingStatus get status => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ListingEntityCopyWith<ListingEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingEntityCopyWith<$Res> {
  factory $ListingEntityCopyWith(
          ListingEntity value, $Res Function(ListingEntity) then) =
      _$ListingEntityCopyWithImpl<$Res, ListingEntity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double price,
      ListingStatus status,
      List<String> imageUrls});
}

/// @nodoc
class _$ListingEntityCopyWithImpl<$Res, $Val extends ListingEntity>
    implements $ListingEntityCopyWith<$Res> {
  _$ListingEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? status = null,
    Object? imageUrls = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ListingStatus,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingEntityImplCopyWith<$Res>
    implements $ListingEntityCopyWith<$Res> {
  factory _$$ListingEntityImplCopyWith(
          _$ListingEntityImpl value, $Res Function(_$ListingEntityImpl) then) =
      __$$ListingEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double price,
      ListingStatus status,
      List<String> imageUrls});
}

/// @nodoc
class __$$ListingEntityImplCopyWithImpl<$Res>
    extends _$ListingEntityCopyWithImpl<$Res, _$ListingEntityImpl>
    implements _$$ListingEntityImplCopyWith<$Res> {
  __$$ListingEntityImplCopyWithImpl(
      _$ListingEntityImpl _value, $Res Function(_$ListingEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? status = null,
    Object? imageUrls = null,
  }) {
    return _then(_$ListingEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ListingStatus,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ListingEntityImpl implements _ListingEntity {
  const _$ListingEntityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.status,
      final List<String> imageUrls = const <String>[]})
      : _imageUrls = imageUrls;

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double price;
  @override
  final ListingStatus status;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  String toString() {
    return 'ListingEntity(id: $id, title: $title, description: $description, price: $price, status: $status, imageUrls: $imageUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, price,
      status, const DeepCollectionEquality().hash(_imageUrls));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingEntityImplCopyWith<_$ListingEntityImpl> get copyWith =>
      __$$ListingEntityImplCopyWithImpl<_$ListingEntityImpl>(this, _$identity);
}

abstract class _ListingEntity implements ListingEntity {
  const factory _ListingEntity(
      {required final String id,
      required final String title,
      required final String description,
      required final double price,
      required final ListingStatus status,
      final List<String> imageUrls}) = _$ListingEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get price;
  @override
  ListingStatus get status;
  @override
  List<String> get imageUrls;
  @override
  @JsonKey(ignore: true)
  _$$ListingEntityImplCopyWith<_$ListingEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
