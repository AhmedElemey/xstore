import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'store_category_entity.freezed.dart';

@freezed
class StoreCategoryEntity with _$StoreCategoryEntity {
  const factory StoreCategoryEntity({
    required int id,
    required LocalizedText name,
  }) = _StoreCategoryEntity;
}
