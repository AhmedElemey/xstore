import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/cities/data/models/city_model.dart';

void main() {
  group('CityModel.fromJson', () {
    test('parses governorateId as parent link', () {
      final city = CityModel.fromJson({
        'id': 1,
        'nameEn': 'Cairo',
        'nameAr': 'القاهرة',
        'governorateId': 16,
      });
      expect(city.id, 1);
      expect(city.governorateId, 16);
      expect(city.toEntity().governorateId, 16);
    });

    test('falls back to legacy governmentId key', () {
      final city = CityModel.fromJson({
        'id': 2,
        'nameEn': 'Alexandria',
        'nameAr': 'الإسكندرية',
        'governmentId': 15,
      });
      expect(city.governorateId, 15);
    });
  });
}
