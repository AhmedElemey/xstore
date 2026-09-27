import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/validators.dart';
import 'package:xstore/features/app_settings/domain/app_settings.dart';
import 'package:xstore/features/app_settings/presentation/app_settings_providers.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/listing/presentation/providers/listing_dependencies.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';

// A complete, valid listing — loadForEdit() turns it into a form with no
// validation errors, so only the title limit decides the outcome below.
const _listing = ListingEntity(
  id: '42',
  title: 'Wireless Mouse',
  description: 'A great wireless mouse',
  price: 199.5,
  status: ListingStatus.active,
  titleEn: 'Wireless Mouse', // 14 characters
  descriptionEn: 'A great wireless mouse',
  imageUrls: ['https://example.com/a.jpg'],
  categoryId: 7,
  subcategoryId: 32,
  condition: ListingCondition.likeNew,
  stockQuantity: 3,
  location: 'Cairo',
);

ProviderContainer _containerWithSettings(Map<String, Object?> values) {
  final container = ProviderContainer(
    overrides: [
      appSettingsProvider.overrideWith((ref) async => AppSettings(values)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('listingTitleMaxLengthProvider', () {
    Future<int> maxFor(Map<String, Object?> values) async {
      final container = _containerWithSettings(values);
      await container.read(appSettingsProvider.future);
      return container.read(listingTitleMaxLengthProvider);
    }

    test('uses the admin value', () async {
      expect(await maxFor({AppSettingKeys.listingTitleMaxCharacter: 170}), 170);
    });

    test('falls back to the default when missing or invalid', () async {
      expect(await maxFor({}), kListingTitleMaxLengthDefault);
      for (final bad in [0, -5, '170', 170.5, null]) {
        expect(
          await maxFor({AppSettingKeys.listingTitleMaxCharacter: bad}),
          kListingTitleMaxLengthDefault,
          reason: '$bad',
        );
      }
    });
  });

  group('Validators.listingFormErrors title limit', () {
    ListingFormValidationInput input(String name, int max) =>
        ListingFormValidationInput(
          photoPaths: const ['a.jpg'],
          name: name,
          priceInput: '100',
          description: 'desc',
          categoryId: '1',
          subcategoryId: '2',
          condition: 'new',
          quantity: 1,
          location: 'Cairo',
          shippingAvailable: false,
          shippingCostInput: '',
          nameMaxLength: max,
        );

    test('enforces the configured limit and names it in the message', () {
      expect(Validators.listingFormHasErrors(input('a' * 170, 170)), isFalse);
      expect(Validators.listingFormHasErrors(input('a' * 171, 170)), isTrue);
      expect(
        Validators.listingFormErrors(l10n, input('a' * 171, 170))['name'],
        'Max 170 characters',
      );
    });
  });

  group('ListingFormNotifier.validate', () {
    Future<ListingFormNotifier> loadedForm(Map<String, Object?> values) async {
      SharedPreferences.setMockInitialValues({});
      final container = _containerWithSettings(values);
      await container.read(appSettingsProvider.future);
      container.listen(listingFormNotifierProvider, (_, __) {});
      final notifier = container.read(listingFormNotifierProvider.notifier);
      notifier.prepareForEdit(_listing);
      notifier.loadForEdit(_listing);
      return notifier;
    }

    test('accepts a title within the admin limit', () async {
      final notifier = await loadedForm({
        AppSettingKeys.listingTitleMaxCharacter: 14,
      });
      expect(notifier.validate(l10n), isTrue);
    });

    test('rejects a restored title longer than a lowered admin limit '
        'instead of cutting it', () async {
      final notifier = await loadedForm({
        AppSettingKeys.listingTitleMaxCharacter: 10,
      });
      expect(notifier.validate(l10n), isFalse);
      expect(notifier.state.name, 'Wireless Mouse');
      expect(notifier.state.errors['name'], 'Max 10 characters');
    });
  });
}
