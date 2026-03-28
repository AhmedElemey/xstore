import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_entity.freezed.dart';

@freezed
class ReviewEntity with _$ReviewEntity {
  const factory ReviewEntity({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required double rating,
    required String comment,
    @Default(0) int helpfulCount,
    required DateTime createdAt,
  }) = _ReviewEntity;
}
