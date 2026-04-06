import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import 'apple_sign_in_button.dart';
import 'facebook_sign_in_button.dart';
import 'google_sign_in_button.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GoogleSignInButton(),
        const Gap(AppSpacing.sm),
        if (Platform.isIOS || Platform.isMacOS) ...[
          const AppleSignInButton(),
          const Gap(AppSpacing.sm),
        ],
        const FacebookSignInButton(),
      ],
    );
  }
}
