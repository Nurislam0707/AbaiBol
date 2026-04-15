import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.canPop = false,
  });

  final String title;
  final String? subtitle;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 96,
      flexibleSpace: _GlassHeaderContent(
        title: title,
        subtitle: subtitle,
        canPop: canPop,
      ),
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.canPop = false,
  });

  final String title;
  final String? subtitle;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return _GlassHeaderContent(
      title: title,
      subtitle: subtitle,
      canPop: canPop,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(96);
}

class _GlassHeaderContent extends StatelessWidget {
  const _GlassHeaderContent({
    required this.title,
    this.subtitle,
    this.canPop,
  });

  final String title;
  final String? subtitle;
  final bool? canPop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.72 : 0.82),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? theme.colorScheme.outlineVariant : AppColors.stroke,
                ),
              ),
            ),
            child: Row(
              children: [
                if (canPop == true)
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/abai_mark.svg',
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canPop != true)
                        Text(
                          'NURIS PLATFORM',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
