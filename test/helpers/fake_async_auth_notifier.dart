import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';

/// Overrides [Auth] session for tests (`authProvider.overrideWith`).
class FakeAuth extends Auth {
  FakeAuth(this._user);

  final UserEntity? _user;

  @override
  Future<UserEntity?> build() async => _user;
}
