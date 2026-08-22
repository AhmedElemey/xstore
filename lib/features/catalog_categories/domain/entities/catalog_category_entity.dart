import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'catalog_category_entity.freezed.dart';

/// Product/listing category taxonomy from `GET /api/categories`. Distinct from
/// `home/domain/entities/category_entity.dart` (home-screen chips from the
/// same endpoint, top-level only) — named `catalog_categories` to avoid the
/// collision.
///
/// Live shape: a bare list of top-level categories; each embeds its
/// subcategories in `children` (those children already carry `parentId`).
@freezed
class CatalogCategoryEntity with _$CatalogCategoryEntity {
  const factory CatalogCategoryEntity({
    required int id,
    required LocalizedText name,
    int? parentId,
    @Default(<CatalogCategoryEntity>[]) List<CatalogCategoryEntity> children,
  }) = _CatalogCategoryEntity;
}
