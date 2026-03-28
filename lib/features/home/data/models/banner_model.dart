import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/banner_entity.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
class BannerModel with _$BannerModel {
  const factory BannerModel({
    required String id,
    required String title,
    required String imageUrl,
    String? actionUrl,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
}

extension BannerModelX on BannerModel {
  BannerEntity toEntity() => BannerEntity(
        id: id,
        title: title,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );
}
