import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/store_category_entity.dart';

class StoreCategoryModel {
  const StoreCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) =>
      StoreCategoryModel(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
      );

  final int id;
  final String nameEn;
  final String nameAr;
}

extension StoreCategoryModelX on StoreCategoryModel {
  StoreCategoryEntity toEntity() => StoreCategoryEntity(
        id: id,
        name: LocalizedText(en: nameEn, ar: nameAr),
      );
}
