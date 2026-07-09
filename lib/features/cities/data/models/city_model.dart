import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/city_entity.dart';

class CityModel {
  const CityModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
      );

  final int id;
  final String nameEn;
  final String nameAr;
}

extension CityModelX on CityModel {
  CityEntity toEntity() =>
      CityEntity(id: id, name: LocalizedText(en: nameEn, ar: nameAr));
}
