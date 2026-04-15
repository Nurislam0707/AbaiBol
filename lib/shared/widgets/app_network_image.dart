import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    
    final image = isNetwork
      ? Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _ImagePlaceholder(width: width, height: height, icon: placeholderIcon);
          },
          errorBuilder: (context, error, stackTrace) => _ImagePlaceholder(
            width: width,
            height: height,
            icon: placeholderIcon,
          ),
        )
      : Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _ImagePlaceholder(
            width: width,
            height: height,
            icon: placeholderIcon,
          ),
        );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.heroTag,
  });

  final String imageUrl;
  final double radius;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: AppNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        placeholderIcon: Icons.person_rounded,
      ),
    );

    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.accent.withValues(alpha: 0.22),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.8)),
    );
  }
}
