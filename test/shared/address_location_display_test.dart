// Tests for resolveAddressLocation (shared/utils/address_location_display.dart).
//
// Covers both re-resolution paths: by id (addresses saved after the id
// fields were added) and by matching the frozen name against the reference
// lists (addresses saved before that — the case a user hit when switching
// language still showed a stale English name for an address that predates
// this fix).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/localization_provider.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/features/cities/domain/entities/city_entity.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/governments/domain/entities/government_entity.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/shared/utils/address_location_display.dart';

const _cairoGov = GovernmentEntity(id: 16, name: LocalizedText(en: 'Cairo', ar: 'القاهرة'));
const _ainShamsCity = CityEntity(
  id: 42,
  name: LocalizedText(en: 'Ain Shams', ar: 'عين شمس'),
  governorateId: 16,
);

OrderAddress _address({int? cityId, int? governorateId, String city = 'Cairo', String wilaya = 'Cairo'}) =>
    OrderAddress(
      fullName: 'Jane Doe',
      phone: '01012345678',
      street: '1 Test Street',
      city: city,
      wilaya: wilaya,
      cityId: cityId,
      governorateId: governorateId,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<({String city, String wilaya})> resolve(
    WidgetTester tester,
    OrderAddress address, {
    required bool isArabic,
  }) async {
    late ({String city, String wilaya}) result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appIsArabicProvider.overrideWithValue(isArabic),
          allGovernmentsProvider.overrideWith((ref) async => const [_cairoGov]),
          allCitiesProvider.overrideWith((ref) async => const [_ainShamsCity]),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              result = resolveAddressLocation(ref, address);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return result;
  }

  testWidgets('resolves by id in whichever locale is active', (tester) async {
    final address = _address(cityId: 42, governorateId: 16, city: 'Ain Shams', wilaya: 'Cairo');

    final en = await resolve(tester, address, isArabic: false);
    expect(en.city, 'Ain Shams');
    expect(en.wilaya, 'Cairo');

    final ar = await resolve(tester, address, isArabic: true);
    expect(ar.city, 'عين شمس');
    expect(ar.wilaya, 'القاهرة');
  });

  testWidgets(
    'a legacy address with no ids still re-resolves by matching its frozen name',
    (tester) async {
      // No cityId/governorateId — exactly the shape of an address saved
      // before those fields existed, whose display previously stayed
      // frozen in whatever language was active at save time.
      final address = _address(city: 'Ain Shams', wilaya: 'Cairo');

      final ar = await resolve(tester, address, isArabic: true);

      expect(ar.city, 'عين شمس');
      expect(ar.wilaya, 'القاهرة');
    },
  );

  testWidgets(
    'falls back to the frozen string when no id or name match is found',
    (tester) async {
      final address = _address(city: 'Nowhere', wilaya: 'Nowhere');

      final ar = await resolve(tester, address, isArabic: true);

      expect(ar.city, 'Nowhere');
      expect(ar.wilaya, 'Nowhere');
    },
  );
}
