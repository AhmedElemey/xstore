/// Low-level exceptions thrown by data sources before mapping to [Failure].
class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  @override
  String toString() => message ?? 'AppException';
}

class NetworkException extends AppException {
  const NetworkException([super.message]);
}

class ServerException extends AppException {
  const ServerException([super.message]);
}

class CacheException extends AppException {
  const CacheException([super.message]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message]);
}

/// Invalid credentials or auth-specific business errors (mock / API).
class AuthException extends UnauthorizedException {
  const AuthException([super.message]);
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);
  final String message;
}

class SocialAuthCancelledException implements Exception {
  const SocialAuthCancelledException([this.message = 'Sign-in cancelled']);
  final String message;
}

class PhoneAuthException implements Exception {
  const PhoneAuthException(this.message);
  final String message;
}
