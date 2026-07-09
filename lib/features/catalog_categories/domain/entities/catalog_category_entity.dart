import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'catalog_category_entity.freezed.dart';

/// Product/listing category taxonomy from `/api/categories`. Distinct from
/// `home/domain/entities/category_entity.dart` (home-screen shortcuts,
/// different endpoint `/home/categories`) — named `catalog_categories` to
/// avoid the collision. Not wired into any screen yet (Phase 2: replace
/// `listing/presentation/data/listing_categories_data.dart`'s hardcoded list).
@freezed
class CatalogCategoryEntity with _$CatalogCategoryEntity {
  const factory CatalogCategoryEntity({
    required int id,
    required LocalizedText name,
    int? parentId,
  }) = _CatalogCategoryEntity;
}
