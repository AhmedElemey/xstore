import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
import 'package:xstore/features/profile/domain/entities/update_profile_request.dart';
import 'package:xstore/features/profile/domain/repositories/profile_repository.dart';
import 'package:xstore/features/profile/presentation/providers/profile_dependencies.dart';
import 'package:xstore/features/profile/presentation/screens/vendor_store_screen.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

import '../../../helpers/fake_async_auth_notifier.dart';

class _MissingStoreRepo implements ProfileRepository {
  var storeCalls = 0;
  var listingCalls = 0;

  @override
  Future<Either<Failure, ProfileEntity>> getVendorStoreProfile(
    String sellerId,
  ) async {
    storeCalls++;
    return const Left(Failure.server('Store not found'));
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  }) async {
    listingCalls++;
    return const Right([]);
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(UserEntity sessionUser) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
    required String confirmationText,
  }) =>
      throw UnimplementedError();
}

Widget _harness(_MissingStoreRepo repo) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        () => FakeAuth(
          const UserEntity(
            id: 'buyer-1',
            name: 'Buyer',
            email: 'buyer@test.com',
            phoneNumber: '01011111111',
          ),
        ),
      ),
      profileRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: VendorStoreScreen(sellerId: 'other-vendor'),
    ),
  );
}

void main() {
  testWidgets(
    'other-vendor store 404 shows an error state, not an empty shell',
    (tester) async {
      final repo = _MissingStoreRepo();
      await tester.pumpWidget(_harness(repo));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text("This store isn't available right now"), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(repo.storeCalls, 1);
      expect(repo.listingCalls, 0);
    },
  );
}
