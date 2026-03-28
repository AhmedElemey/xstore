import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';

class XstoreBottomNav extends StatelessWidget {
  const XstoreBottomNav({
    super.key,
    required this.shell,
  });

  final StatefulNavigationShell shell;

  void _onDestinationSelected(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: AppStrings.homeTitle,
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: AppStrings.exploreTitle,
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: AppStrings.cartTitle,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: AppStrings.profileTitle,
        ),
      ],
    );
  }
}
