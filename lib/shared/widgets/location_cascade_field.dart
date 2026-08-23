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

  /// Sentinel returned by the city sheet's back button, distinct from `null`
  /// (dismissed with no pick) and any `int` (a picked id) — signals
  /// "reopen the governorate sheet" instead of closing the whole flow.
  static const Object _goBack = Object();

  /// Opens the governorate sheet, then cascades into the city sheet (filtered
  /// to the picked governorate). The city sheet's back button reopens the
  /// governorate sheet, keeping the governorate just picked selected, so the
  /// user can change it without losing the flow. Dismissing the city sheet
  /// (tap-outside/swipe, not back) keeps the previous city when the
  /// governorate didn't change, and clears it otherwise.
  Future<void> _pickLocation(BuildContext context, bool isArabic) async {
    var selectedGovernorate = governmentId;

    while (true) {
      final govResult = await _showLookupSheet<GovernmentEntity>(
        context: context,
        title: context.l10n.selectGovernorate,
        provider: allGovernmentsProvider,
        invalidate: (ref) => ref.invalidate(allGovernmentsProvider),
        filter: (all) => all,
        idOf: (e) => e.id,
        labelOf: (e) => e.name.resolve(isArabic),
        searchTextOf: (e) => '${e.name.en} ${e.name.ar}',
        selectedId: selectedGovernorate,
      );
      if (govResult == null || !context.mounted) return;
      selectedGovernorate = govResult as int;

      final keptCityId = selectedGovernorate == governmentId ? cityId : null;

      final cityResult = await _showLookupSheet<CityEntity>(
        context: context,
        title: context.l10n.selectCityLabel,
        provider: allCitiesProvider,
        invalidate: (ref) => ref.invalidate(allCitiesProvider),
        filter: (all) => all
            .where((c) => c.governorateId == selectedGovernorate)
            .toList(),
        idOf: (e) => e.id,
        labelOf: (e) => e.name.resolve(isArabic),
        searchTextOf: (e) => '${e.name.en} ${e.name.ar}',
        selectedId: keptCityId,
        emptyText: context.l10n.noCitiesForGovernorate,
        showBackButton: true,
      );
      if (!context.mounted) return;

      if (cityResult == _goBack) continue;

      onChanged(cityResult as int? ?? keptCityId, selectedGovernorate);
      return;
    }
  }

  /// Bottom-sheet single-select over a cached reference list. Returns the
  /// chosen id, `null` when dismissed, or [_goBack] when [showBackButton] is
  /// set and the user tapped it. Opens immediately; the sheet itself watches
  /// the provider (spinner / error+retry / data).
  Future<Object?> _showLookupSheet<T>({
    required BuildContext context,
    required String title,
    required ProviderListenable<AsyncValue<List<T>>> provider,
    required void Function(WidgetRef ref) invalidate,
    required List<T> Function(List<T>) filter,
    required int Function(T) idOf,
    required String Function(T) labelOf,
    required String Function(T) searchTextOf,
    required int? selectedId,
    String? emptyText,
    bool showBackButton = false,
  }) {
    return showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _LookupSheetBody<T>(
          title: title,
          provider: provider,
          invalidate: invalidate,
          filter: filter,
          idOf: idOf,
          labelOf: labelOf,
          searchTextOf: searchTextOf,
          selectedId: selectedId,
          emptyText: emptyText,
          showBackButton: showBackButton,
        );
      },
    );
  }
}

class _LookupSheetBody<T> extends ConsumerStatefulWidget {
  const _LookupSheetBody({
    required this.title,
    required this.provider,
    required this.invalidate,
    required this.filter,
    required this.idOf,
    required this.labelOf,
    required this.searchTextOf,
    required this.selectedId,
    this.emptyText,
    this.showBackButton = false,
  });

  final String title;
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final void Function(WidgetRef ref) invalidate;
  final List<T> Function(List<T>) filter;
  final int Function(T) idOf;
  final String Function(T) labelOf;
  final String Function(T) searchTextOf;
  final int? selectedId;
  final String? emptyText;
  final bool showBackButton;

  @override
  ConsumerState<_LookupSheetBody<T>> createState() =>
      _LookupSheetBodyState<T>();
}

class _LookupSheetBodyState<T> extends ConsumerState<_LookupSheetBody<T>> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<T> _matching(List<T> items) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where(
          (item) => widget.searchTextOf(item).toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(widget.provider);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetHeight =
        (screenHeight * 0.55).clamp(0.0, screenHeight - keyboard);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: widget.showBackButton
                    ? const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      )
                    : const EdgeInsets.all(AppSpacing.lg),
                child: widget.showBackButton
                    ? Row(
                        children: [
                          IconButton(
                            key: const ValueKey(
                              'locationCascadeBackButton',
                            ),
                            icon: Icon(context.arrowBackIcon),
                            onPressed: () => Navigator.pop(
                              context,
                              LocationCascadeField._goBack,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: AppTypography.titleMedium,
                            ),
                          ),
                        ],
                      )
                    : Text(widget.title, style: AppTypography.titleMedium),
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
                          onPressed: () => widget.invalidate(ref),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                  data: (all) {
                    final items = widget.filter(all);
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          widget.emptyText ?? context.l10n.genericError,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      );
                    }
                    final visible = _matching(items);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: TextField(
                            key: const ValueKey(
                              'locationCascadeSearchField',
                            ),
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                            enableSuggestions: false,
                            onChanged: (_) => setState(() {}),
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: context.l10n.locationSheetSearchHint,
                              hintStyle: AppTypography.bodyLarge.copyWith(
                                color: context.textSecondary,
                                height: 1,
                              ),
                              filled: true,
                              fillColor: context.surfaceColor,
                              isDense: true,
                              prefixIcon: const Icon(LucideIcons.search),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(LucideIcons.x),
                                      onPressed: () {
                                        _search.clear();
                                        setState(() {});
                                      },
                                    ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.inputContentPaddingV,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: visible.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.lg,
                                  ),
                                  child: Text(
                                    context.l10n.locationSheetNoMatches,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior
                                          .onDrag,
                                  itemCount: visible.length,
                                  itemBuilder: (context, i) {
                                    final item = visible[i];
                                    final id = widget.idOf(item);
                                    return ListTile(
                                      title: Text(widget.labelOf(item)),
                                      trailing: id == widget.selectedId
                                          ? const Icon(
                                              Icons.check,
                                              color: AppColors.primary,
                                            )
                                          : null,
                                      onTap: () =>
                                          Navigator.pop(context, id),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
