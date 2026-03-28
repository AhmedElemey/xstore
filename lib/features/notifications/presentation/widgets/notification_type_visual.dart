import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification_entity.dart';

typedef NotificationTypeVisual = ({Color bg, Color fg, IconData ic});

/// Single map-style switch: one icon + colors per notification type.
NotificationTypeVisual notificationTypeVisual(NotificationType t) => switch (t) {
      NotificationType.orderPlaced => (
          bg: AppColors.notificationIconTintGreen,
          fg: AppColors.success,
          ic: LucideIcons.package
        ),
      NotificationType.orderConfirmed => (
          bg: AppColors.notificationIconTintBlue,
          fg: AppColors.orderStatusConfirmed,
          ic: LucideIcons.checkCircle2
        ),
      NotificationType.orderShipped => (
          bg: AppColors.notificationIconTintPurple,
          fg: AppColors.orderStatusShipped,
          ic: LucideIcons.truck
        ),
      NotificationType.orderDelivered => (
          bg: AppColors.notificationIconTintGreen,
          fg: AppColors.orderStatusDelivered,
          ic: LucideIcons.home
        ),
      NotificationType.orderCancelled => (
          bg: AppColors.notificationIconTintRed,
          fg: AppColors.error,
          ic: LucideIcons.xCircle
        ),
      NotificationType.priceDrop => (
          bg: AppColors.notificationIconTintOrange,
          fg: AppColors.accent,
          ic: LucideIcons.trendingDown
        ),
      NotificationType.backInStock => (
          bg: AppColors.notificationIconTintGreen,
          fg: AppColors.success,
          ic: LucideIcons.refreshCw
        ),
      NotificationType.flashSale => (
          bg: AppColors.notificationIconTintOrange,
          fg: AppColors.accent,
          ic: LucideIcons.zap
        ),
      NotificationType.newMessage => (
          bg: AppColors.notificationIconTintBlue,
          fg: AppColors.primary,
          ic: LucideIcons.messageCircle
        ),
      NotificationType.reviewReply => (
          bg: AppColors.notificationIconTintPurple,
          fg: AppColors.orderStatusShipped,
          ic: LucideIcons.star
        ),
      NotificationType.promotionalOffer => (
          bg: AppColors.notificationIconTintOrange,
          fg: AppColors.accent,
          ic: LucideIcons.tag
        ),
      NotificationType.newOrder => (
          bg: AppColors.notificationIconTintOrange,
          fg: AppColors.accent,
          ic: LucideIcons.shoppingBag
        ),
      NotificationType.listingApproved => (
          bg: AppColors.notificationIconTintGreen,
          fg: AppColors.success,
          ic: LucideIcons.checkCircle2
        ),
      NotificationType.listingRejected => (
          bg: AppColors.notificationIconTintRed,
          fg: AppColors.error,
          ic: LucideIcons.xCircle
        ),
      NotificationType.paymentReceived => (
          bg: AppColors.notificationIconTintGreen,
          fg: AppColors.success,
          ic: LucideIcons.creditCard
        ),
      NotificationType.lowStock => (
          bg: AppColors.notificationIconTintAmber,
          fg: AppColors.warning,
          ic: LucideIcons.alertTriangle
        ),
      NotificationType.orderCancelledVendor => (
          bg: AppColors.notificationIconTintRed,
          fg: AppColors.error,
          ic: LucideIcons.xCircle
        ),
      NotificationType.newReview => (
          bg: AppColors.notificationIconTintPurple,
          fg: AppColors.orderStatusShipped,
          ic: LucideIcons.star
        ),
      NotificationType.accountVerified => (
          bg: AppColors.notificationIconTintBlue,
          fg: AppColors.primary,
          ic: LucideIcons.shieldCheck
        ),
      NotificationType.systemAnnouncement => (
          bg: AppColors.notificationIconTintBlue,
          fg: AppColors.primary,
          ic: LucideIcons.bell
        ),
      NotificationType.securityAlert => (
          bg: AppColors.notificationIconTintRed,
          fg: AppColors.error,
          ic: LucideIcons.shieldAlert
        ),
    };
