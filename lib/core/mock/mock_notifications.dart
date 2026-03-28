import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../router/app_routes.dart';
import 'mock_images.dart';

/// Role-specific mock feed; [anchor] is usually [DateTime.now()].
List<NotificationEntity> mockNotificationsForRole(
  UserRole role, {
  required DateTime anchor,
}) {
  return role == UserRole.vendor
      ? _vendorNotifications(anchor)
      : _consumerNotifications(anchor);
}

List<NotificationEntity> _consumerNotifications(DateTime n) {
  String order(String id) => AppRoutes.orderPath(id);
  String product(String id) => '${AppRoutes.product}/$id';

  return [
    NotificationEntity(
      id: 'notif_001',
      type: NotificationType.orderShipped,
      title: 'Your order is on the way! 🚀',
      body:
          'PS5 Console + 2 Controllers has been shipped. Track your delivery.',
      imageUrl: MockImages.product(90),
      actionRoute: order('XS-2024-002'),
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 2)),
    ),
    NotificationEntity(
      id: 'notif_002',
      type: NotificationType.priceDrop,
      title: 'Price Drop Alert! 💰',
      body:
          'iPhone 15 Pro dropped by 7% (200,000 → 185,000 DZD). Grab it before it\'s gone!',
      imageUrl: MockImages.product(10),
      actionRoute: product('listing_001'),
      discountPercent: 7,
      priceDropAmount: 15000,
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 4)),
    ),
    NotificationEntity(
      id: 'notif_003',
      type: NotificationType.flashSale,
      title: '⚡ Flash Sale starts in 1 hour!',
      body:
          'Up to 60% off on Electronics. Don\'t miss out — sale ends tonight!',
      actionRoute: '${AppRoutes.explore}?filter=flash_sale',
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 5)),
    ),
    NotificationEntity(
      id: 'notif_004',
      type: NotificationType.newMessage,
      title: 'New message from Ahmed\'s Electronics',
      body:
          'Ahmed: Hi! Your order has been prepared and will ship today.',
      imageUrl: MockImages.avatar(1),
      actionRoute: AppRoutes.chatThread('vendor_001'),
      senderName: 'Ahmed Bensalem',
      senderAvatar: MockImages.avatar(1),
      isRead: true,
      createdAt: n.subtract(const Duration(hours: 6)),
    ),
    NotificationEntity(
      id: 'notif_005',
      type: NotificationType.orderConfirmed,
      title: 'Order Confirmed ✅',
      body:
          'Ahmed\'s Electronics confirmed your order #XS-2024-002. Preparing now!',
      imageUrl: MockImages.product(130),
      actionRoute: order('XS-2024-002'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 1)),
    ),
    NotificationEntity(
      id: 'notif_006',
      type: NotificationType.backInStock,
      title: 'Back in Stock! 🎉',
      body:
          'Samsung Galaxy Tab S9 you wishlisted is back in stock. Order now!',
      imageUrl: MockImages.product(190),
      actionRoute: product('listing_019'),
      isRead: true,
      createdAt: n.subtract(const Duration(hours: 27)),
    ),
    NotificationEntity(
      id: 'notif_007',
      type: NotificationType.promotionalOffer,
      title: '🎁 Exclusive offer just for you!',
      body:
          'Use code SAVE10 for 10% off your next order. Valid for 48 hours only!',
      actionRoute: AppRoutes.explore,
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 29)),
    ),
    NotificationEntity(
      id: 'notif_008',
      type: NotificationType.orderDelivered,
      title: 'Order Delivered! 📦',
      body:
          'Your iPhone 15 Pro order has been delivered. How was your experience?',
      imageUrl: MockImages.product(10),
      actionRoute: order('XS-2024-001'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 3)),
    ),
    NotificationEntity(
      id: 'notif_009',
      type: NotificationType.reviewReply,
      title: 'Vendor replied to your review ⭐',
      body:
          'Ahmed replied: Thank you for your kind review! We hope to see you again.',
      imageUrl: MockImages.avatar(1),
      actionRoute: order('XS-2024-001'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 4)),
    ),
    NotificationEntity(
      id: 'notif_010',
      type: NotificationType.accountVerified,
      title: 'Account Verified! 🛡️',
      body:
          'Your xStore account has been verified. Enjoy all platform features.',
      isRead: true,
      createdAt: n.subtract(const Duration(days: 5)),
    ),
    NotificationEntity(
      id: 'notif_011',
      type: NotificationType.orderPlaced,
      title: 'Order placed',
      body: 'We received your order #XS-2024-010. The vendor will confirm soon.',
      actionRoute: order('XS-2024-010'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 10)),
    ),
    NotificationEntity(
      id: 'notif_012',
      type: NotificationType.promotionalOffer,
      title: 'Weekend sale',
      body: 'Extra 5% off this weekend on selected electronics.',
      actionRoute: AppRoutes.explore,
      isRead: false,
      createdAt: n.subtract(const Duration(days: 12)),
    ),
    NotificationEntity(
      id: 'notif_013',
      type: NotificationType.flashSale,
      title: 'Flash sale reminder',
      body: 'Electronics flash sale ends tonight.',
      actionRoute: AppRoutes.explore,
      isRead: true,
      createdAt: n.subtract(const Duration(days: 18)),
    ),
    NotificationEntity(
      id: 'notif_014',
      type: NotificationType.systemAnnouncement,
      title: 'Scheduled maintenance',
      body: 'xStore will be briefly unavailable Tuesday 2–3 AM.',
      isRead: true,
      createdAt: n.subtract(const Duration(days: 22)),
    ),
    NotificationEntity(
      id: 'notif_015',
      type: NotificationType.securityAlert,
      title: 'New sign-in',
      body: 'We noticed a login from a new device in Algiers.',
      isRead: true,
      createdAt: n.subtract(const Duration(days: 28)),
    ),
  ];
}

List<NotificationEntity> _vendorNotifications(DateTime n) {
  String order(String id) => AppRoutes.orderPath(id);
  String product(String id) => '${AppRoutes.product}/$id';

  return [
    NotificationEntity(
      id: 'notif_v001',
      type: NotificationType.newOrder,
      title: 'New Order Received! 🛍️',
      body:
          'Sara Khelifi ordered iPhone 15 Pro x1 for 185,000 DZD. Confirm now!',
      imageUrl: MockImages.avatar(2),
      actionRoute: order('XS-2024-001'),
      isRead: false,
      createdAt: n.subtract(const Duration(minutes: 30)),
    ),
    NotificationEntity(
      id: 'notif_v002',
      type: NotificationType.newOrder,
      title: 'New Order Received! 🛍️',
      body:
          'Karim Boudiaf ordered AirPods Pro x1 for 32,000 DZD. Confirm now!',
      imageUrl: MockImages.avatar(3),
      actionRoute: order('XS-2024-002'),
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 2)),
    ),
    NotificationEntity(
      id: 'notif_v003',
      type: NotificationType.newMessage,
      title: 'New message from Sara Khelifi',
      body:
          'Sara: Hi! Is the iPhone still available? Can you ship to Oran?',
      imageUrl: MockImages.avatar(2),
      actionRoute: AppRoutes.chatThread('consumer_001'),
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 3)),
    ),
    NotificationEntity(
      id: 'notif_v004',
      type: NotificationType.lowStock,
      title: '⚠️ Low Stock Alert',
      body:
          'PS5 Console + 2 Controllers has only 2 units left. Restock soon!',
      imageUrl: MockImages.product(90),
      actionRoute: product('listing_009'),
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 5)),
    ),
    NotificationEntity(
      id: 'notif_v005',
      type: NotificationType.listingApproved,
      title: 'Listing Approved ✅',
      body:
          'Your listing \'MacBook Pro M3 14"\' has been approved and is now live!',
      imageUrl: MockImages.product(50),
      actionRoute: product('listing_005'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 1)),
    ),
    NotificationEntity(
      id: 'notif_v006',
      type: NotificationType.paymentReceived,
      title: 'Payment Received 💰',
      body:
          'You received 185,000 DZD for order #XS-2024-001. Check your earnings.',
      actionRoute: AppRoutes.earnings,
      isRead: true,
      createdAt: n.subtract(const Duration(hours: 22)),
    ),
    NotificationEntity(
      id: 'notif_v007',
      type: NotificationType.newReview,
      title: 'New Review on Your Listing ⭐',
      body:
          'Karim B. left a 5-star review on iPhone 15 Pro. See what they said!',
      imageUrl: MockImages.avatar(3),
      actionRoute: product('listing_001'),
      isRead: false,
      createdAt: n.subtract(const Duration(hours: 20)),
    ),
    NotificationEntity(
      id: 'notif_v008',
      type: NotificationType.orderCancelledVendor,
      title: 'Order Cancelled ❌',
      body:
          'Amira S. cancelled order #XS-2024-005 for MacBook Pro. Reason: Changed mind.',
      actionRoute: order('XS-2024-005'),
      isRead: true,
      createdAt: n.subtract(const Duration(hours: 18)),
    ),
    NotificationEntity(
      id: 'notif_v009',
      type: NotificationType.listingRejected,
      title: 'Listing rejected',
      body:
          'Listing "USB-C Hub" was rejected: photos did not meet quality guidelines.',
      imageUrl: MockImages.product(12),
      actionRoute: product('listing_012'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 4)),
    ),
    NotificationEntity(
      id: 'notif_v010',
      type: NotificationType.newOrder,
      title: 'Order delivered',
      body: 'Order #XS-2024-099 was marked delivered by the buyer.',
      actionRoute: order('XS-2024-099'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 5)),
    ),
    NotificationEntity(
      id: 'notif_v011',
      type: NotificationType.paymentReceived,
      title: 'Payout processed',
      body: '32,000 DZD for order #XS-2024-088 is on the way.',
      actionRoute: AppRoutes.earnings,
      isRead: true,
      createdAt: n.subtract(const Duration(days: 7)),
    ),
    NotificationEntity(
      id: 'notif_v012',
      type: NotificationType.accountVerified,
      title: 'Store verified 🛡️',
      body: 'Your store passed verification. Buyers will see the verified badge.',
      isRead: true,
      createdAt: n.subtract(const Duration(days: 9)),
    ),
    NotificationEntity(
      id: 'notif_v013',
      type: NotificationType.systemAnnouncement,
      title: 'Seller tips',
      body: 'New tools for tracking conversions are available in Analytics.',
      isRead: true,
      createdAt: n.subtract(const Duration(days: 14)),
    ),
    NotificationEntity(
      id: 'notif_v014',
      type: NotificationType.lowStock,
      title: 'Stock running low',
      body: 'AirPods Pro listing has 3 units remaining.',
      imageUrl: MockImages.product(33),
      actionRoute: product('listing_033'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 18)),
    ),
    NotificationEntity(
      id: 'notif_v015',
      type: NotificationType.newReview,
      title: 'New 4★ review',
      body: 'A buyer reviewed Wireless Buds — tap to read feedback.',
      imageUrl: MockImages.avatar(4),
      actionRoute: product('listing_044'),
      isRead: true,
      createdAt: n.subtract(const Duration(days: 25)),
    ),
  ];
}
