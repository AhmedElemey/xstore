import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../domain/entities/notification_entity.dart';

/// One icon per notification type (drawn on an Orbit orb).
IconData notificationTypeIcon(NotificationType t) => switch (t) {
      NotificationType.orderPlaced => LucideIcons.package,
      NotificationType.orderConfirmed => LucideIcons.checkCircle2,
      NotificationType.orderShipped => LucideIcons.truck,
      NotificationType.orderDelivered => LucideIcons.home,
      NotificationType.orderCancelled => LucideIcons.xCircle,
      NotificationType.priceDrop => LucideIcons.trendingDown,
      NotificationType.backInStock => LucideIcons.refreshCw,
      NotificationType.flashSale => LucideIcons.zap,
      NotificationType.newMessage => LucideIcons.messageCircle,
      NotificationType.reviewReply => LucideIcons.star,
      NotificationType.promotionalOffer => LucideIcons.tag,
      NotificationType.newOrder => LucideIcons.shoppingBag,
      NotificationType.listingApproved => LucideIcons.checkCircle2,
      NotificationType.listingRejected => LucideIcons.xCircle,
      NotificationType.paymentReceived => LucideIcons.creditCard,
      NotificationType.lowStock => LucideIcons.alertTriangle,
      NotificationType.orderCancelledVendor => LucideIcons.xCircle,
      NotificationType.newReview => LucideIcons.star,
      NotificationType.accountVerified => LucideIcons.shieldCheck,
      NotificationType.systemAnnouncement => LucideIcons.bell,
      NotificationType.securityAlert => LucideIcons.shieldAlert,
    };
