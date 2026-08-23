import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/cities/domain/entities/city_entity.dart';
import '../../features/cities/presentation/providers/city_dependencies.dart';
import '../../features/governments/domain/entities/government_entity.dart';
import '../../features/governments/presentation/providers/government_dependencies.dart';

/// A single API-backed cascading picker for a governorate + city pair
/// (register + edit profile).
///
/// Tapping the field opens the governorate bottom sheet; picking a
/// governorate immediately opens the city bottom sheet filtered to it. Once
/// both are picked, the field displays "Governorate - City".
///
/// Live hierarchy (confirmed 2026-08-11 / 2026-08-22): `/api/governorates`
/// holds the top-level governorates; `/api/cities` holds cities linked upward
/// via `governorateId`. Opening government loads [allGovernmentsProvider];
/// opening city loads [allCitiesProvider] filtered by the chosen
/// governorate. [governmentId] / [cityId] are the ids sent on register.
class LocationCascadeField extends ConsumerWidget {
  const LocationCascadeField({
    super.key,
    required this.cityId,
    required this.governmentId,
    required this.onChanged,
    this.errorText,
  });

  /// Selected city id (backend `cities`).
  final int? cityId;

  /// Selected governorate id (backend `governorates`).
  final int? governmentId;

  /// Fires with the full pair whenever either picker changes. The city is
  /// reset to `null` when the governorate changes, or when the user dismisses
  /// the city sheet after picking a governorate.
  final void Function(int? cityId, int? governmentId) onChanged;

  final String? errorText;

  static T? _byId<T>(List<T>? list, int? id, int Function(T) idOf) {
    if (list == null || id == null) return null;
    for (final item in list) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(appIsArabicProvider);
    // Watched so the fields rebuild once the (cached) lists resolve and can
    // render the selected names.
    final cities = ref.watch(allCitiesProvider).valueOrNull;
    final governments = ref.watch(allGovernmentsProvider).valueOrNull;

    final governorateName =
        _byId<GovernmentEntity>(governments, governmentId, (e) => e.id)
            ?.name
            .resolve(isArabic);
    final cityName =
        _byId<CityEntity>(cities, cityId, (e) => e.id)?.name.resolve(isArabic);

    final combinedDisplay = governorateName == null
        ? null
        : cityName == null
            ? governorateName
            : '$governorateName - $cityName';

    return _LocationPickerTile(
      key: const ValueKey('locationCascadeField'),
      label: context.l10n.governorateAndCityLabel,
      hint: context.l10n.locationCascadeHint,
      display: combinedDisplay,
      icon: LucideIcons.mapPin,
      errorText: errorText,
      onTap: () => _pickLocation(context, isArabic),
    );
  }

  /// Opens the governorate sheet, then immediately cascades into the city
  /// sheet (filtered to the picked governorate). Dismissing the city sheet
  /// keeps the previous city when the governorate didn't change, and clears
  /// it otherwise.
  Future<void> _pickLocation(BuildContext context, bool isArabic) async {
    final pickedGovernorate = await _showLookupSheet<GovernmentEntity>(
      context: context,
      title: context.l10n.selectGovernorate,
      provider: allGovernmentsProvider,
      invalidate: (ref) => ref.invalidate(allGovernmentsProvider),
      filter: (all) => all,
      idOf: (e) => e.id,
      labelOf: (e) => e.name.resolve(isArabic),
      selectedId: governmentId,
    );
    if (pickedGovernorate == null || !context.mounted) return;

    final keptCityId = pickedGovernorate == governmentId ? cityId : null;

    final pickedCity = await _showLookupSheet<CityEntity>(
      context: context,
      title: context.l10n.selectCityLabel,
      provider: allCitiesProvider,
      invalidate: (ref) => ref.invalidate(allCitiesProvider),
      filter: (all) =>
          all.where((c) => c.governorateId == pickedGovernorate).toList(),
      idOf: (e) => e.id,
      labelOf: (e) => e.name.resolve(isArabic),
      selectedId: keptCityId,
      emptyText: context.l10n.noCitiesForGovernorate,
    );
    if (!context.mounted) return;

    onChanged(pickedCity ?? keptCityId, pickedGovernorate);
  }

  /// Bottom-sheet single-select over a cached reference list. Returns the
  /// chosen id, or `null` when dismissed. Opens immediately; the sheet
  /// itself watches the provider (spinner / error+retry / data).
  Future<int?> _showLookupSheet<T>({
    required BuildContext context,
    required String title,
    required ProviderListenable<AsyncValue<List<T>>> provider,
    required void Function(WidgetRef ref) invalidate,
    required List<T> Function(List<T>) filter,
    required int Function(T) idOf,
    required String Function(T) labelOf,
    required int? selectedId,
    String? emptyText,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final sheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.55;
        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(provider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(title, style: AppTypography.titleMedium),
                    ),
                    Expanded(
                      child: async.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.l10n.genericError,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.error),
                              ),
                              const Gap(AppSpacing.sm),
                              TextButton(
                                onPressed: () => invalidate(ref),
                                child: Text(context.l10n.retry),
                              ),
                            ],
                          ),
                        ),
                        data: (all) {
                          final items = filter(all);
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                emptyText ?? context.l10n.genericError,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              final id = idOf(item);
                              return ListTile(
                                title: Text(labelOf(item)),
                                trailing: id == selectedId
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(sheetContext, id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LocationPickerTile extends StatelessWidget {
  const _LocationPickerTile({
    super.key,
    required this.label,
    required this.hint,
    required this.display,
    required this.icon,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? display;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        isEmpty: display == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(LucideIcons.chevronDown),
          filled: true,
          fillColor: context.surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          errorText: errorText,
        ),
        child: display == null
            ? null
            : Text(
                display!,
                style: AppTypography.body15.copyWith(
                  color: hasError ? AppColors.error : context.textPrimary,
                ),
              ),
      ),
    );
  }
}
