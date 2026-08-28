import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../catalog_categories/presentation/providers/catalog_category_dependencies.dart';
import '../utils/catalog_category_tree.dart';

Future<void> showListingCategoryPicker({
  required BuildContext context,
  required String title,
  required int? selectedId,
  required ValueChanged<int> onSelected,
}) async {
  final id = await _showCatalogPickerSheet(
    context: context,
    title: title,
    selectedId: selectedId,
    showLeadingIcon: true,
  );
  if (id != null) onSelected(id);
}

Future<void> showListingSubcategoryPicker({
  required BuildContext context,
  required String title,
  required int parentId,
  required int? selectedId,
  required ValueChanged<int> onSelected,
}) async {
  final id = await _showCatalogPickerSheet(
    context: context,
    title: title,
    selectedId: selectedId,
    parentId: parentId,
  );
  if (id != null) onSelected(id);
}

Future<int?> _showCatalogPickerSheet({
  required BuildContext context,
  required String title,
  required int? selectedId,
  int? parentId,
  bool showLeadingIcon = false,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (sheetContext) {
      return _CatalogPickerBody(
        title: title,
        selectedId: selectedId,
        parentId: parentId,
        showLeadingIcon: showLeadingIcon,
      );
    },
  );
}

class _CatalogPickerBody extends ConsumerWidget {
  const _CatalogPickerBody({
    required this.title,
    required this.selectedId,
    required this.parentId,
    required this.showLeadingIcon,
  });

  final String title;
  final int? selectedId;
  final int? parentId;
  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height * 0.55;
    final isArabic = ref.watch(appIsArabicProvider);
    final async = ref.watch(allCatalogCategoriesProvider);
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => _PickerError(
                  message: context.l10n.genericError,
                  retryLabel: context.l10n.retry,
                  onRetry: () => ref.invalidate(allCatalogCategoriesProvider),
                ),
                data: (all) {
                  final parent = parentId;
                  final items = parent == null
                      ? topLevelCategories(all)
                      : subcategoriesOf(all, parent);
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(context.l10n.genericError),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final sel = c.id == selectedId;
                      return ListTile(
                        leading: showLeadingIcon
                            ? const Icon(
                                LucideIcons.tag,
                                color: AppColors.primary,
                              )
                            : null,
                        title: Text(c.name.resolve(isArabic)),
                        trailing: sel
                            ? const Icon(
                                LucideIcons.check,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, c.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerError extends StatelessWidget {
  const _PickerError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
