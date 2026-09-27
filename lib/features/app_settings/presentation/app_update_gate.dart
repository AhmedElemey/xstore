import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../domain/app_settings.dart';
import 'app_settings_providers.dart';

const _androidStoreFallback =
    'https://play.google.com/store/apps/details?id=com.xstore.app';

/// No App Store listing id yet — admins set `ios_store_url` once it exists.
const _iosStoreFallback = 'https://apps.apple.com';

/// Sits above the router (in `MaterialApp.builder`, like [OfflineBannerHost])
/// and overlays the app when `GET /api/app-settings` says this version is
/// too old: a full-screen block for a required update, a dismissible card
/// for an optional one. No Navigator/Overlay exists at this level, so it
/// uses plain Material buttons (no tooltips or dialogs).
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> {
  /// "Later" hides the optional prompt for the rest of this launch.
  bool _dismissed = false;

  Future<void> _openStore() async {
    final settings =
        ref.read(appSettingsProvider).valueOrNull ?? AppSettings.empty;
    final url = defaultTargetPlatform == TargetPlatform.iOS
        ? settings.valueOf(AppSettingKeys.iosStoreUrl, _iosStoreFallback)
        : settings.valueOf(
            AppSettingKeys.androidStoreUrl,
            _androidStoreFallback,
          );
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final requirement = ref.watch(appUpdateRequirementProvider);

    // Always two children, same slots: inserting or removing a sibling above
    // the navigator remounts every route (see OfflineBannerHost).
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: switch (requirement) {
            AppUpdateRequirement.required => _RequiredUpdateView(
              onUpdate: _openStore,
            ),
            AppUpdateRequirement.optional when !_dismissed => Align(
              alignment: Alignment.bottomCenter,
              child: _OptionalUpdateCard(
                onUpdate: _openStore,
                onLater: () => setState(() => _dismissed = true),
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _RequiredUpdateView extends StatelessWidget {
  const _RequiredUpdateView({required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.downloadCloud,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.spacing28),
              Text(
                l10n.updateRequiredTitle,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.updateRequiredMessage,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacing28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onUpdate,
                  child: Text(l10n.updateNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionalUpdateCard extends StatelessWidget {
  const _OptionalUpdateCard({required this.onUpdate, required this.onLater});

  final VoidCallback onUpdate;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.updateAvailableTitle,
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.updateAvailableMessage,
                  style: AppTypography.bodySmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: onLater, child: Text(l10n.later)),
                    TextButton(
                      onPressed: onUpdate,
                      child: Text(l10n.updateNow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
