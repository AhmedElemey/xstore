import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../data/listing_categories_data.dart';
import '../utils/listing_localized_labels.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

Future<void> showListingCategoryPicker({
  required BuildContext context,
  required String title,
  required List<ListingCategoryOption> categories,
  required String? selectedId,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.45,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final sel = c.id == selectedId;
                    return ListTile(
                      leading: Icon(c.icon, color: AppColors.primary),
                      title: Text(listingLocalizedCategoryName(context, c.id)),
                      trailing:
                          sel ? const Icon(LucideIcons.check, color: AppColors.primary) : null,
                      onTap: () {
                        onSelected(c.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const Gap(AppSpacing.md),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showListingSubcategoryPicker({
  required BuildContext context,
  required ListingCategoryOption category,
  required String? selectedId,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${ctx.l10n.subcategoryPickerPrefix}${listingLocalizedCategoryName(ctx, category.id)}',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            ...category.subcategories.map(
              (s) {
                final sel = s.id == selectedId;
                return ListTile(
                  title: Text(
                    listingLocalizedSubcategoryName(ctx, category.id, s.id),
                  ),
                  trailing: sel
                      ? const Icon(LucideIcons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onSelected(s.id);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
            const Gap(AppSpacing.lg),
          ],
        ),
      );
    },
  );
}
