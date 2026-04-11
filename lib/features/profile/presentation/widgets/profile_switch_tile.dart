import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
    return ProfileMenuTile(
      icon: icon,
      iconBackground: iconBackground,
      label: label,
      showChevron: false,
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.45),
        activeThumbColor: AppColors.white,
        onChanged: onChanged,
      ),
    );
  }
}
