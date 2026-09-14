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

/// Live reviews send Identity `userName` (the login email). Prefer the
/// viewer's display name for their own review, and never keep an email
/// when a real name is available.
String reviewAuthorLabel({
  required String wireName,
  String? reviewUserId,
  String? viewerId,
  String? viewerEmail,
  String? viewerDisplayName,
}) {
  final wire = wireName.trim();
  final self = viewerDisplayName?.trim() ?? '';
  final selfOk = self.isNotEmpty && !_looksLikeEmail(self);
  final mine = (viewerId != null &&
          reviewUserId != null &&
          viewerId == reviewUserId) ||
      (_looksLikeEmail(wire) &&
          viewerEmail != null &&
          wire.toLowerCase() == viewerEmail.toLowerCase());
  if (mine && selfOk) return self;
  if (wire.isNotEmpty && !_looksLikeEmail(wire)) return wire;
  return selfOk ? self : wire;
}

bool isOwnReview(
  ReviewEntity review, {
  String? userId,
  String? email,
}) {
  if (userId != null && userId.isNotEmpty && review.userId == userId) {
    return true;
  }
  final mail = email?.trim().toLowerCase();
  if (mail == null || mail.isEmpty) return false;
  return review.userName.trim().toLowerCase() == mail;
}

bool _looksLikeEmail(String value) => value.contains('@');
