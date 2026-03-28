import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/deal_entity.dart';

part 'deal_model.freezed.dart';
part 'deal_model.g.dart';

@freezed
class DealModel with _$DealModel {
  const factory DealModel({
    required String id,
    required String title,
    required double price,
    String? imageUrl,
    @Default(0.0) double discountPercent,
  }) = _DealModel;

  factory DealModel.fromJson(Map<String, dynamic> json) =>
      _$DealModelFromJson(json);
}

extension DealModelX on DealModel {
  DealEntity toEntity() => DealEntity(
        id: id,
        title: title,
        price: price,
        imageUrl: imageUrl,
        discountPercent: discountPercent,
      );
}
