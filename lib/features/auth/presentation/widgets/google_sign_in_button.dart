import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/social_auth_provider.dart';
import 'social_button.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(socialAuthProvider.select((s) => s.isGoogleLoading));
    final isAnyLoading =
        ref.watch(socialAuthProvider.select((s) => s.isAnyLoading));
    return SocialButton(
      onTap: isAnyLoading
          ? null
          : () => ref.read(socialAuthProvider.notifier).signInWithGoogle(),
      isLoading: isLoading,
      icon: SvgPicture.asset('assets/icons/google_logo.svg'),
      label: context.l10n.continueWithGoogle,
      borderColor: const Color(0xFFDADCE0),
      bgColor: context.surfaceColor,
      textColor: context.textPrimary,
    );
  }
}
