import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final o = box.localToGlobal(Offset.zero, ancestor: overlay);
    final v = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(o.dx, o.dy, o.dx + 1, o.dy + 1),
      items: [
        PopupMenuItem(
          value: 't',
          child: Text(
            entity.isRead
                ? context.l10n.notificationsMenuMarkUnread
                : context.l10n.notificationsMenuMarkRead,
          ),
        ),
        PopupMenuItem(
          value: 'd',
          child: Text(context.l10n.notificationsMenuDelete),
        ),
        PopupMenuItem(
          value: 'c',
          child: Text(context.l10n.notificationsMenuCopy),
        ),
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
      await Clipboard.setData(
        ClipboardData(text: '${entity.title}\n${entity.body}'),
      );
      if (!context.mounted) return;
      AppSnackbar.success(context, copiedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nv = notificationTypeVisual(entity.type);
    final u = !entity.isRead;
    final dur = markAllReadAnimating
        ? const Duration(milliseconds: 320)
        : Duration.zero;
    final img = entity.imageUrl;
    final thumb = img != null && img.isNotEmpty;
    final brand = context.isDark ? AppColors.primaryLight : AppColors.primary;
    final dismissible = Dismissible(
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
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
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
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
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
            borderRadius: BorderRadius.circular(20),
            color: u ? brand.withValues(alpha: 0.07) : context.glassColor,
            border: Border.all(
              color: u ? brand.withValues(alpha: 0.3) : context.borderColor,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              onLongPress: () => _menu(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.4),
                                colors: [
                                  Color.lerp(nv.fg, AppColors.white, 0.8)!,
                                  nv.fg,
                                  Color.lerp(nv.fg, AppColors.black, 0.5)!,
                                ],
                                stops: const [0, 0.45, 1],
                              ),
                            ),
                            child: SizedBox.square(
                              dimension: 40,
                              child: Icon(
                                nv.ic,
                                color: context.isDark
                                    ? AppColors.darkOnBrand
                                    : AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          if (u)
                            PositionedDirectional(
                              end: 0,
                              bottom: 0,
                              child: PulsingDot(
                                size: AppSpacing.sm,
                                color: brand,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entity.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: u ? FontWeight.w800 : FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entity.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (thumb) ...[
                      const SizedBox(width: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        child: AppCachedNetworkImage(
                          imageUrl: img,
                          width: AppSpacing.x4l,
                          height: AppSpacing.x4l,
                          fit: BoxFit.cover,
                          memCacheWidth: 192,
                          memCacheHeight: 192,
                          placeholder: (_, __) =>
                              ColoredBox(color: context.textDisabled),
                          errorWidget: (_, __, ___) =>
                              ColoredBox(color: context.textDisabled),
                        ),
                      ),
                    ],
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      Formatters.formatNotificationTime(
                        entity.createdAt,
                        context.l10n,
                      ),
                      style: AppTypography.labelMedium.copyWith(
                        color: context.labelColor,
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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: dismissible,
      ),
    );
  }
}
