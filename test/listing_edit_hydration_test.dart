import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';

const _draftKey = 'xstore_listing_form_draft';

const _editingListing = ListingEntity(
  id: '42',
  title: 'Old Title',
  description: 'Old description',
  price: 199.5,
  status: ListingStatus.paused,
  titleEn: 'Wireless Mouse',
  descriptionEn: 'A great wireless mouse',
  imageUrls: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
  compareAtPrice: 249,
  categoryId: 7,
  subcategoryId: 32,
  condition: ListingCondition.likeNew,
  brand: 'Logitech',
  stockQuantity: 3,
  shippingAvailable: true,
  shippingCost: 25,
  location: 'Cairo',
  attributes: {'Color': 'Black'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadForEdit hydrates the form from an existing listing', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(listingFormNotifierProvider.notifier);
    notifier.prepareForEdit(_editingListing);
    notifier.loadForEdit(_editingListing);

    final state = container.read(listingFormNotifierProvider);
    expect(state.editingListingId, '42');
    expect(state.editingStatus, ListingStatus.paused);
    expect(state.name, 'Wireless Mouse');
    expect(state.priceInput, '199.50');
    expect(state.compareAtPriceInput, '249.00');
    expect(state.description, 'A great wireless mouse');
    expect(state.categoryId, '7');
    expect(state.subcategoryId, '32');
    expect(state.condition, 'Like New');
    expect(state.brand, 'Logitech');
    expect(state.quantity, 3);
    expect(state.location, 'Cairo');
    expect(state.shippingAvailable, isTrue);
    expect(state.shippingCostInput, '25.00');
    expect(state.attributes.map((a) => (a.key, a.value)), [('Color', 'Black')]);
    expect(state.existingImageUrls, _editingListing.imageUrls);
    expect(state.photoPaths, isEmpty);
  });

  test(
    'prepareForEdit makes the pending create-flow draft load skip itself',
    () async {
      SharedPreferences.setMockInitialValues({
        _draftKey: jsonEncode({'name': 'Stale Draft Product'}),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Keep the autoDispose notifier alive across the awaits below —
      // mirrors AddListingScreen's continuous ref.watch in build(); a bare
      // container.read() alone doesn't hold a listener, so without this the
      // provider gets reclaimed and silently rebuilds from scratch.
      container.listen(listingFormNotifierProvider, (_, __) {});

      final notifier = container.read(listingFormNotifierProvider.notifier);
      // Mirrors AddListingScreen.initState(): flag edit mode synchronously,
      // in the same call stack as notifier creation, before the draft-load
      // microtask (scheduled by build()) gets a chance to run.
      notifier.prepareForEdit(_editingListing);

      // Let the guarded _loadDraft microtask run to completion; it must
      // see the flag and return early rather than applying the stale draft.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      notifier.loadForEdit(_editingListing);

      final state = container.read(listingFormNotifierProvider);
      expect(state.name, 'Wireless Mouse');
      expect(state.editingListingId, '42');
    },
  );

  test('quantity below 1 is clamped up so the form stays submittable', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final soldOut = _editingListing.copyWith(stockQuantity: 0);
    final notifier = container.read(listingFormNotifierProvider.notifier);
    notifier.loadForEdit(soldOut);

    expect(container.read(listingFormNotifierProvider).quantity, 1);
  });

  test('reset clears the form and bumps draftRevision for controller sync', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(listingFormNotifierProvider, (_, __) {});

    final notifier = container.read(listingFormNotifierProvider.notifier);
    notifier.loadForEdit(_editingListing);
    final revision = container.read(listingFormNotifierProvider).draftRevision;
    expect(container.read(listingFormNotifierProvider).name, 'Wireless Mouse');

    notifier.reset();

    final state = container.read(listingFormNotifierProvider);
    expect(state.name, isEmpty);
    expect(state.priceInput, isEmpty);
    expect(state.categoryId, isEmpty);
    expect(state.editingListingId, isEmpty);
    expect(state.photoPaths, isEmpty);
    expect(state.draftRevision, revision + 1);
  });

  test('changing category clears subcategory, attributes, and brand', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(listingFormNotifierProvider, (_, __) {});

    final notifier = container.read(listingFormNotifierProvider.notifier);
    notifier.loadForEdit(_editingListing);
    expect(container.read(listingFormNotifierProvider).brand, 'Logitech');
    expect(container.read(listingFormNotifierProvider).subcategoryId, '32');

    notifier.updateField('categoryId', '9');

    final state = container.read(listingFormNotifierProvider);
    expect(state.categoryId, '9');
    expect(state.subcategoryId, isEmpty);
    expect(state.brand, isEmpty);
    expect(state.attributes, isEmpty);
  });

  test('changing subcategory clears brand', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(listingFormNotifierProvider, (_, __) {});

    final notifier = container.read(listingFormNotifierProvider.notifier);
    notifier.loadForEdit(_editingListing);
    expect(container.read(listingFormNotifierProvider).brand, 'Logitech');

    notifier.updateField('subcategoryId', '99');

    final state = container.read(listingFormNotifierProvider);
    expect(state.subcategoryId, '99');
    expect(state.brand, isEmpty);
    expect(state.categoryId, '7');
  });
}
