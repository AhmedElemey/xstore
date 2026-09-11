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
      // Already inside explore_screen.dart's outer CustomScrollView — a
      // second, shrink-wrapped scrollable here is unnecessary nesting for a
      // small, bounded suggestions list, and it rebuilds on every keystroke.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < suggestions.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              dense: true,
              title: Text(suggestions[i], style: AppTypography.bodyMedium),
              onTap: () => onSelect(suggestions[i]),
            ),
          ],
        ],
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
