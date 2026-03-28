import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

class PhotoUploadGrid extends StatelessWidget {
  const PhotoUploadGrid({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Gap(AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ...paths.asMap().entries.map(
                  (e) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(e.value),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(28, 28),
                          ),
                          onPressed: () => onRemove(e.key),
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
