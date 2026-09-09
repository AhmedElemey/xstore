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
import 'package:xstore/features/listing/domain/repositories/listing_repository.dart';
import 'package:xstore/features/listing/presentation/providers/listing_dependencies.dart';
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
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
    required String confirmationText,
  }) => throw UnimplementedError();
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

  testWidgets(
    'other-vendor store from the public catalog opens, not an error shell',
    (tester) async {
      const seller = UserEntity(
        id: 'other-vendor',
        name: 'Tech Hub',
        email: '',
        phoneNumber: '',
        role: UserRole.vendor,
        storeName: 'Tech Hub',
      );
      final repo = _PublicStoreRepo(
        profile: const ProfileEntity(user: seller),
        listings: const [
          ListingEntity(
            id: '7',
            title: 'Desk Lamp',
            description: 'A lamp',
            price: 250,
            status: ListingStatus.active,
            categoryLabel: 'Home',
            vendorId: 'other-vendor',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
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
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.text('Tech Hub'), findsWidgets);
      expect(find.text('Desk Lamp'), findsOneWidget);
      expect(repo.storeCalls, 1);
      expect(repo.listingCalls, 1);
    },
  );

  testWidgets(
    'own store uses get-profile + my-listings, not the missing public store routes',
    (tester) async {
      const vendor = UserEntity(
        id: 'v1',
        name: 'Vendor',
        email: 'v@test.com',
        phoneNumber: '01000000000',
        role: UserRole.vendor,
        storeName: 'Tech Hub',
        storeId: 1,
      );
      final profileRepo = _OwnStoreRepo(
        profile: const ProfileEntity(user: vendor),
      );
      final listingRepo = _StubListingRepo(
        mine: const [
          ListingEntity(
            id: '7',
            title: 'Desk Lamp',
            description: 'A lamp',
            price: 250,
            status: ListingStatus.active,
            categoryLabel: 'Home',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => FakeAuth(vendor)),
            profileRepositoryProvider.overrideWithValue(profileRepo),
            listingRepositoryProvider.overrideWithValue(listingRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: VendorStoreScreen(sellerId: 'v1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.text('Tech Hub'), findsWidgets);
      expect(find.text('Desk Lamp'), findsOneWidget);
      expect(profileRepo.storeCalls, 0);
      expect(profileRepo.listingCalls, 0);
      expect(profileRepo.profileCalls, 1);
      expect(listingRepo.mineCalls, 1);
    },
  );
}

class _PublicStoreRepo implements ProfileRepository {
  _PublicStoreRepo({required this.profile, required this.listings});

  final ProfileEntity profile;
  final List<ListingEntity> listings;
  var storeCalls = 0;
  var listingCalls = 0;

  @override
  Future<Either<Failure, ProfileEntity>> getVendorStoreProfile(
    String sellerId,
  ) async {
    storeCalls++;
    return Right(profile);
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> fetchVendorStoreListings({
    required String sellerId,
    String? categoryLabel,
    required int page,
    required int pageSize,
  }) async {
    listingCalls++;
    return Right(listings);
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(UserEntity sessionUser) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
    required String confirmationText,
  }) => throw UnimplementedError();
}

class _OwnStoreRepo implements ProfileRepository {
  _OwnStoreRepo({required this.profile});

  final ProfileEntity profile;
  var storeCalls = 0;
  var listingCalls = 0;
  var profileCalls = 0;

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
    return const Left(Failure.server('not found'));
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(
    UserEntity sessionUser,
  ) async {
    profileCalls++;
    return Right(profile);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> updateAvatar({
    required String userId,
    required String filePath,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
    required String confirmationText,
  }) => throw UnimplementedError();
}

class _StubListingRepo implements ListingRepository {
  _StubListingRepo({required this.mine});

  final List<ListingEntity> mine;
  var mineCalls = 0;

  @override
  Future<Either<Failure, List<ListingEntity>>> getMyListings() async {
    mineCalls++;
    return Right(mine);
  }

  @override
  Future<Either<Failure, ListingEntity>> createListing({
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    List<String> imagePaths = const [],
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, ListingEntity>> getListingById(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, ListingEntity>> updateListing({
    required String id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    required List<String> imagePaths,
    required ListingStatus status,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteListing(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, ListingEntity>> resubmitListing({
    required String id,
    required double newPrice,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, ListingEntity>> deactivateListing(String id) =>
      throw UnimplementedError();
}
