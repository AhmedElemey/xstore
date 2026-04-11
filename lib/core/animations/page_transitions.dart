import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_animations.dart';

/// Modal-style routes (OTP, product detail, checkout, store hours, cart).
CustomTransitionPage<void> slideUpTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppAnimations.pageEnter,
    reverseTransitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.enter,
          ),
        ),
        child: child,
      );
    },
  );
}

/// Stack-style detail routes (profile, edit profile, notifications, listings).
CustomTransitionPage<void> slideRightTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppAnimations.pageEnter,
    reverseTransitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.enter,
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.enter,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Main shell tabs (home, explore, wishlist, orders, profile / vendor tabs).
CustomTransitionPage<void> fadeScaleTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppAnimations.pageEnter,
    reverseTransitionDuration: AppAnimations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppAnimations.enter,
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.enter,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Optional helper for custom tab views (pass real animation values when used).
Widget sharedAxisTransition({
  required Widget child,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  SharedAxisTransitionType transitionType =
      SharedAxisTransitionType.horizontal,
}) {
  return SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    transitionType: transitionType,
    child: child,
  );
}
