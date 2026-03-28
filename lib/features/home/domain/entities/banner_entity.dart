import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_entity.freezed.dart';

@freezed
class BannerEntity with _$BannerEntity {
  const factory BannerEntity({
    required String id,
    required String title,
    required String imageUrl,
    String? actionUrl,
  }) = _BannerEntity;
}
