import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/catalog_category_entity.dart';

class CatalogCategoryModel {
  const CatalogCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
  });

  factory CatalogCategoryModel.fromJson(Map<String, dynamic> json) =>
      CatalogCategoryModel(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        parentId: json['parentId'] as int?,
      );

  final int id;
  final String nameEn;
  final String nameAr;
  final int? parentId;
}

extension CatalogCategoryModelX on CatalogCategoryModel {
  CatalogCategoryEntity toEntity() => CatalogCategoryEntity(
        id: id,
        name: LocalizedText(en: nameEn, ar: nameAr),
        parentId: parentId,
      );
}
