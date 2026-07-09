// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CatalogCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  LocalizedText get name => throw _privateConstructorUsedError;
  int? get parentId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CatalogCategoryEntityCopyWith<CatalogCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogCategoryEntityCopyWith<$Res> {
  factory $CatalogCategoryEntityCopyWith(CatalogCategoryEntity value,
          $Res Function(CatalogCategoryEntity) then) =
      _$CatalogCategoryEntityCopyWithImpl<$Res, CatalogCategoryEntity>;
  @useResult
  $Res call({int id, LocalizedText name, int? parentId});

  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class _$CatalogCategoryEntityCopyWithImpl<$Res,
        $Val extends CatalogCategoryEntity>
    implements $CatalogCategoryEntityCopyWith<$Res> {
  _$CatalogCategoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? parentId = freezed,
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
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CatalogCategoryEntityImplCopyWith<$Res>
    implements $CatalogCategoryEntityCopyWith<$Res> {
  factory _$$CatalogCategoryEntityImplCopyWith(
          _$CatalogCategoryEntityImpl value,
          $Res Function(_$CatalogCategoryEntityImpl) then) =
      __$$CatalogCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, LocalizedText name, int? parentId});

  @override
  $LocalizedTextCopyWith<$Res> get name;
}

/// @nodoc
class __$$CatalogCategoryEntityImplCopyWithImpl<$Res>
    extends _$CatalogCategoryEntityCopyWithImpl<$Res,
        _$CatalogCategoryEntityImpl>
    implements _$$CatalogCategoryEntityImplCopyWith<$Res> {
  __$$CatalogCategoryEntityImplCopyWithImpl(_$CatalogCategoryEntityImpl _value,
      $Res Function(_$CatalogCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? parentId = freezed,
  }) {
    return _then(_$CatalogCategoryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedText,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$CatalogCategoryEntityImpl implements _CatalogCategoryEntity {
  const _$CatalogCategoryEntityImpl(
      {required this.id, required this.name, this.parentId});

  @override
  final int id;
  @override
  final LocalizedText name;
  @override
  final int? parentId;

  @override
  String toString() {
    return 'CatalogCategoryEntity(id: $id, name: $name, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, parentId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogCategoryEntityImplCopyWith<_$CatalogCategoryEntityImpl>
      get copyWith => __$$CatalogCategoryEntityImplCopyWithImpl<
          _$CatalogCategoryEntityImpl>(this, _$identity);
}

abstract class _CatalogCategoryEntity implements CatalogCategoryEntity {
  const factory _CatalogCategoryEntity(
      {required final int id,
      required final LocalizedText name,
      final int? parentId}) = _$CatalogCategoryEntityImpl;

  @override
  int get id;
  @override
  LocalizedText get name;
  @override
  int? get parentId;
  @override
  @JsonKey(ignore: true)
  _$$CatalogCategoryEntityImplCopyWith<_$CatalogCategoryEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
