import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      extendBody: true, // Crucial for floating nav bar transparency
      body: Stack(
        children: [
          const _AmbientBackground(),
          navigationShell,
        ],
      ),
      bottomNavigationBar: _PremiumNavBar(
        navigationShell: navigationShell,
        strings: strings,
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({
    required this.navigationShell,
    required this.strings,
  });

  final StatefulNavigationShell navigationShell;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final destinations = [
      _NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: strings.home,
      ),
      _NavDestination(
        icon: Icons.search_rounded,
        selectedIcon: Icons.search_rounded,
        label: strings.search,
      ),
      _NavDestination(
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events_rounded,
        label: strings.ranking,
      ),
      _NavDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: strings.profile,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                ? const Color(0xFF0F172A).withValues(alpha: 0.75) 
                : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark 
                  ? Colors.white10 
                  : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                // Sliding Indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  alignment: Alignment(
                    -1.0 + (navigationShell.currentIndex * (2.0 / (destinations.length - 1))),
                    0.0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / destinations.length,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Icons
                Row(
                  children: destinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dest = entry.value;
                    final isSelected = navigationShell.currentIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: _NavBarItem(
                          destination: dest,
                          isSelected: isSelected,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.destination,
    required this.isSelected,
  });

  final _NavDestination destination;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isSelected ? 1.0 : 1.0, 
          child: Icon(
            isSelected ? destination.selectedIcon : destination.icon,
            color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.6),
            size: 26,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isSelected ? 0 : 0, // We could add labels here if needed
          child: isSelected 
            ? const SizedBox.shrink() 
            : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF081120), Color(0xFF0D1730)]
                    : const [AppColors.background, Color(0xFFEEF4FF)],
              ),
            ),
          ),
          const Positioned(
            top: -80,
            left: -20,
            child: _GlowOrb(color: AppColors.primary, size: 220),
          ),
          const Positioned(
            bottom: -70,
            right: -30,
            child: _GlowOrb(color: AppColors.accent, size: 180),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
