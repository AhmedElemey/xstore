import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

/// Consumer, vendor, or shared notification kinds (`newMessage` is used for both roles).
enum NotificationType {
  orderPlaced,
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,
  priceDrop,
  backInStock,
  flashSale,
  newMessage,
  reviewReply,
  promotionalOffer,
  newOrder,
  orderCancelledVendor,
  newReview,
  listingApproved,
  listingRejected,
  paymentReceived,
  lowStock,
  accountVerified,
  systemAnnouncement,
  securityAlert,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required NotificationType type,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    required String title,
    required String body,
    String? imageUrl,
    String? actionRoute,
    Map<String, dynamic>? actionData,
    @Default(false) bool isRead,
    required DateTime createdAt,
    String? orderId,
    String? listingId,
    String? reviewId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    int? discountPercent,
    double? priceDropAmount,
  }) = _NotificationEntity;
}

@freezed
class NotificationGroup with _$NotificationGroup {
  const factory NotificationGroup({
    required String label,
    required List<NotificationEntity> notifications,
  }) = _NotificationGroup;
}
