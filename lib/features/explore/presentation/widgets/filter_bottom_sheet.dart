import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../listing/presentation/data/listing_categories_data.dart';
import '../explore_state.dart';
import 'price_range_slider.dart';

Future<void> showExploreFilterBottomSheet({
  required BuildContext context,
  required FilterState initial,
  required void Function(FilterState applied) onApply,
  required VoidCallback onReset,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (ctx) {
      return _FilterSheetBody(
        initial: initial,
        onApply: onApply,
        onReset: onReset,
      );
    },
  );
}

class _FilterSheetBody extends StatefulWidget {
  const _FilterSheetBody({
    required this.initial,
    required this.onApply,
    required this.onReset,
  });

  final FilterState initial;
  final void Function(FilterState applied) onApply;
  final VoidCallback onReset;

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

  static const _categoryOptions = ['Electronics', 'Fashion', 'Home', 'Sports'];

  @override
  void initState() {
    super.initState();
    _cats = List.from(widget.initial.categories);
    _conds = List.from(widget.initial.conditions);
    _range = RangeValues(
      widget.initial.minPrice ?? 0,
      widget.initial.maxPrice ?? 500,
    );
    _minRating = widget.initial.minRating;
    _loc = TextEditingController(text: widget.initial.location ?? '');
    _ship = widget.initial.shippingOnly;
    _minPrice = TextEditingController(text: (widget.initial.minPrice ?? 0).toStringAsFixed(0));
    _maxPrice = TextEditingController(text: (widget.initial.maxPrice ?? 500).toStringAsFixed(0));
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
    if (_range.start > 0 || _range.end < 500) n++;
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

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: pad.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              Row(
                children: [
                  Text(AppStrings.filters, style: AppTypography.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Gap(AppSpacing.lg),
              Text(AppStrings.category, style: AppTypography.titleMedium),
              const Gap(AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _categoryOptions.map((c) {
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
              Text(AppStrings.condition, style: AppTypography.titleMedium),
              const Gap(AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
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
                max: 500,
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
              Text(AppStrings.minRating, style: AppTypography.titleMedium),
              const Gap(AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: Text(AppStrings.ratingStars4Plus),
                    selected: _minRating == 4,
                    onSelected: (_) => setState(() => _minRating = 4),
                  ),
                  ChoiceChip(
                    label: Text(AppStrings.ratingStars3Plus),
                    selected: _minRating == 3,
                    onSelected: (_) => setState(() => _minRating = 3),
                  ),
                  ChoiceChip(
                    label: Text(AppStrings.ratingStars2Plus),
                    selected: _minRating == 2,
                    onSelected: (_) => setState(() => _minRating = 2),
                  ),
                ],
              ),
              const Gap(AppSpacing.lg),
              TextField(
                controller: _loc,
                decoration: InputDecoration(
                  labelText: AppStrings.location,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.shippingOnly, style: AppTypography.bodyMedium),
                value: _ship,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _ship = v),
              ),
              const Gap(AppSpacing.x2l),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    child: Text(AppStrings.resetFilters, style: AppTypography.labelLarge),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      widget.onApply(_buildState());
                      Navigator.pop(context);
                    },
                    child: Text(AppStrings.applyFiltersCount(_countActive())),
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }
}
