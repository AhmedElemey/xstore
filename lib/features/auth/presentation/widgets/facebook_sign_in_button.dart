import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/social_auth_provider.dart';
import 'social_button.dart';

class FacebookSignInButton extends ConsumerWidget {
  const FacebookSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(socialAuthProvider.select((s) => s.isFacebookLoading));
    final isAnyLoading =
        ref.watch(socialAuthProvider.select((s) => s.isAnyLoading));
    return SocialButton(
      onTap: isAnyLoading
          ? null
          : () => ref.read(socialAuthProvider.notifier).signInWithFacebook(),
      isLoading: isLoading,
      icon: SvgPicture.asset('assets/icons/facebook_logo.svg'),
      label: AppStrings.continueWithFacebook,
      borderColor: const Color(0xFF1877F2),
      bgColor: const Color(0xFF1877F2),
      textColor: Colors.white,
    );
  }
}
