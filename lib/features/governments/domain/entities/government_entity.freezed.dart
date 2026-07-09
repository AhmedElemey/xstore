// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'government_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GovernmentEntity {
  int get id => throw _privateConstructorUsedError;
  LocalizedText get name => throw _privateConstructorUsedError;
  int? get cityId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GovernmentEntityCopyWith<GovernmentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GovernmentEntityCopyWith<$Res> {
  factory $GovernmentEntityCopyWith(
          GovernmentEntity value, $Res Function(GovernmentEntity) then) =
      _$GovernmentEntityCopyWithImpl<$Res, GovernmentEntity>;
  @useResult
  $Res call({int id, LocalizedText name, int? cityId});

  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class _$GovernmentEntityCopyWithImpl<$Res, $Val extends GovernmentEntity>
    implements $GovernmentEntityCopyWith<$Res> {
  _$GovernmentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cityId = freezed,
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
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$GovernmentEntityImplCopyWith<$Res>
    implements $GovernmentEntityCopyWith<$Res> {
  factory _$$GovernmentEntityImplCopyWith(_$GovernmentEntityImpl value,
          $Res Function(_$GovernmentEntityImpl) then) =
      __$$GovernmentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, LocalizedText name, int? cityId});

  @override
  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class __$$GovernmentEntityImplCopyWithImpl<$Res>
    extends _$GovernmentEntityCopyWithImpl<$Res, _$GovernmentEntityImpl>
    implements _$$GovernmentEntityImplCopyWith<$Res> {
  __$$GovernmentEntityImplCopyWithImpl(_$GovernmentEntityImpl _value,
      $Res Function(_$GovernmentEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cityId = freezed,
  }) {
    return _then(_$GovernmentEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$GovernmentEntityImpl implements _GovernmentEntity {
  const _$GovernmentEntityImpl(
      {required this.id, required this.name, this.cityId});

  @override
  final int id;
  @override
  final LocalizedText name;
  @override
  final int? cityId;

  @override
  String toString() {
    return 'GovernmentEntity(id: $id, name: $name, cityId: $cityId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GovernmentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cityId, cityId) || other.cityId == cityId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, cityId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GovernmentEntityImplCopyWith<_$GovernmentEntityImpl> get copyWith =>
      __$$GovernmentEntityImplCopyWithImpl<_$GovernmentEntityImpl>(
          this, _$identity);
}

abstract class _GovernmentEntity implements GovernmentEntity {
  const factory _GovernmentEntity(
      {required final int id,
      required final LocalizedText name,
      final int? cityId}) = _$GovernmentEntityImpl;

  @override
  int get id;
  @override
  LocalizedText get name;
  @override
  int? get cityId;
  @override
  @JsonKey(ignore: true)
  _$$GovernmentEntityImplCopyWith<_$GovernmentEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
