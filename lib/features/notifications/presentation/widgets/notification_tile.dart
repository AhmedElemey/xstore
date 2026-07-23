import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/pulsing_dot.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_type_visual.dart';

export 'notification_type_visual.dart' show notificationTypeVisual;

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onDeleteConfirmed,
    required this.onSwipeMarkRead,
    required this.onMarkUnread,
    this.markAllReadAnimating = false,
  });

  final NotificationEntity entity;
  final VoidCallback onTap;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback onSwipeMarkRead;
  final VoidCallback onMarkUnread;
  final bool markAllReadAnimating;

  Future<void> _menu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final o = box.localToGlobal(Offset.zero, ancestor: overlay);
    final v = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(o.dx, o.dy, o.dx + 1, o.dy + 1),
      items: [
        PopupMenuItem(
          value: 't',
          child: Text(entity.isRead ? context.l10n.notificationsMenuMarkUnread : context.l10n.notificationsMenuMarkRead),
        ),
        PopupMenuItem(value: 'd', child: Text(context.l10n.notificationsMenuDelete)),
        PopupMenuItem(value: 'c', child: Text(context.l10n.notificationsMenuCopy)),
      ],
    );
    if (!context.mounted) return;
    if (v == 't') {
      if (entity.isRead) {
        onMarkUnread();
      } else {
        onSwipeMarkRead();
      }
    }
    if (v == 'd') onDeleteConfirmed();
    if (v == 'c') {
      final copiedMessage = context.l10n.notificationsCopied;
      await Clipboard.setData(ClipboardData(text: '${entity.title}\n${entity.body}'));
      if (!context.mounted) return;
      AppSnackbar.success(context, copiedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nv = notificationTypeVisual(entity.type);
    final u = !entity.isRead;
    final dur = markAllReadAnimating ? const Duration(milliseconds: 320) : Duration.zero;
    final img = entity.imageUrl;
    final thumb = img != null && img.isNotEmpty;
    return Dismissible(
      key: ValueKey<String>(entity.id),
      direction: u ? DismissDirection.horizontal : DismissDirection.endToStart,
      confirmDismiss: (d) async {
        if (d == DismissDirection.startToEnd) {
          if (u) onSwipeMarkRead();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDeleteConfirmed(),
      background: ExcludeSemantics(
        child: ColoredBox(
          color: AppColors.primary,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.check, color: AppColors.white),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    context.l10n.notificationsSwipeMarkRead,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      secondaryBackground: ExcludeSemantics(
        child: ColoredBox(
          color: AppColors.error,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.notificationsSwipeDelete,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  const Icon(LucideIcons.trash2, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: dur,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: u
                ? AppColors.notificationUnreadBackground
                : context.surfaceColor,
            border: Border(
              left: BorderSide(
                color: u ? AppColors.primary : AppColors.transparent,
                width: AppSpacing.xs - 1,
              ),
            ),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: () => _menu(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: AppSpacing.x4l,
                      height: AppSpacing.x4l,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: AppSpacing.x4l / 2,
                            backgroundColor: nv.bg,
                            child: Icon(nv.ic, color: nv.fg, size: AppSpacing.x2l - AppSpacing.xs),
                          ),
                          if (u)
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: PulsingDot(
                                size: AppSpacing.sm,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  entity.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight:
                                        u ? FontWeight.w700 : FontWeight.w500,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                Formatters.formatNotificationTime(entity.createdAt),
                                style: AppTypography.labelSmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            entity.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (thumb) SizedBox(width: AppSpacing.sm),
                    if (thumb)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        child: AppCachedNetworkImage(
                          imageUrl: img,
                          width: AppSpacing.x4l,
                          height: AppSpacing.x4l,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              ColoredBox(color: context.textDisabled),
                          errorWidget: (_, __, ___) =>
                              ColoredBox(color: context.textDisabled),
                        ),
                      ),
                    if (thumb) SizedBox(width: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Icon(
                        context.chevronForward,
                        size: AppSpacing.x2l - AppSpacing.xs,
                        color: context.iconSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
