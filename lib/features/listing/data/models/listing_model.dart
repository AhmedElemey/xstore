import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/listing_entity.dart';

part 'listing_model.freezed.dart';
part 'listing_model.g.dart';

@freezed
class ListingModel with _$ListingModel {
  const factory ListingModel({
    required String id,
    required String title,
    required String description,
    required double price,
    @Default('draft') String status,
    @Default(<String>[]) List<String> imageUrls,
  }) = _ListingModel;

  factory ListingModel.fromJson(Map<String, dynamic> json) =>
      _$ListingModelFromJson(json);
}

ListingStatus _listingStatusFromDto(String value) {
  switch (value) {
    case 'pending':
      return ListingStatus.pending;
    case 'active':
      return ListingStatus.active;
    case 'draft':
    default:
      return ListingStatus.draft;
  }
}

extension ListingModelX on ListingModel {
  ListingEntity toEntity() => ListingEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        status: _listingStatusFromDto(status),
        imageUrls: imageUrls,
      );
}
