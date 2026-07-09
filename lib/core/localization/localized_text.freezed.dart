// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localized_text.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LocalizedText {
  String get en => throw _privateConstructorUsedError;
  String get ar => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LocalizedTextCopyWith<LocalizedText> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedTextCopyWith<$Res> {
  factory $LocalizedTextCopyWith(
          LocalizedText value, $Res Function(LocalizedText) then) =
      _$LocalizedTextCopyWithImpl<$Res, LocalizedText>;
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class _$LocalizedTextCopyWithImpl<$Res, $Val extends LocalizedText>
    implements $LocalizedTextCopyWith<$Res> {
  _$LocalizedTextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? ar = null,
  }) {
    return _then(_value.copyWith(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizedTextImplCopyWith<$Res>
    implements $LocalizedTextCopyWith<$Res> {
  factory _$$LocalizedTextImplCopyWith(
          _$LocalizedTextImpl value, $Res Function(_$LocalizedTextImpl) then) =
      __$$LocalizedTextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class __$$LocalizedTextImplCopyWithImpl<$Res>
    extends _$LocalizedTextCopyWithImpl<$Res, _$LocalizedTextImpl>
    implements _$$LocalizedTextImplCopyWith<$Res> {
  __$$LocalizedTextImplCopyWithImpl(
      _$LocalizedTextImpl _value, $Res Function(_$LocalizedTextImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? ar = null,
  }) {
    return _then(_$LocalizedTextImpl(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LocalizedTextImpl extends _LocalizedText {
  const _$LocalizedTextImpl({required this.en, required this.ar}) : super._();

  @override
  final String en;
  @override
  final String ar;

  @override
  String toString() {
    return 'LocalizedText(en: $en, ar: $ar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedTextImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.ar, ar) || other.ar == ar));
  }

  @override
  int get hashCode => Object.hash(runtimeType, en, ar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedTextImplCopyWith<_$LocalizedTextImpl> get copyWith =>
      __$$LocalizedTextImplCopyWithImpl<_$LocalizedTextImpl>(this, _$identity);
}

abstract class _LocalizedText extends LocalizedText {
  const factory _LocalizedText(
      {required final String en,
      required final String ar}) = _$LocalizedTextImpl;
  const _LocalizedText._() : super._();

  @override
  String get en;
  @override
  String get ar;
  @override
  @JsonKey(ignore: true)
  _$$LocalizedTextImplCopyWith<_$LocalizedTextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
