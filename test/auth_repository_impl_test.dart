import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xstore/features/auth/data/datasources/phone_auth_datasource.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/consumer_register_params.dart';
import 'package:xstore/features/auth/domain/entities/send_otp_result.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/domain/entities/vendor_register_params.dart';
import 'package:xstore/features/auth/domain/entities/verify_otp_params.dart';

class _FakeUser implements User {
  const _FakeUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async =>
      'firebase-id-token-test';

  @override
  String get uid => 'firebase-uid-test';
}

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this._user);

  final User? _user;

  @override
  User? get currentUser => _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingRemote implements AuthRemoteDataSource {
  String? lastSocialProvider;
  String? lastSocialIdToken;
  String? lastPhoneIdToken;
  String? lastPhoneNumber;
  String? lastGoogleIdToken;
  bool? lastGoogleAsVendor;

  ConsumerRegisterParams? lastConsumerRegisterParams;
  VendorRegisterParams? lastVendorRegisterParams;
  String? lastChangePasswordCurrent;
  String? lastForgotPasswordEmail;
  String? lastRefreshTokenInput;

  final UserModel socialResponse = mockConsumerUserModel(
    email: 'social@xstore.com',
  );
  final UserModel phoneResponse = mockConsumerUserModel(
    phoneNumber: '01012345678',
  );
  final UserModel consumerRegisterResponse = mockConsumerUserModel(
    email: 'new-consumer@xstore.com',
  );
  final UserModel vendorRegisterResponse = mockVendorUserModel(
    email: 'new-vendor@xstore.com',
  );

  @override
  Future<UserModel> login(_) => throw UnimplementedError();

  @override
  Future<UserModel> register(_) => throw UnimplementedError();

  @override
  Future<UserModel> fetchProfile() async => consumerRegisterResponse;

  @override
  Future<UserModel> registerConsumer(ConsumerRegisterParams params) async {
    lastConsumerRegisterParams = params;
    return consumerRegisterResponse;
  }

  @override
  Future<UserModel> registerVendor(VendorRegisterParams params) async {
    lastVendorRegisterParams = params;
    return vendorRegisterResponse;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    lastChangePasswordCurrent = currentPassword;
  }

  @override
  Future<String?> forgotPassword(String email) async {
    lastForgotPasswordEmail = email;
    return '654321';
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<({String token, String refreshToken})> refreshToken(
    String token,
  ) async {
    lastRefreshTokenInput = token;
    return (token: 'refreshed-token', refreshToken: 'new-refresh-token');
  }

  @override
  Future<String?> sendEmailOtp(String email) => throw UnimplementedError();

  @override
  Future<void> verifyEmailOtp(String otpToken) => throw UnimplementedError();

  @override
  Future<String?> sendPhoneOtpBackend(String phoneNumber) =>
      throw UnimplementedError();

  @override
  Future<void> verifyPhoneOtpBackend(String otpToken) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> loginWithSocialToken({
    required String provider,
    required String idToken,
  }) async {
    lastSocialProvider = provider;
    lastSocialIdToken = idToken;
    return socialResponse;
  }

  @override
  Future<UserModel> loginWithPhoneToken({
    required String firebaseIdToken,
    required String phoneNumber,
  }) async {
    lastPhoneIdToken = firebaseIdToken;
    lastPhoneNumber = phoneNumber;
    return phoneResponse;
  }

  @override
  Future<String?> sendLoginOtp(String phoneNumber) =>
      throw UnimplementedError();

  @override
  Future<UserModel> loginWithOtp({
    required String phoneNumber,
    required String otpToken,
    required bool rememberMe,
  }) =>
      throw UnimplementedError();

  @override
  Future<UserModel> loginWithGoogle({
    required String idToken,
    required bool asVendor,
  }) async {
    lastGoogleIdToken = idToken;
    lastGoogleAsVendor = asVendor;
    return asVendor ? mockVendorUserModel() : mockConsumerUserModel();
  }
}

class _FakeSocial implements SocialAuthDatasource {
  _FakeSocial(this.result);

  final SocialAuthResult result;

  @override
  Future<SocialAuthResult> signInWithApple() => Future.value(result);

  @override
  Future<SocialAuthResult> signInWithFacebook() => Future.value(result);

  @override
  Future<SocialAuthResult> signInWithGoogle() => Future.value(result);

  @override
  Future<void> signOutSocial() async {}
}

class _FakePhone implements PhoneAuthDatasource {
  @override
  Future<SendOtpResult> sendOtp({
    required String e164Number,
    int? resendToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otpCode,
    required String phoneNumber,
  }) async =>
      const UserEntity(
        id: 'phone-firebase-uid',
        name: 'Phone User',
        email: '',
        phoneNumber: '01012345678',
        role: UserRole.consumer,
        isVerified: true,
        joinedAt: null,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingRemote remote;
  late FlutterSecureStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    remote = _RecordingRemote();
    storage = const FlutterSecureStorage();
    repository = AuthRepositoryImpl(
      remote: remote,
      social: _FakeSocial(
        const SocialAuthResult(
          provider: SocialProvider.google,
          uid: 'google-uid',
          email: 'user@gmail.com',
          isNewUser: false,
        ),
      ),
      phone: _FakePhone(),
      secureStorage: storage,
      firebaseAuth: _FakeFirebaseAuth(_FakeUser()),
    );
  });

  Future<String?> readStoredToken() =>
      storage.read(key: PrefsKeys.authToken);

  group('AuthRepositoryImpl Firebase → backend session bridge', () {
    test(
      'signInWithGoogle defers the exchange; loginWithGoogle mints the session',
      () async {
        // Google sign-in only fetches the identity token now — no exchange,
        // no persisted session until the user picks a role.
        final signIn = await repository.signInWithGoogle();
        expect(signIn.isRight(), isTrue);
        expect(remote.lastGoogleIdToken, isNull);
        expect(await readStoredToken(), isNull);

        // The role screen then calls loginWithGoogle with the chosen role.
        final login = await repository.loginWithGoogle(
          idToken: 'google-id-token',
          role: UserRole.vendor,
        );
        expect(login.isRight(), isTrue);
        expect(remote.lastGoogleIdToken, 'google-id-token');
        expect(remote.lastGoogleAsVendor, isTrue);
        expect(await readStoredToken(), 'mock-token-vendor');
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );

    test(
      'signInWithApple exchanges Firebase ID token and persists backend token',
      () async {
        repository = AuthRepositoryImpl(
          remote: remote,
          social: _FakeSocial(
            const SocialAuthResult(
              provider: SocialProvider.apple,
              uid: 'apple-uid',
              email: 'user@icloud.com',
              isNewUser: true,
            ),
          ),
          phone: _FakePhone(),
          secureStorage: storage,
          firebaseAuth: _FakeFirebaseAuth(_FakeUser()),
        );

        final result = await repository.signInWithApple();

        expect(result.isRight(), isTrue);
        expect(remote.lastSocialProvider, 'apple');
        expect(remote.lastSocialIdToken, 'firebase-id-token-test');
        expect(await readStoredToken(), 'mock-token-consumer');
        result.fold((_) => fail('expected right'), (social) {
          expect(social.isNewUser, isFalse);
        });
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );

    test(
      'signInWithFacebook exchanges Firebase ID token and persists backend token',
      () async {
        repository = AuthRepositoryImpl(
          remote: remote,
          social: _FakeSocial(
            const SocialAuthResult(
              provider: SocialProvider.facebook,
              uid: 'facebook-uid',
              email: 'user@facebook.com',
              isNewUser: false,
            ),
          ),
          phone: _FakePhone(),
          secureStorage: storage,
          firebaseAuth: _FakeFirebaseAuth(_FakeUser()),
        );

        final result = await repository.signInWithFacebook();

        expect(result.isRight(), isTrue);
        expect(remote.lastSocialProvider, 'facebook');
        expect(await readStoredToken(), 'mock-token-consumer');
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );

    test(
      'verifyOtp exchanges Firebase ID token and persists backend token',
      () async {
        final result = await repository.verifyOtp(
          const VerifyOtpParams(
            verificationId: 'vid',
            otpCode: '123456',
            phoneNumber: '01012345678',
          ),
        );

        expect(result.isRight(), isTrue);
        expect(remote.lastPhoneIdToken, 'firebase-id-token-test');
        expect(remote.lastPhoneNumber, '01012345678');
        expect(await readStoredToken(), 'mock-token-consumer');
      },
      skip: MockConfig.useMock ? 'Requires MOCK=false' : false,
    );
  });

  group('AuthRepositoryImpl Phase 1 backend endpoints', () {
    test('registerConsumer persists session and passes params through',
        () async {
      final result = await repository.registerConsumer(
        const ConsumerRegisterParams(
          fullNameEn: 'Jane Doe',
          fullNameAr: 'جين دو',
          email: 'jane@test.com',
          phoneNumber: '01012345678',
          password: 'Password1!',
          confirmPassword: 'Password1!',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(remote.lastConsumerRegisterParams?.email, 'jane@test.com');
      expect(await readStoredToken(), isNotNull);
    });

    test('registerVendor persists session and passes params through',
        () async {
      final result = await repository.registerVendor(
        const VendorRegisterParams(
          fullNameEn: 'Ahmed Ali',
          fullNameAr: 'أحمد علي',
          email: 'ahmed@test.com',
          phoneNumber: '01112345678',
          password: 'Password1!',
          confirmPassword: 'Password1!',
          storeNameEn: 'Tech Store',
          storeNameAr: 'متجر التقنية',
          storeDescriptionEn: 'Best electronics',
          storeDescriptionAr: 'أفضل إلكترونيات',
          storeCategoryId: 1,
          storeCityId: 1,
          storeGovernmentId: 1,
          whatsappNumber: '01098765432',
          profileImagePath: '/tmp/store.jpg',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(remote.lastVendorRegisterParams?.storeCategoryId, 1);
      expect(await readStoredToken(), isNotNull);
    });

    test('changePassword forwards current/new passwords and succeeds',
        () async {
      final result = await repository.changePassword(
        currentPassword: 'old-pass',
        newPassword: 'new-pass',
        confirmNewPassword: 'new-pass',
      );

      expect(result.isRight(), isTrue);
      expect(remote.lastChangePasswordCurrent, 'old-pass');
    });

    test(
        'forgotPassword forwards the email and surfaces the debug OTP',
        () async {
      final result = await repository.forgotPassword('jane@test.com');

      expect(result.isRight(), isTrue);
      expect(remote.lastForgotPasswordEmail, 'jane@test.com');
      result.fold((_) => fail('expected right'), (otp) {
        expect(otp, '654321');
      });
    });

    test('refreshToken persists the new token pair', () async {
      final result = await repository.refreshToken('stale-token');

      expect(result.isRight(), isTrue);
      expect(remote.lastRefreshTokenInput, 'stale-token');
      expect(await readStoredToken(), 'refreshed-token');
      expect(
        await storage.read(key: PrefsKeys.authRefreshToken),
        'new-refresh-token',
      );
      result.fold((_) => fail('expected right'), (pair) {
        expect(pair.token, 'refreshed-token');
        expect(pair.refreshToken, 'new-refresh-token');
      });
    });
  });

  group('AuthRepositoryImpl mock mode default wiring', () {
    late AuthRepositoryImpl defaultRepository;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      setupFirebaseCoreMocks();
      await Firebase.initializeApp();
    });

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      remote = _RecordingRemote();
      storage = const FlutterSecureStorage();
      defaultRepository = AuthRepositoryImpl(
        remote: remote,
        social: SocialAuthDatasourceImpl(),
        phone: PhoneAuthDatasourceImpl(),
        secureStorage: storage,
      );
    });

    test(
      'signInWithGoogle succeeds without injected FirebaseAuth when MOCK=true',
      () async {
        final result = await defaultRepository.signInWithGoogle();

        expect(result.isRight(), isTrue);
        expect(remote.lastSocialIdToken, 'mock-firebase-id-token');
        expect(await storage.read(key: PrefsKeys.authToken), 'mock-token-consumer');
      },
      skip: MockConfig.useMock ? false : 'Requires MOCK=true (default)',
    );

    test(
      'verifyOtp succeeds without injected FirebaseAuth when MOCK=true',
      () async {
        final result = await defaultRepository.verifyOtp(
          const VerifyOtpParams(
            verificationId: 'mock_verification_id_12345',
            otpCode: '123456',
            phoneNumber: '01012345678',
          ),
        );

        expect(result.isRight(), isTrue);
        expect(remote.lastPhoneIdToken, 'mock-firebase-id-token');
        expect(await storage.read(key: PrefsKeys.authToken), 'mock-token-consumer');
      },
      skip: MockConfig.useMock ? false : 'Requires MOCK=true (default)',
    );
  });
}
