import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/shared/utils/whatsapp.dart';

void main() {
  group('whatsAppDigits', () {
    test('local 01… becomes 20… for wa.me', () {
      expect(whatsAppDigits('01012345678'), '201012345678');
    });

    test('already-international +20 keeps country code digits', () {
      expect(whatsAppDigits('+20 10 1234 5678'), '201012345678');
    });

    test('null and blank are rejected', () {
      expect(whatsAppDigits(null), isNull);
      expect(whatsAppDigits(''), isNull);
      expect(whatsAppDigits('   '), isNull);
    });

    test('too-short numbers are rejected', () {
      expect(whatsAppDigits('010'), isNull);
    });
  });
}
