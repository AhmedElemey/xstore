import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../listing/presentation/data/listing_categories_data.dart';
import '../explore_state.dart';
import 'price_range_slider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

// Generous ceiling for marketplace listings (electronics, appliances, etc.)
// — the previous 500 EGP cap made the slider unusable for anything but the
// cheapest items.
const _kMaxPriceFilter = 50000.0;

Future<void> showExploreFilterBottomSheet({
  required BuildContext context,
  required FilterState initial,
  required List<String> categoryOptions,
  required void Function(FilterState applied) onApply,
  required VoidCallback onReset,
}) {
  // Capture from the caller — inside the sheet MediaQuery may have
  // padding stripped by the shell / nested navigator.
  final topInset = MediaQuery.viewPaddingOf(context).top;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Root navigator so the sheet covers the shell tab bar and can
    // clear the status bar correctly (nested tab nav left the title
    // under the Dynamic Island and the bottom nav still visible).
    useRootNavigator: true,
    useSafeArea: false,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (ctx) {
      return _FilterSheetBody(
        initial: initial,
        categoryOptions: categoryOptions,
        onApply: onApply,
        onReset: onReset,
        topInset: topInset,
      );
    },
  );
}

class _FilterSheetBody extends StatefulWidget {
  const _FilterSheetBody({
    required this.initial,
    required this.categoryOptions,
    required this.onApply,
    required this.onReset,
    required this.topInset,
  });

  final FilterState initial;
  final List<String> categoryOptions;
  final void Function(FilterState applied) onApply;
  final VoidCallback onReset;
  final double topInset;

  @override
  State<_FilterSheetBody> createState() => _FilterSheetBodyState();
}

class _FilterSheetBodyState extends State<_FilterSheetBody> {
  late List<String> _cats;
  late List<String> _conds;
  late RangeValues _range;
  double? _minRating;
  late TextEditingController _loc;
  late bool _ship;
  late TextEditingController _minPrice;
  late TextEditingController _maxPrice;

  @override
  void initState() {
    super.initState();
    _cats = List.from(widget.initial.categories);
    _conds = List.from(widget.initial.conditions);
    _range = RangeValues(
      widget.initial.minPrice ?? 0,
      widget.initial.maxPrice ?? _kMaxPriceFilter,
    );
    _minRating = widget.initial.minRating;
    _loc = TextEditingController(text: widget.initial.location ?? '');
    _ship = widget.initial.shippingOnly;
    _minPrice = TextEditingController(
      text: (widget.initial.minPrice ?? 0).toStringAsFixed(0),
    );
    _maxPrice = TextEditingController(
      text: (widget.initial.maxPrice ?? _kMaxPriceFilter).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _loc.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  int _countActive() {
    var n = _cats.length + _conds.length;
    if (_minRating != null) n++;
    if (_loc.text.trim().isNotEmpty) n++;
    if (_ship) n++;
    if (_range.start > 0 || _range.end < _kMaxPriceFilter) n++;
    return n;
  }

  FilterState _buildState() {
    final minP = double.tryParse(_minPrice.text);
    final maxP = double.tryParse(_maxPrice.text);
    return FilterState(
      categories: _cats,
      conditions: _conds,
      minPrice: minP,
      maxPrice: maxP,
      minRating: _minRating,
      location: _loc.text.trim().isEmpty ? null : _loc.text.trim(),
      shippingOnly: _ship,
    );
  }

  Widget _horizontalChipRow({required List<Widget> children}) {
    if (children.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final size = MediaQuery.sizeOf(context);
    // Prefer the caller-captured inset; fall back if the sheet still has one.
    final topInset = widget.topInset > 0
        ? widget.topInset
        : viewPadding.top;
    final bottomInset = viewPadding.bottom + viewInsets.bottom;
    final maxHeight = size.height - topInset - bottomInset - AppSpacing.md;

    return Padding(
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight.clamp(200.0, size.height),
        ),
        child: Material(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.filters,
                      style: AppTypography.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.category,
                          style: AppTypography.titleMedium,
                        ),
                        const Gap(AppSpacing.sm),
                        _horizontalChipRow(
                          children: widget.categoryOptions.map((c) {
                            final sel = _cats.contains(c);
                            return FilterChip(
                              label: Text(c),
                              selected: sel,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _cats.add(c);
                                  } else {
                                    _cats.remove(c);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          context.l10n.condition,
                          style: AppTypography.titleMedium,
                        ),
                        const Gap(AppSpacing.sm),
                        _horizontalChipRow(
                          children: ListingCategoriesData.conditions.map((c) {
                            final sel = _conds.contains(c);
                            return FilterChip(
                              label: Text(c),
                              selected: sel,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _conds.add(c);
                                  } else {
                                    _conds.remove(c);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const Gap(AppSpacing.lg),
                        PriceRangeSlider(
                          min: 0,
                          max: _kMaxPriceFilter,
                          values: _range,
                          onChanged: (v) {
                            setState(() {
                              _range = v;
                              _minPrice.text = v.start.round().toString();
                              _maxPrice.text = v.end.round().toString();
                            });
                          },
                          minController: _minPrice,
                          maxController: _maxPrice,
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          context.l10n.minRating,
                          style: AppTypography.titleMedium,
                        ),
                        const Gap(AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            ChoiceChip(
                              label: Text(context.l10n.ratingStars4Plus),
                              selected: _minRating == 4,
                              onSelected: (_) =>
                                  setState(() => _minRating = 4),
                            ),
                            ChoiceChip(
                              label: Text(context.l10n.ratingStars3Plus),
                              selected: _minRating == 3,
                              onSelected: (_) =>
                                  setState(() => _minRating = 3),
                            ),
                            ChoiceChip(
                              label: Text(context.l10n.ratingStars2Plus),
                              selected: _minRating == 2,
                              onSelected: (_) =>
                                  setState(() => _minRating = 2),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                        TextField(
                          controller: _loc,
                          decoration: InputDecoration(
                            labelText: context.l10n.location,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.md,
                              ),
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.shippingOnly,
                            style: AppTypography.bodyMedium,
                          ),
                          value: _ship,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _ship = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        widget.onReset();
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.l10n.resetFilters,
                        style: AppTypography.labelLarge,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        widget.onApply(_buildState());
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.l10n.applyFiltersCount(_countActive()),
                      ),
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
