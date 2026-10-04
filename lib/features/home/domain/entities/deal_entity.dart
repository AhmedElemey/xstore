import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_entity.freezed.dart';

@freezed
class DealEntity with _$DealEntity {
  const factory DealEntity({
    required String id,
    required String title,
    required double price,
    String? imageUrl,
    @Default(0.0) double discountPercent,
    @Default(false) bool isSoldOut,
  }) = _DealEntity;
}
