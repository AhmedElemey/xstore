import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/government_entity.dart';

class GovernmentModel {
  const GovernmentModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.cityId,
  });

  factory GovernmentModel.fromJson(Map<String, dynamic> json) =>
      GovernmentModel(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        cityId: json['cityId'] as int?,
      );

  final int id;
  final String nameEn;
  final String nameAr;
  final int? cityId;
}

extension GovernmentModelX on GovernmentModel {
  GovernmentEntity toEntity() => GovernmentEntity(
        id: id,
        name: LocalizedText(en: nameEn, ar: nameAr),
        cityId: cityId,
      );
}
