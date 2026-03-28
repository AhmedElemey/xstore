// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BannerEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BannerEntityCopyWith<BannerEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerEntityCopyWith<$Res> {
  factory $BannerEntityCopyWith(
          BannerEntity value, $Res Function(BannerEntity) then) =
      _$BannerEntityCopyWithImpl<$Res, BannerEntity>;
  @useResult
  $Res call({String id, String title, String imageUrl, String? actionUrl});
}

/// @nodoc
class _$BannerEntityCopyWithImpl<$Res, $Val extends BannerEntity>
    implements $BannerEntityCopyWith<$Res> {
  _$BannerEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? actionUrl = freezed,
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BannerEntityImplCopyWith<$Res>
    implements $BannerEntityCopyWith<$Res> {
  factory _$$BannerEntityImplCopyWith(
          _$BannerEntityImpl value, $Res Function(_$BannerEntityImpl) then) =
      __$$BannerEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String imageUrl, String? actionUrl});
}

/// @nodoc
class __$$BannerEntityImplCopyWithImpl<$Res>
    extends _$BannerEntityCopyWithImpl<$Res, _$BannerEntityImpl>
    implements _$$BannerEntityImplCopyWith<$Res> {
  __$$BannerEntityImplCopyWithImpl(
      _$BannerEntityImpl _value, $Res Function(_$BannerEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? actionUrl = freezed,
  }) {
    return _then(_$BannerEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BannerEntityImpl implements _BannerEntity {
  const _$BannerEntityImpl(
      {required this.id,
      required this.title,
      required this.imageUrl,
      this.actionUrl});

  @override
  final String id;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final String? actionUrl;

  @override
  String toString() {
    return 'BannerEntity(id: $id, title: $title, imageUrl: $imageUrl, actionUrl: $actionUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, imageUrl, actionUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerEntityImplCopyWith<_$BannerEntityImpl> get copyWith =>
      __$$BannerEntityImplCopyWithImpl<_$BannerEntityImpl>(this, _$identity);
}

abstract class _BannerEntity implements BannerEntity {
  const factory _BannerEntity(
      {required final String id,
      required final String title,
      required final String imageUrl,
      final String? actionUrl}) = _$BannerEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  String? get actionUrl;
  @override
  @JsonKey(ignore: true)
  _$$BannerEntityImplCopyWith<_$BannerEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
