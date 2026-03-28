import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../data/listing_categories_data.dart';

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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                      icon: const Icon(Icons.close),
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
                      leading: Icon(c.icon, color: AppColors.primary),
                      title: Text(c.name),
                      trailing:
                          sel ? const Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        onSelected(c.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const Gap(AppSpacing.sm),
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Subcategory — ${category.name}',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...category.subcategories.map(
              (s) {
                final sel = s.id == selectedId;
                return ListTile(
                  title: Text(s.name),
                  trailing: sel
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onSelected(s.id);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
            const Gap(AppSpacing.md),
          ],
        ),
      );
    },
  );
}
