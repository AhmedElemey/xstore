import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/product/domain/entities/review_entity.dart';

void main() {
  group('reviewAuthorLabel', () {
    test('uses the viewer display name for their own email userName', () {
      expect(
        reviewAuthorLabel(
          wireName: 'neciy31845@94an.com',
          reviewUserId: '2',
          viewerId: '2',
          viewerEmail: 'neciy31845@94an.com',
          viewerDisplayName: 'Neci',
        ),
        'Neci',
      );
    });

    test('matches own review by email when ids are missing', () {
      expect(
        reviewAuthorLabel(
          wireName: 'buyer@test.com',
          viewerEmail: 'buyer@test.com',
          viewerDisplayName: 'Test Buyer',
        ),
        'Test Buyer',
      );
    });

    test('treats matching userId as the viewer\'s own review', () {
      final review = ReviewEntity(
        id: 'r1',
        userId: '2',
        userName: 'neciy31845@94an.com',
        rating: 5,
        comment: 'good',
        createdAt: DateTime.utc(2026, 9, 13),
      );
      expect(isOwnReview(review, userId: '2', email: 'other@test.com'), isTrue);
      expect(isOwnReview(review, userId: '9', email: 'neciy31845@94an.com'), isTrue);
      expect(isOwnReview(review, userId: '9', email: 'other@test.com'), isFalse);
    });
  });
}
