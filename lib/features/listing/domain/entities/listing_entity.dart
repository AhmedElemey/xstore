import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_entity.freezed.dart';

enum ListingStatus {
  draft,
  pending,
  active,
}

@freezed
class ListingEntity with _$ListingEntity {
  const factory ListingEntity({
    required String id,
    required String title,
    required String description,
    required double price,
    required ListingStatus status,
    @Default(<String>[]) List<String> imageUrls,
  }) = _ListingEntity;
}
