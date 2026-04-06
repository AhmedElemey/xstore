// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Failure {
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(_$NetworkFailureImpl value,
          $Res Function(_$NetworkFailureImpl) then) =
      __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
      _$NetworkFailureImpl _value, $Res Function(_$NetworkFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$NetworkFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NetworkFailureImpl extends NetworkFailure {
  const _$NetworkFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure extends Failure {
  const factory NetworkFailure([final String? message]) = _$NetworkFailureImpl;
  const NetworkFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
          _$ServerFailureImpl value, $Res Function(_$ServerFailureImpl) then) =
      __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
      _$ServerFailureImpl _value, $Res Function(_$ServerFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$ServerFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ServerFailureImpl extends ServerFailure {
  const _$ServerFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return server(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return server?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerFailure extends Failure {
  const factory ServerFailure([final String? message]) = _$ServerFailureImpl;
  const ServerFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
          _$CacheFailureImpl value, $Res Function(_$CacheFailureImpl) then) =
      __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
      _$CacheFailureImpl _value, $Res Function(_$CacheFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$CacheFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CacheFailureImpl extends CacheFailure {
  const _$CacheFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return cache(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return cache?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class CacheFailure extends Failure {
  const factory CacheFailure([final String? message]) = _$CacheFailureImpl;
  const CacheFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(_$ValidationFailureImpl value,
          $Res Function(_$ValidationFailureImpl) then) =
      __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(_$ValidationFailureImpl _value,
      $Res Function(_$ValidationFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$ValidationFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ValidationFailureImpl extends ValidationFailure {
  const _$ValidationFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return validation(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return validation?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure extends Failure {
  const factory ValidationFailure([final String? message]) =
      _$ValidationFailureImpl;
  const ValidationFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnauthorizedFailureImplCopyWith(_$UnauthorizedFailureImpl value,
          $Res Function(_$UnauthorizedFailureImpl) then) =
      __$$UnauthorizedFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnauthorizedFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnauthorizedFailureImpl>
    implements _$$UnauthorizedFailureImplCopyWith<$Res> {
  __$$UnauthorizedFailureImplCopyWithImpl(_$UnauthorizedFailureImpl _value,
      $Res Function(_$UnauthorizedFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$UnauthorizedFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UnauthorizedFailureImpl extends UnauthorizedFailure {
  const _$UnauthorizedFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      __$$UnauthorizedFailureImplCopyWithImpl<_$UnauthorizedFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return unauthorized(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return unauthorized?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return unauthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return unauthorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(this);
    }
    return orElse();
  }
}

abstract class UnauthorizedFailure extends Failure {
  const factory UnauthorizedFailure([final String? message]) =
      _$UnauthorizedFailureImpl;
  const UnauthorizedFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NotFoundFailureImplCopyWith(_$NotFoundFailureImpl value,
          $Res Function(_$NotFoundFailureImpl) then) =
      __$$NotFoundFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NotFoundFailureImpl>
    implements _$$NotFoundFailureImplCopyWith<$Res> {
  __$$NotFoundFailureImplCopyWithImpl(
      _$NotFoundFailureImpl _value, $Res Function(_$NotFoundFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$NotFoundFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NotFoundFailureImpl extends NotFoundFailure {
  const _$NotFoundFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      __$$NotFoundFailureImplCopyWithImpl<_$NotFoundFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundFailure extends Failure {
  const factory NotFoundFailure([final String? message]) =
      _$NotFoundFailureImpl;
  const NotFoundFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SocialAuthFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$SocialAuthFailureImplCopyWith(_$SocialAuthFailureImpl value,
          $Res Function(_$SocialAuthFailureImpl) then) =
      __$$SocialAuthFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$SocialAuthFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$SocialAuthFailureImpl>
    implements _$$SocialAuthFailureImplCopyWith<$Res> {
  __$$SocialAuthFailureImplCopyWithImpl(_$SocialAuthFailureImpl _value,
      $Res Function(_$SocialAuthFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$SocialAuthFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SocialAuthFailureImpl extends SocialAuthFailure {
  const _$SocialAuthFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialAuthFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialAuthFailureImplCopyWith<_$SocialAuthFailureImpl> get copyWith =>
      __$$SocialAuthFailureImplCopyWithImpl<_$SocialAuthFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return socialAuth(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return socialAuth?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (socialAuth != null) {
      return socialAuth(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return socialAuth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return socialAuth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (socialAuth != null) {
      return socialAuth(this);
    }
    return orElse();
  }
}

abstract class SocialAuthFailure extends Failure {
  const factory SocialAuthFailure([final String? message]) =
      _$SocialAuthFailureImpl;
  const SocialAuthFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$SocialAuthFailureImplCopyWith<_$SocialAuthFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SocialAuthCancelledFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$SocialAuthCancelledFailureImplCopyWith(
          _$SocialAuthCancelledFailureImpl value,
          $Res Function(_$SocialAuthCancelledFailureImpl) then) =
      __$$SocialAuthCancelledFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$SocialAuthCancelledFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$SocialAuthCancelledFailureImpl>
    implements _$$SocialAuthCancelledFailureImplCopyWith<$Res> {
  __$$SocialAuthCancelledFailureImplCopyWithImpl(
      _$SocialAuthCancelledFailureImpl _value,
      $Res Function(_$SocialAuthCancelledFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$SocialAuthCancelledFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SocialAuthCancelledFailureImpl extends SocialAuthCancelledFailure {
  const _$SocialAuthCancelledFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialAuthCancelledFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialAuthCancelledFailureImplCopyWith<_$SocialAuthCancelledFailureImpl>
      get copyWith => __$$SocialAuthCancelledFailureImplCopyWithImpl<
          _$SocialAuthCancelledFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return socialAuthCancelled(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return socialAuthCancelled?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (socialAuthCancelled != null) {
      return socialAuthCancelled(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return socialAuthCancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return socialAuthCancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (socialAuthCancelled != null) {
      return socialAuthCancelled(this);
    }
    return orElse();
  }
}

abstract class SocialAuthCancelledFailure extends Failure {
  const factory SocialAuthCancelledFailure([final String? message]) =
      _$SocialAuthCancelledFailureImpl;
  const SocialAuthCancelledFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$SocialAuthCancelledFailureImplCopyWith<_$SocialAuthCancelledFailureImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PhoneAuthFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$PhoneAuthFailureImplCopyWith(_$PhoneAuthFailureImpl value,
          $Res Function(_$PhoneAuthFailureImpl) then) =
      __$$PhoneAuthFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$PhoneAuthFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PhoneAuthFailureImpl>
    implements _$$PhoneAuthFailureImplCopyWith<$Res> {
  __$$PhoneAuthFailureImplCopyWithImpl(_$PhoneAuthFailureImpl _value,
      $Res Function(_$PhoneAuthFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$PhoneAuthFailureImpl(
      freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PhoneAuthFailureImpl extends PhoneAuthFailure {
  const _$PhoneAuthFailureImpl([this.message]) : super._();

  @override
  final String? message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhoneAuthFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PhoneAuthFailureImplCopyWith<_$PhoneAuthFailureImpl> get copyWith =>
      __$$PhoneAuthFailureImplCopyWithImpl<_$PhoneAuthFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) network,
    required TResult Function(String? message) server,
    required TResult Function(String? message) cache,
    required TResult Function(String? message) validation,
    required TResult Function(String? message) unauthorized,
    required TResult Function(String? message) notFound,
    required TResult Function(String? message) socialAuth,
    required TResult Function(String? message) socialAuthCancelled,
    required TResult Function(String? message) phoneAuth,
  }) {
    return phoneAuth(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? network,
    TResult? Function(String? message)? server,
    TResult? Function(String? message)? cache,
    TResult? Function(String? message)? validation,
    TResult? Function(String? message)? unauthorized,
    TResult? Function(String? message)? notFound,
    TResult? Function(String? message)? socialAuth,
    TResult? Function(String? message)? socialAuthCancelled,
    TResult? Function(String? message)? phoneAuth,
  }) {
    return phoneAuth?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? network,
    TResult Function(String? message)? server,
    TResult Function(String? message)? cache,
    TResult Function(String? message)? validation,
    TResult Function(String? message)? unauthorized,
    TResult Function(String? message)? notFound,
    TResult Function(String? message)? socialAuth,
    TResult Function(String? message)? socialAuthCancelled,
    TResult Function(String? message)? phoneAuth,
    required TResult orElse(),
  }) {
    if (phoneAuth != null) {
      return phoneAuth(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(SocialAuthFailure value) socialAuth,
    required TResult Function(SocialAuthCancelledFailure value)
        socialAuthCancelled,
    required TResult Function(PhoneAuthFailure value) phoneAuth,
  }) {
    return phoneAuth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(SocialAuthFailure value)? socialAuth,
    TResult? Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult? Function(PhoneAuthFailure value)? phoneAuth,
  }) {
    return phoneAuth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(SocialAuthFailure value)? socialAuth,
    TResult Function(SocialAuthCancelledFailure value)? socialAuthCancelled,
    TResult Function(PhoneAuthFailure value)? phoneAuth,
    required TResult orElse(),
  }) {
    if (phoneAuth != null) {
      return phoneAuth(this);
    }
    return orElse();
  }
}

abstract class PhoneAuthFailure extends Failure {
  const factory PhoneAuthFailure([final String? message]) =
      _$PhoneAuthFailureImpl;
  const PhoneAuthFailure._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$PhoneAuthFailureImplCopyWith<_$PhoneAuthFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
