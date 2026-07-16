import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xstore/features/auth/data/datasources/phone_auth_datasource.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';

class _FakeRemote extends Fake implements AuthRemoteDataSource {
  UserModel? socialResponse;
  @override
  Future<UserModel?> loginWithSocialToken({
    required String provider,
    required String idToken,
  }) async =>
      socialResponse;
}

class _FakeSocial extends Fake implements SocialAuthDatasource {
  late SocialAuthResult result;
  bool throwOnSignOut = false;
  @override
  Future<SocialAuthResult> signInWithGoogle() async => result;
  @override
  Future<void> signOutSocial() async {
    if (throwOnSignOut) {
      throw Exception('Facebook SDK not initialized');
    }
  }
}

class _FakePhone extends Fake implements PhoneAuthDatasource {}

class _MemStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String?> store = {};
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
  }
}

class _FakeUser extends Fake implements User {
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async =>
      'fake-firebase-id-token';
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => _FakeUser();
}

void main() {
  const socialResult = SocialAuthResult(
    provider: SocialProvider.google,
    uid: 'firebase-uid-1',
    email: 'user@gmail.com',
    displayName: 'Test User',
    isNewUser: true,
  );

  late _FakeRemote remote;
  late _FakeSocial social;
  late _MemStorage storage;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = _FakeRemote();
    social = _FakeSocial()..result = socialResult;
    storage = _MemStorage();
    repo = AuthRepositoryImpl(
      remote: remote,
      social: social,
      phone: _FakePhone(),
      secureStorage: storage,
      firebaseAuth: _FakeFirebaseAuth(),
    );
  });

  group('social sign-in while backend route returns 404', () {
    test('succeeds with a local session and keeps Firebase isNewUser', () async {
      remote.socialResponse = null; // datasource maps 404 → null

      final either = await repo.signInWithGoogle();

      final result = either.getOrElse((f) => fail('expected Right, got $f'));
      expect(result.isNewUser, isTrue);
      expect(result.email, 'user@gmail.com');
      // No backend session must be persisted from a 404 fallback.
      expect(storage.store.containsKey(PrefsKeys.authToken), isFalse);
      // Provider credentials are still saved locally for later registration.
      expect(storage.store[PrefsKeys.socialAuthCredentials], contains('google'));
      expect(
        storage.store[PrefsKeys.socialAuthCredentials],
        contains('user@gmail.com'),
      );
    });

    test('backend response, once live, overrides isNewUser and persists', () async {
      remote.socialResponse =
          mockConsumerUserModel(email: 'user@gmail.com').copyWith(
        isNewUser: false,
        token: 'backend-token',
      );

      final either = await repo.signInWithGoogle();

      final result = either.getOrElse((f) => fail('expected Right, got $f'));
      expect(result.isNewUser, isFalse);
      expect(storage.store[PrefsKeys.authToken], 'backend-token');
    });
  });

  group('logout', () {
    test('clears local session even when social sign-out throws', () async {
      storage.store[PrefsKeys.authToken] = 't';
      storage.store[PrefsKeys.authRefreshToken] = 'rt';
      storage.store[PrefsKeys.authUser] = '{"id":"u1"}';
      storage.store[PrefsKeys.socialAuthCredentials] = '{"provider":"google"}';
      social.throwOnSignOut = true;

      final either = await repo.logout();

      expect(either.isRight(), isTrue);
      expect(storage.store, isEmpty);
    });
  });
}
