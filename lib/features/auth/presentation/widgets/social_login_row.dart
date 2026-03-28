import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  void _soon(BuildContext context) {
    context.showSnack('Coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialChip(
            label: 'Google',
            emoji: '🇬',
            onTap: () => _soon(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialChip(
            label: 'Apple',
            emoji: '🍎',
            onTap: () => _soon(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialChip(
            label: 'Facebook',
            emoji: '📘',
            onTap: () => _soon(context),
          ),
        ),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
