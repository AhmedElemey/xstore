import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/explore/presentation/explore_provider.dart';

void main() {
  group('scrubSearchQueryForAnalytics', () {
    for (final (input, expected) in [
      ('01012345678', '[number]'),
      ('call 010 1234 5678 now', 'call [number] now'),
      ('+20 10-1234-5678', '[number]'),
      ('٠١٠١٢٣٤٥٦٧٨', '[number]'),
      ('۰۱۰۱۲۳۴۵۶۷۸', '[number]'),
      ('seller ahmed@mail.com', 'seller [email]'),
      // Product words and short numbers stay.
      ('iphone 15 pro 256', 'iphone 15 pro 256'),
      ('tv 55 inch 2024', 'tv 55 inch 2024'),
      ('سماعة بلوتوث', 'سماعة بلوتوث'),
    ]) {
      test('"$input" → "$expected"', () {
        expect(scrubSearchQueryForAnalytics(input), expected);
      });
    }
  });
}
