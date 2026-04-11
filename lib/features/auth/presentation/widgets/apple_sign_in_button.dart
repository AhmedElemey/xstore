import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/social_auth_provider.dart';
import 'social_button.dart';

class AppleSignInButton extends ConsumerWidget {
  const AppleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }
    final isLoading = ref.watch(socialAuthProvider.select((s) => s.isAppleLoading));
    final isAnyLoading = ref.watch(socialAuthProvider.select((s) => s.isAnyLoading));
    final isDark = context.isDark;
    return SocialButton(
      onTap: isAnyLoading
          ? null
          : () => ref.read(socialAuthProvider.notifier).signInWithApple(),
      isLoading: isLoading,
      icon: Icon(
        Icons.apple,
        color: isDark ? Colors.white : Colors.black,
        size: 22,
      ),
      label: context.l10n.continueWithApple,
      borderColor: context.borderColor,
      bgColor: isDark ? Colors.black : Colors.white,
      textColor: isDark ? Colors.white : Colors.black,
    );
  }
}
