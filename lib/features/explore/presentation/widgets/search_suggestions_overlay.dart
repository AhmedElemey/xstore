import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class SearchSuggestionsOverlay extends StatelessWidget {
  const SearchSuggestionsOverlay({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Material(
      elevation: 6,
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, i) {
          final s = suggestions[i];
          return ListTile(
            dense: true,
            title: Text(s, style: AppTypography.bodyMedium),
            onTap: () => onSelect(s),
          );
        },
      ),
    );
  }
}

class RecentSearchesHeader extends StatelessWidget {
  const RecentSearchesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        context.l10n.recentSearches,
        style: AppTypography.labelLarge.copyWith(color: context.textSecondary),
      ),
    );
  }
}
