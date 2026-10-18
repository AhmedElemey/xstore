import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'profile_menu_tile.dart';

class ProfileSwitchTile extends StatelessWidget {
  const ProfileSwitchTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBackground;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // One node for screen readers ("<label>, switch, on/off") and the whole
    // row toggles, not only the Switch.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: label,
      toggled: value,
      onTap: () => onChanged(!value),
      child: ProfileMenuTile(
        icon: icon,
        iconBackground: iconBackground,
        label: label,
        showChevron: false,
        onTap: () => onChanged(!value),
        trailing: Switch.adaptive(
          value: value,
          activeTrackColor: context.linkColor.withValues(alpha: 0.45),
          activeThumbColor: AppColors.white,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
