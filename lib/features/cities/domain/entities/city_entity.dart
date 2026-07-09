import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/localization/localized_text.dart';

part 'city_entity.freezed.dart';

@freezed
class CityEntity with _$CityEntity {
  const factory CityEntity({
    required int id,
    required LocalizedText name,
  }) = _CityEntity;
}
