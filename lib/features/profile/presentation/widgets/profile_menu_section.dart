import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

/// Orbit glass group of profile rows separated by hairlines.
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, thickness: 1, color: context.borderColor),
          ],
        ],
      ),
    );
  }
}
