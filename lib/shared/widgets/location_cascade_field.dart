import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Single form field that captures a governorate + city pair through a
/// two-step popup cascade, used in both register and edit-profile.
///
/// Backend naming is inverted vs. Egypt's real-world hierarchy: the `cities`
/// endpoint holds the top-level governorates (Cairo, Alexandria) and the
/// `governments` endpoint holds the districts within a city (Nasr City, Maadi)
/// via `Government.cityId`. So [cityId] is the governorate (popup 1) and
/// [governmentId] is the city/district (popup 2), filtered by the chosen
/// governorate. See the note on [GovernmentEntity].
class LocationCascadeField extends ConsumerWidget {
  const LocationCascadeField({
    super.key,
    required this.cityId,
    required this.governmentId,
    required this.onChanged,
    this.errorText,
  });

  /// Selected governorate id (backend `cities`).
  final int? cityId;

  /// Selected city/district id (backend `governments`).
  final int? governmentId;

  /// Fires with the full pair whenever the selection changes. The city is
  /// reset to `null` when the governorate changes, or when the user dismisses
  /// the city popup after picking a governorate.
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
    // Watched so the field rebuilds once the (cached) lists resolve and can
    // render the selected names.
    final cities = ref.watch(allCitiesProvider).valueOrNull;
    final governments = ref.watch(allGovernmentsProvider).valueOrNull;

    final governorate =
        _byId<CityEntity>(cities, cityId, (e) => e.id)?.name.resolve(isArabic);
    final city = _byId<GovernmentEntity>(governments, governmentId, (e) => e.id)
        ?.name
        .resolve(isArabic);

    final display = switch ((governorate, city)) {
      (final g?, final c?) => '$g — $c',
      (final g?, _) => g,
      _ => null,
    };
    final hasError = errorText != null;

    return InkWell(
      onTap: () => _openCascade(context, isArabic),
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        isEmpty: display == null,
        decoration: InputDecoration(
          labelText: context.l10n.governorateAndCityLabel,
          hintText: context.l10n.locationCascadeHint,
          prefixIcon: const Icon(LucideIcons.mapPin),
          suffixIcon: const Icon(LucideIcons.chevronDown),
          filled: true,
          fillColor: context.surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          errorText: errorText,
        ),
        child: display == null
            ? null
            : Text(
                display,
                style: AppTypography.body15.copyWith(
                  color: hasError ? AppColors.error : context.textPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _openCascade(BuildContext context, bool isArabic) async {
    // Step 1 — governorate (backend city).
    final pickedGovernorate = await _showLookupSheet<CityEntity>(
      context: context,
      title: context.l10n.selectGovernorate,
      provider: allCitiesProvider,
      filter: (all) => all,
      idOf: (e) => e.id,
      labelOf: (e) => e.name.resolve(isArabic),
      selectedId: cityId,
    );
    if (pickedGovernorate == null || !context.mounted) return;

    // Keep the current city only when the governorate is unchanged.
    final priorCity = pickedGovernorate == cityId ? governmentId : null;

    // Step 2 — city/district (backend government) within that governorate.
    final pickedCity = await _showLookupSheet<GovernmentEntity>(
      context: context,
      title: context.l10n.selectCityLabel,
      provider: allGovernmentsProvider,
      filter: (all) =>
          all.where((g) => g.cityId == pickedGovernorate).toList(),
      idOf: (e) => e.id,
      labelOf: (e) => e.name.resolve(isArabic),
      selectedId: priorCity,
      emptyText: context.l10n.noCitiesForGovernorate,
    );

    // Governorate is committed regardless; city may be null if step 2 was
    // dismissed (form validation flags the incomplete pair).
    onChanged(pickedGovernorate, pickedCity);
  }

  /// Bottom-sheet single-select over a cached reference list. Returns the
  /// chosen id, or `null` when dismissed.
  Future<int?> _showLookupSheet<T>({
    required BuildContext context,
    required String title,
    required ProviderListenable<AsyncValue<List<T>>> provider,
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
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.7;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(provider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(title, style: AppTypography.titleMedium),
                    ),
                    Flexible(
                      child: async.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            context.l10n.genericError,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                        data: (all) {
                          final items = filter(all);
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                emptyText ?? context.l10n.genericError,
                                style: AppTypography.bodyMedium
                                    .copyWith(color: context.textSecondary),
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
                                    ? const Icon(Icons.check,
                                        color: AppColors.primary)
                                    : null,
                                onTap: () =>
                                    Navigator.pop(sheetContext, id),
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
