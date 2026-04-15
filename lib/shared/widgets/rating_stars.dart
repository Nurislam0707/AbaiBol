import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.activeColor,
    this.inactiveColor,
    this.onRatingSelected,
  });

  final int rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<int>? onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.colorScheme.secondary;
    final effectiveInactiveColor =
        inactiveColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final icon = Icon(
          value <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: value <= rating ? effectiveActiveColor : effectiveInactiveColor,
          size: size,
        );

        if (onRatingSelected == null) {
          return icon;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onRatingSelected!(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: icon,
          ),
        );
      }),
    );
  }
}
