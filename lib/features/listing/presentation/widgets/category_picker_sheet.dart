import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../catalog_categories/domain/entities/catalog_category_entity.dart';

Future<void> showListingCategoryPicker({
  required BuildContext context,
  required String title,
  required List<CatalogCategoryEntity> categories,
  required int? selectedId,
  required String Function(CatalogCategoryEntity) labelOf,
  required ValueChanged<int> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
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
              const Divider(height: 1),
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.45,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final sel = c.id == selectedId;
                    return ListTile(
                      // CatalogCategoryEntity has no per-category icon
                      // (unlike the old hardcoded taxonomy) — one generic
                      // icon for all rows.
                      leading: const Icon(LucideIcons.tag, color: AppColors.primary),
                      title: Text(labelOf(c)),
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
  required String title,
  required List<CatalogCategoryEntity> subcategories,
  required int? selectedId,
  required String Function(CatalogCategoryEntity) labelOf,
  required ValueChanged<int> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
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
            const Divider(height: 1),
            ...subcategories.map(
              (s) {
                final sel = s.id == selectedId;
                return ListTile(
                  title: Text(labelOf(s)),
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
