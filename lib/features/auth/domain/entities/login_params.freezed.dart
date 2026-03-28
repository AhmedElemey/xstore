// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoginParams {
  String get emailOrPhone => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  bool get rememberMe => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginParamsCopyWith<LoginParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginParamsCopyWith<$Res> {
  factory $LoginParamsCopyWith(
          LoginParams value, $Res Function(LoginParams) then) =
      _$LoginParamsCopyWithImpl<$Res, LoginParams>;
  @useResult
  $Res call({String emailOrPhone, String password, bool rememberMe});
}

/// @nodoc
class _$LoginParamsCopyWithImpl<$Res, $Val extends LoginParams>
    implements $LoginParamsCopyWith<$Res> {
  _$LoginParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailOrPhone = null,
    Object? password = null,
    Object? rememberMe = null,
  }) {
    return _then(_value.copyWith(
      emailOrPhone: null == emailOrPhone
          ? _value.emailOrPhone
          : emailOrPhone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginParamsImplCopyWith<$Res>
    implements $LoginParamsCopyWith<$Res> {
  factory _$$LoginParamsImplCopyWith(
          _$LoginParamsImpl value, $Res Function(_$LoginParamsImpl) then) =
      __$$LoginParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String emailOrPhone, String password, bool rememberMe});
}

/// @nodoc
class __$$LoginParamsImplCopyWithImpl<$Res>
    extends _$LoginParamsCopyWithImpl<$Res, _$LoginParamsImpl>
    implements _$$LoginParamsImplCopyWith<$Res> {
  __$$LoginParamsImplCopyWithImpl(
      _$LoginParamsImpl _value, $Res Function(_$LoginParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailOrPhone = null,
    Object? password = null,
    Object? rememberMe = null,
  }) {
    return _then(_$LoginParamsImpl(
      emailOrPhone: null == emailOrPhone
          ? _value.emailOrPhone
          : emailOrPhone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LoginParamsImpl implements _LoginParams {
  const _$LoginParamsImpl(
      {required this.emailOrPhone,
      required this.password,
      this.rememberMe = false});

  @override
  final String emailOrPhone;
  @override
  final String password;
  @override
  @JsonKey()
  final bool rememberMe;

  @override
  String toString() {
    return 'LoginParams(emailOrPhone: $emailOrPhone, password: $password, rememberMe: $rememberMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginParamsImpl &&
            (identical(other.emailOrPhone, emailOrPhone) ||
                other.emailOrPhone == emailOrPhone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.rememberMe, rememberMe) ||
                other.rememberMe == rememberMe));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, emailOrPhone, password, rememberMe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginParamsImplCopyWith<_$LoginParamsImpl> get copyWith =>
      __$$LoginParamsImplCopyWithImpl<_$LoginParamsImpl>(this, _$identity);
}

abstract class _LoginParams implements LoginParams {
  const factory _LoginParams(
      {required final String emailOrPhone,
      required final String password,
      final bool rememberMe}) = _$LoginParamsImpl;

  @override
  String get emailOrPhone;
  @override
  String get password;
  @override
  bool get rememberMe;
  @override
  @JsonKey(ignore: true)
  _$$LoginParamsImplCopyWith<_$LoginParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
