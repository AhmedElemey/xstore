import '../../../../core/localization/localized_text.dart';
import '../../domain/entities/catalog_category_entity.dart';

class CatalogCategoryModel {
  const CatalogCategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
    this.isActive = true,
    this.children = const [],
  });

  factory CatalogCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] ??
        json['subCategories'] ??
        json['subcategories'];
    final children = rawChildren is List
        ? rawChildren
            .whereType<Map>()
            .map(
              (e) => CatalogCategoryModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .where((c) => c.isActive && c.id != 0)
            .toList()
        : const <CatalogCategoryModel>[];
    final parentId = _asInt(json['parentId']);
    return CatalogCategoryModel(
      id: _asInt(json['id']) ?? 0,
      nameEn: _asString(json['nameEn']) ?? _asString(json['name']) ?? '',
      nameAr: _asString(json['nameAr']) ?? '',
      parentId: parentId == null || parentId == 0 ? null : parentId,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      children: children,
    );
  }

  static String? _asString(Object? value) {
    if (value is String) {
      return value;
    }
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  final int id;
  final String nameEn;
  final String nameAr;
  final int? parentId;
  final bool isActive;
  final List<CatalogCategoryModel> children;
}

extension CatalogCategoryModelX on CatalogCategoryModel {
  CatalogCategoryEntity toEntity() => CatalogCategoryEntity(
        id: id,
        name: LocalizedText(en: nameEn, ar: nameAr),
        parentId: parentId,
        children: children.map((c) => c.toEntity()).toList(),
      );
}
