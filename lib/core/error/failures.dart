import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Typed domain/data errors surfaced to use cases and UI (sealed union).
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network([String? message]) = NetworkFailure;

  const factory Failure.server([String? message]) = ServerFailure;

  const factory Failure.cache([String? message]) = CacheFailure;

  const factory Failure.validation([String? message]) = ValidationFailure;

  const factory Failure.unauthorized([String? message]) = UnauthorizedFailure;

  const factory Failure.notFound([String? message]) = NotFoundFailure;
  const factory Failure.socialAuth([String? message]) = SocialAuthFailure;
  const factory Failure.socialAuthCancelled([String? message]) =
      SocialAuthCancelledFailure;
  const factory Failure.phoneAuth([String? message]) = PhoneAuthFailure;

  @override
  String toString() => when(
        network: (m) => m ?? 'Network failure',
        server: (m) => m ?? 'Server failure',
        cache: (m) => m ?? 'Cache failure',
        validation: (m) => m ?? 'Validation failure',
        unauthorized: (m) => m ?? 'Unauthorized',
        notFound: (m) => m ?? 'Not found',
        socialAuth: (m) => m ?? 'Social sign-in failed',
        socialAuthCancelled: (m) => m ?? 'Sign-in cancelled',
        phoneAuth: (m) => m ?? 'Phone authentication failed',
      );
}
