import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
