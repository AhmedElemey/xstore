// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SocialAuthResult {
  SocialProvider get provider => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get accessToken => throw _privateConstructorUsedError;
  String? get idToken => throw _privateConstructorUsedError;
  bool get isNewUser => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SocialAuthResultCopyWith<SocialAuthResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialAuthResultCopyWith<$Res> {
  factory $SocialAuthResultCopyWith(
          SocialAuthResult value, $Res Function(SocialAuthResult) then) =
      _$SocialAuthResultCopyWithImpl<$Res, SocialAuthResult>;
  @useResult
  $Res call(
      {SocialProvider provider,
      String uid,
      String? email,
      String? displayName,
      String? photoUrl,
      String? accessToken,
      String? idToken,
      bool isNewUser});
}

/// @nodoc
class _$SocialAuthResultCopyWithImpl<$Res, $Val extends SocialAuthResult>
    implements $SocialAuthResultCopyWith<$Res> {
  _$SocialAuthResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? uid = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? accessToken = freezed,
    Object? idToken = freezed,
    Object? isNewUser = null,
  }) {
    return _then(_value.copyWith(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as SocialProvider,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SocialAuthResultImplCopyWith<$Res>
    implements $SocialAuthResultCopyWith<$Res> {
  factory _$$SocialAuthResultImplCopyWith(_$SocialAuthResultImpl value,
          $Res Function(_$SocialAuthResultImpl) then) =
      __$$SocialAuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SocialProvider provider,
      String uid,
      String? email,
      String? displayName,
      String? photoUrl,
      String? accessToken,
      String? idToken,
      bool isNewUser});
}

/// @nodoc
class __$$SocialAuthResultImplCopyWithImpl<$Res>
    extends _$SocialAuthResultCopyWithImpl<$Res, _$SocialAuthResultImpl>
    implements _$$SocialAuthResultImplCopyWith<$Res> {
  __$$SocialAuthResultImplCopyWithImpl(_$SocialAuthResultImpl _value,
      $Res Function(_$SocialAuthResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? uid = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? accessToken = freezed,
    Object? idToken = freezed,
    Object? isNewUser = null,
  }) {
    return _then(_$SocialAuthResultImpl(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as SocialProvider,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SocialAuthResultImpl implements _SocialAuthResult {
  const _$SocialAuthResultImpl(
      {required this.provider,
      required this.uid,
      this.email,
      this.displayName,
      this.photoUrl,
      this.accessToken,
      this.idToken,
      this.isNewUser = false});

  @override
  final SocialProvider provider;
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final String? accessToken;
  @override
  final String? idToken;
  @override
  @JsonKey()
  final bool isNewUser;

  @override
  String toString() {
    return 'SocialAuthResult(provider: $provider, uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, accessToken: $accessToken, idToken: $idToken, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialAuthResultImpl &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @override
  int get hashCode => Object.hash(runtimeType, provider, uid, email,
      displayName, photoUrl, accessToken, idToken, isNewUser);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialAuthResultImplCopyWith<_$SocialAuthResultImpl> get copyWith =>
      __$$SocialAuthResultImplCopyWithImpl<_$SocialAuthResultImpl>(
          this, _$identity);
}

abstract class _SocialAuthResult implements SocialAuthResult {
  const factory _SocialAuthResult(
      {required final SocialProvider provider,
      required final String uid,
      final String? email,
      final String? displayName,
      final String? photoUrl,
      final String? accessToken,
      final String? idToken,
      final bool isNewUser}) = _$SocialAuthResultImpl;

  @override
  SocialProvider get provider;
  @override
  String get uid;
  @override
  String? get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  String? get accessToken;
  @override
  String? get idToken;
  @override
  bool get isNewUser;
  @override
  @JsonKey(ignore: true)
  _$$SocialAuthResultImplCopyWith<_$SocialAuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
