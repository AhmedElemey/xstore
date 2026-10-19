import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:xstore/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';

import '../../../helpers/fake_async_auth_notifier.dart';

class _CountingRepo implements CartRepository {
  int getCartCalls = 0;

  @override
  Future<Either<Failure, CartEntity>> getCart(String consumerId) async {
    getCartCalls++;
    return Right(CartEntity(id: 'c', consumerId: consumerId, items: const []));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

const _consumer = UserEntity(
  id: '6',
  name: 'Consumer',
  email: 'c@example.com',
  phoneNumber: '01012345678',
);

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (ProviderContainer, _CountingRepo) setUpContainer(UserEntity? user) {
    SharedPreferences.setMockInitialValues({});
    final repo = _CountingRepo();
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(user)),
        cartRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return (container, repo);
  }

  test('cart loads when first built after auth already resolved', () async {
    final (container, repo) = setUpContainer(_consumer);
    await container.read(authProvider.future); // cold start: session restored

    container.read(cartProvider); // the dock builds the provider afterwards
    await _flush();
    await _flush();

    expect(repo.getCartCalls, 1);
    expect(container.read(cartProvider).consumerId, '6');
  });

  test(
    'cart built while auth is loading fetches once when it resolves',
    () async {
      final (container, repo) = setUpContainer(_consumer);

      container.read(cartProvider);
      await container.read(authProvider.future);
      await _flush();
      await _flush();

      expect(repo.getCartCalls, 1);
    },
  );

  test('no fetch when signed out', () async {
    final (container, repo) = setUpContainer(null);
    await container.read(authProvider.future);

    container.read(cartProvider);
    await _flush();
    await _flush();

    expect(repo.getCartCalls, 0);
  });
}
