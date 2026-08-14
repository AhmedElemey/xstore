// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CityEntity {
  int get id => throw _privateConstructorUsedError;
  LocalizedText get name => throw _privateConstructorUsedError;

  /// Parent governorate id from `/api/cities` (`governorateId` on the wire).
  int? get governorateId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CityEntityCopyWith<CityEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityEntityCopyWith<$Res> {
  factory $CityEntityCopyWith(
          CityEntity value, $Res Function(CityEntity) then) =
      _$CityEntityCopyWithImpl<$Res, CityEntity>;
  @useResult
  $Res call({int id, LocalizedText name, int? governorateId});

  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class _$CityEntityCopyWithImpl<$Res, $Val extends CityEntity>
    implements $CityEntityCopyWith<$Res> {
  _$CityEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? governorateId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      governorateId: freezed == governorateId
          ? _value.governorateId
          : governorateId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedTextCopyWith<$Res> get name {
    return $LocalizedTextCopyWith<$Res>(_value.name, (value) {
      return _then(_value.copyWith(name: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CityEntityImplCopyWith<$Res>
    implements $CityEntityCopyWith<$Res> {
  factory _$$CityEntityImplCopyWith(
          _$CityEntityImpl value, $Res Function(_$CityEntityImpl) then) =
      __$$CityEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, LocalizedText name, int? governorateId});

  @override
  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class __$$CityEntityImplCopyWithImpl<$Res>
    extends _$CityEntityCopyWithImpl<$Res, _$CityEntityImpl>
    implements _$$CityEntityImplCopyWith<$Res> {
  __$$CityEntityImplCopyWithImpl(
      _$CityEntityImpl _value, $Res Function(_$CityEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? governorateId = freezed,
  }) {
    return _then(_$CityEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      governorateId: freezed == governorateId
          ? _value.governorateId
          : governorateId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$CityEntityImpl implements _CityEntity {
  const _$CityEntityImpl(
      {required this.id, required this.name, this.governorateId});

  @override
  final int id;
  @override
  final LocalizedText name;

  /// Parent governorate id from `/api/cities` (`governorateId` on the wire).
  @override
  final int? governorateId;

  @override
  String toString() {
    return 'CityEntity(id: $id, name: $name, governorateId: $governorateId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.governorateId, governorateId) ||
                other.governorateId == governorateId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, governorateId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CityEntityImplCopyWith<_$CityEntityImpl> get copyWith =>
      __$$CityEntityImplCopyWithImpl<_$CityEntityImpl>(this, _$identity);
}

abstract class _CityEntity implements CityEntity {
  const factory _CityEntity(
      {required final int id,
      required final LocalizedText name,
      final int? governorateId}) = _$CityEntityImpl;

  @override
  int get id;
  @override
  LocalizedText get name;
  @override

  /// Parent governorate id from `/api/cities` (`governorateId` on the wire).
  int? get governorateId;
  @override
  @JsonKey(ignore: true)
  _$$CityEntityImplCopyWith<_$CityEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
