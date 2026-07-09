import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'government_entity.freezed.dart';

/// NOTE: per the API spec, POST/PUT bodies are `{nameEn, nameAr, cityId}` —
/// a government belongs to a city. This inverts Egypt's usual real-world
/// hierarchy (Government -> City) — worth confirming with the backend dev.
@freezed
class GovernmentEntity with _$GovernmentEntity {
  const factory GovernmentEntity({
    required int id,
    required LocalizedText name,
    int? cityId,
  }) = _GovernmentEntity;
}
