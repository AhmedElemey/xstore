import 'package:flutter/material.dart';

import 'google_sign_in_button.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GoogleSignInButton(),
        // TODO(phase-2): Apple and Facebook sign-in are parked (no buttons render); keep for restore.
      ],
    );
  }
}
