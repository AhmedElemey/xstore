import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_push_route_provider.g.dart';

/// Cold-start or pre-auth tap target staged until [Auth] has a session.
@Riverpod(keepAlive: true)
class PendingPushRoute extends _$PendingPushRoute {
  @override
  String? build() => null;

  void stage(String route) => state = route;

  String? consume() {
    final value = state;
    if (value != null) state = null;
    return value;
  }
}
