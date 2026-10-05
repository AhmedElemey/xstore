import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';

/// 34px reviewer avatar: the photo if there is one, else the name's initial
/// on the brand gradient.
class ReviewAvatar extends StatelessWidget {
  const ReviewAvatar({super.key, required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.brandGradient,
        ),
        image: hasImage
            ? DecorationImage(
                image: AppNetworkImage.cached(url, cacheSize: 100),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: context.onBrandColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
    );
  }
}
