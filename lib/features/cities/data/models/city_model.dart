import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/city_entity.dart';

class CityModel {
  const CityModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.governorateId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        // Live wire key is `governorateId` (city → parent governorate).
        // Older seeds/docs used `governmentId`; accept both.
        governorateId:
            json['governorateId'] as int? ?? json['governmentId'] as int?,
      );

  final int id;
  final String nameEn;
  final String nameAr;
  final int? governorateId;
}

extension CityModelX on CityModel {
  CityEntity toEntity() => CityEntity(
        id: id,
        name: LocalizedText(en: nameEn, ar: nameAr),
        governorateId: governorateId,
      );
}
