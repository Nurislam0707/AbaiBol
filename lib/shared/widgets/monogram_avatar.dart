import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MonogramAvatar extends StatelessWidget {
  const MonogramAvatar({
    super.key,
    required this.seedText,
    this.imageUrl,
    this.subtitle,
    this.size = 60,
    this.showShadow = true,
    this.isCircle = false,
  });

  final String seedText;
  final String? imageUrl;
  final String? subtitle;
  final double size;
  final bool showShadow;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initials = _initialsFor(seedText);
    final hue = seedText.runes.fold<int>(0, (sum, rune) => sum + rune) % 360;

    final decoration = BoxDecoration(
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(size * 0.32),
      color: hasImage ? theme.colorScheme.surfaceContainerHighest : null,
      gradient: hasImage
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(1, hue.toDouble(), 0.74, 0.56).toColor(),
                HSLColor.fromAHSL(1, ((hue + 36) % 360).toDouble(), 0.68, 0.42).toColor(),
              ],
            ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ]
          : null,
    );

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Monogram fallback
          if (!hasImage)
            Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

          // Image layer
          if (hasImage) _buildImage(imageUrl!),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    final isNetwork = path.startsWith('http');
    
    return Image(
      image: isNetwork 
          ? NetworkImage(path) 
          : AssetImage(path) as ImageProvider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

String _initialsFor(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'A';
  }
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}
