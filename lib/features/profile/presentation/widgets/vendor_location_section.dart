import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/location_service.dart';
import '../providers/profile_provider.dart';
import 'detect_location_button.dart';
import 'lat_lng_field_row.dart';

class VendorLocationSection extends ConsumerWidget {
  const VendorLocationSection({
    super.key,
    required this.latController,
    required this.lngController,
    required this.governorateController,
    required this.townController,
    required this.detailAddressController,
  });

  final TextEditingController latController;
  final TextEditingController lngController;
  final TextEditingController governorateController;
  final TextEditingController townController;
  final TextEditingController detailAddressController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileNotifierProvider);
    final n = ref.read(profileNotifierProvider.notifier);
    final latErr = s.editLatitude.isNotEmpty && !LocationService.isValidLatitude(s.editLatitude) ? context.l10n.invalidLatitude : null;
    final lngErr = s.editLongitude.isNotEmpty && !LocationService.isValidLongitude(s.editLongitude) ? context.l10n.invalidLongitude : null;
    final hasCoords = s.editLatitude.isNotEmpty && s.editLongitude.isNotEmpty && latErr == null && lngErr == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 18), const Gap(AppSpacing.xs), Text(context.l10n.storeLocation, style: AppTypography.titleMedium)]),
        const Gap(AppSpacing.xs),
        Text(context.l10n.storeLocationSubtitle, style: AppTypography.bodySmall.copyWith(color: context.textSecondary)),
        const Gap(AppSpacing.md),
        DetectLocationButton(isLoading: s.isDetectingLocation, onTap: n.detectCurrentLocation),
        if (s.locationError != null) ...[
          const Gap(AppSpacing.sm),
          Row(children: [const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.error), const Gap(AppSpacing.xs), Expanded(child: Text(_errorText(context, s.locationError!), style: AppTypography.bodySmall.copyWith(color: AppColors.error)))]),
        ],
        const Gap(AppSpacing.md),
        Row(children: [Expanded(child: Divider(color: context.dividerColor)), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), child: Text(context.l10n.orFillManually, style: AppTypography.bodySmall.copyWith(color: context.textSecondary))), Expanded(child: Divider(color: context.dividerColor))]),
        const Gap(AppSpacing.md),
        LatLngFieldRow(latController: latController, lngController: lngController, onLatChanged: n.updateLatitude, onLngChanged: n.updateLongitude, latError: latErr, lngError: lngErr),
        const Gap(AppSpacing.md),
        _field(context, context.l10n.governorate, context.l10n.governorateHint, LucideIcons.building2, governorateController, n.updateGovernorate),
        const Gap(AppSpacing.md),
        _field(context, context.l10n.townCity, context.l10n.townCityHint, LucideIcons.mapPin, townController, n.updateTown),
        const Gap(AppSpacing.md),
        _field(context, context.l10n.detailAddress, context.l10n.detailAddressHint, LucideIcons.navigation, detailAddressController, n.updateDetailAddress, maxLines: 3),
        if (hasCoords) ...[
          const Gap(AppSpacing.md),
          _LocationPreviewCard(latitude: s.editLatitude, longitude: s.editLongitude, governorate: s.editGovernorate, town: s.editTown),
        ],
      ],
    );
  }
}

Widget _field(BuildContext context, String label, String hint, IconData icon, TextEditingController controller, ValueChanged<String> onChanged, {int maxLines = 1}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    maxLines: maxLines,
    textCapitalization: maxLines > 1 ? TextCapitalization.sentences : TextCapitalization.words,
    decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
  );
}

String _errorText(BuildContext context, String key) {
  switch (key) {
    case 'locationServiceDisabled': return context.l10n.locationServiceDisabled;
    case 'locationPermissionDenied': return context.l10n.locationPermissionDenied;
    case 'locationPermissionPermanent': return context.l10n.locationPermissionPermanent;
    case 'invalidLatitude': return context.l10n.invalidLatitude;
    case 'invalidLongitude': return context.l10n.invalidLongitude;
    default: return key;
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard({required this.latitude, required this.longitude, required this.governorate, required this.town});
  final String latitude;
  final String longitude;
  final String governorate;
  final String town;
  @override
  Widget build(BuildContext context) {
    final hasAddress = governorate.isNotEmpty || town.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.success)),
        const Gap(AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(latitude, style: AppTypography.labelSmall.copyWith(color: context.textSecondary, fontFeatures: const [FontFeature.tabularFigures()])), Text(', ', style: AppTypography.labelSmall.copyWith(color: context.textSecondary)), Text(longitude, style: AppTypography.labelSmall.copyWith(color: context.textSecondary, fontFeatures: const [FontFeature.tabularFigures()]))]),
          if (hasAddress) ...[const Gap(AppSpacing.xs), Text([town, governorate].where((s) => s.isNotEmpty).join(', '), style: AppTypography.bodySmall.copyWith(color: context.textPrimary, fontWeight: FontWeight.w500))],
          Text(context.l10n.egypt, style: AppTypography.labelSmall.copyWith(color: context.textSecondary)),
        ])),
        const Icon(LucideIcons.checkCircle, size: 18, color: AppColors.success),
      ]),
    );
  }
}

