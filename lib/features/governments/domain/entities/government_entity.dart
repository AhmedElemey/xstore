import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'government_entity.freezed.dart';

/// Top-level Egyptian governorate from `/api/governorates`.
///
/// Live GET (2026-08-23) is a bare list of `{id, nameEn, nameAr}`. Older
/// hosts wrapped the same rows in `{items, totalCount}`. Older docs linked a
/// government *down* to a city via `cityId`; that link is gone — cities now
/// point *up* via `CityEntity.governorateId`. [cityId] is kept for tolerant
/// parsing of any leftover payloads.
@freezed
class GovernmentEntity with _$GovernmentEntity {
  const factory GovernmentEntity({
    required int id,
    required LocalizedText name,
    int? cityId,
  }) = _GovernmentEntity;
}
