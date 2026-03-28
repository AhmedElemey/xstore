import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  static const _badgeSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<circle cx="24" cy="24" r="20" fill="none" stroke="currentColor" '
      'stroke-width="3"/><path d="M16 24h16M24 16v16" stroke="currentColor" '
      'stroke-width="3" stroke-linecap="round"/></svg>';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exploreTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              _badgeSvg,
              width: 56,
              height: 56,
              colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
            ),
            const Gap(AppSpacing.md),
            Text(
              'Explore — categories & search go here.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
