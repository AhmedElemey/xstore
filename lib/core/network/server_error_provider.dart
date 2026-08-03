import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_error_provider.g.dart';

/// Set when any API response comes back with an HTTP 5xx status (see the
/// error interceptor in `dio_provider.dart`). While true, the router
/// redirects every route to [AppRoutes.serverError] instead of letting the
/// failing screen render its own inline error, and clears when the user
/// retries from that screen.
@Riverpod(keepAlive: true)
class ServerError extends _$ServerError {
  @override
  bool build() => false;

  void trigger() => state = true;

  void clear() => state = false;
}
