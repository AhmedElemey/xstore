import 'package:flutter/material.dart';

import 'profile_menu_tile.dart';

class ProfileSwitchTile extends StatelessWidget {
  const ProfileSwitchTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileMenuTile(
      icon: icon,
      iconColor: iconColor,
      label: label,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
