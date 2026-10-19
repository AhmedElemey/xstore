import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addPhotoPaths appends a batch and clamps at 5', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(listingFormNotifierProvider.notifier);

    notifier.addPhotoPaths(['a', 'b', 'c', 'd', 'e', 'f']);
    expect(
      container.read(listingFormNotifierProvider).photoPaths,
      ['a', 'b', 'c', 'd', 'e'],
    );

    notifier.addPhotoPaths(['g']);
    expect(container.read(listingFormNotifierProvider).photoPaths.length, 5);
  });

  test('addPhotoPaths counts existing hosted photos toward the 5 cap', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(listingFormNotifierProvider.notifier);

    notifier.loadForEdit(
      const ListingEntity(
        id: '1',
        title: 't',
        description: 'd',
        price: 1,
        status: ListingStatus.active,
        imageUrls: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
      ),
    );
    notifier.addPhotoPaths(['a', 'b', 'c', 'd']);
    expect(
      container.read(listingFormNotifierProvider).photoPaths,
      ['a', 'b', 'c'],
    );
  });

  test('removeExistingPhoto drops a hosted url from the form', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(listingFormNotifierProvider.notifier);

    notifier.loadForEdit(
      const ListingEntity(
        id: '1',
        title: 't',
        description: 'd',
        price: 1,
        status: ListingStatus.active,
        imageUrls: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
      ),
    );
    expect(notifier.hasEditChanges, isFalse);
    notifier.removeExistingPhoto(0);
    expect(
      container.read(listingFormNotifierProvider).existingImageUrls,
      ['https://example.com/b.jpg'],
    );
    expect(notifier.hasEditChanges, isTrue);
  });

  test('addPhotoPaths fills only remaining slots', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(listingFormNotifierProvider.notifier);

    notifier.addPhotoPaths(['a', 'b', 'c']);
    notifier.addPhotoPaths(['d', 'e', 'f']);
    expect(
      container.read(listingFormNotifierProvider).photoPaths,
      ['a', 'b', 'c', 'd', 'e'],
    );
  });
}
