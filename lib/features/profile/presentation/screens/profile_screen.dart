// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../domain/models/badge_definition.dart';
import '../../domain/models/user_profile.dart';
import '../../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final strings = ref.watch(appStringsProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final reviewCountAsync = ref.watch(myReviewCountProvider);
    final userId = ref.watch(currentAnonymousUserIdProvider);
    final language = ref.watch(appLanguageProvider);

    final editNameAndShow = (String displayName) {
      _showEditNameDialog(context, ref, displayName, strings);
    };
    final profileFuture = ref.read(currentUserProfileProvider.future);

    ref.listen(profileEditProvider, (previous, next) {
      if (next.saved && previous?.saved != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(strings.profileUpdated),
            ]),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        ref.read(profileEditProvider.notifier).reset();
      }
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), behavior: SnackBarBehavior.floating),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ─── Wave Header SliverAppBar ───────────────────────────────
            SliverToBoxAdapter(
              child: _WaveHeader(
                profileAsync: profileAsync,
                userId: userId,
                strings: strings,
                isDark: isDark,
                onEditProfile: () => context.push('/profile/edit'),
              ),
            ),

            // ─── Content ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AnimatedSlide(
                      delay: 100,
                      child: _StatsRow(
                        reviewCountAsync: reviewCountAsync,
                        language: language,
                        isDark: isDark,
                        strings: strings,
                        onReviewsTap: () => context.push('/profile/reviews'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AnimatedSlide(
                      delay: 180,
                      child: _QuickActionsRow(
                        isDark: isDark,
                        strings: strings,
                        onQrTap: () => context.push('/qr'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Badges
                  _AnimatedSlide(
                    delay: 260,
                    child: reviewCountAsync.maybeWhen(
                      data: (count) {
                        final badges = computeEarnedBadges(count);
                        final locked = allBadges.where((b) => !badges.contains(b)).toList();
                        return _BadgesSection(
                          earned: badges,
                          locked: locked,
                          strings: strings,
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AnimatedSlide(
                      delay: 340,
                      child: _SettingsSection(
                        isDark: isDark,
                        language: language,
                        strings: strings,
                        ref: ref,
                        context: context,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AnimatedSlide(
                      delay: 420,
                      child: Text(
                        'by Tastanbek Nurislam\n© 2026 Abai University',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                          height: 1.8,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// WAVE HEADER
// ──────────────────────────────────────────────────────────────────────────────
class _WaveHeader extends StatelessWidget {
  const _WaveHeader({
    required this.profileAsync,
    required this.userId,
    required this.strings,
    required this.isDark,
    required this.onEditProfile,
  });

  final AsyncValue<UserProfile> profileAsync;
  final String? userId;
  final AppStrings strings;
  final bool isDark;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 340,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Wave background
          Positioned.fill(
            child: profileAsync.maybeWhen(
              data: (p) => _WaveHeaderBackground(
                isDark: isDark,
                imageUrl: p.coverUrl,
              ),
              orElse: () => _WaveHeaderBackground(isDark: isDark),
            ),
          ),

          // Top bar: back arrow area (safe area) + title
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const Spacer(),
                Text(
                  strings.profile,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Profile info centered
          profileAsync.when(
            data: (profile) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Avatar with glowing ring
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 3,
                          ),
                        ),
                        child: MonogramAvatar(
                          seedText: profile.displayName,
                          imageUrl: profile.avatarUrl,
                          size: 100,
                          showShadow: false,
                          isCircle: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    profile.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Obfuscated ID
                  Text(
                    _obfuscatedId(userId),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),

                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        profile.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Anonymous pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF1D4ED8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '100% ${strings.anonymousStudent}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: onEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      strings.editProfile,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, _) => Center(
              child: Text(e.toString(), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveHeaderBackground extends StatelessWidget {
  const _WaveHeaderBackground({required this.isDark, this.imageUrl});
  final bool isDark;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _WaveBackgroundPainter(isDark: isDark),
        ),
        if (imageUrl != null && imageUrl!.isNotEmpty)
          _buildCoverImage(imageUrl!),
      ],
    );
  }

  Widget _buildCoverImage(String path) {
    return Opacity(
      opacity: 0.3,
      child: Image(
        image: path.startsWith('http')
            ? NetworkImage(path)
            : AssetImage(path) as ImageProvider,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// WAVE PAINTER
// ──────────────────────────────────────────────────────────────────────────────
class _WaveBackgroundPainter extends CustomPainter {
  const _WaveBackgroundPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Background fill
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF0D1A3A), const Color(0xFF1E3A6E)]
            : [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Decorative circles / orbs
    final orbPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 90, orbPaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 70, orbPaint);

    // Bottom wave
    final wavePaint = Paint()
      ..color = (isDark
              ? const Color(0xFF0D1730)
              : const Color(0xFFF1F5F9))
          .withValues(alpha: 1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.78);
    path.cubicTo(
      size.width * 0.25, size.height * 0.65,
      size.width * 0.75, size.height * 0.90,
      size.width, size.height * 0.78,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);

    // Second softer wave
    final wave2Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.68);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.55,
      size.width * 0.65, size.height * 0.82,
      size.width, size.height * 0.70,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(_WaveBackgroundPainter old) => old.isDark != isDark;
}

// ──────────────────────────────────────────────────────────────────────────────
// STATS ROW
// ──────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.reviewCountAsync,
    required this.language,
    required this.isDark,
    required this.strings,
    required this.onReviewsTap,
  });

  final AsyncValue<int> reviewCountAsync;
  final AppLanguage language;
  final bool isDark;
  final AppStrings strings;
  final VoidCallback onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countValue = reviewCountAsync.maybeWhen(
      data: (v) => '$v',
      orElse: () => '—',
    );

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onReviewsTap,
            child: _StatTile(
              value: countValue,
              label: strings.reviewHistory,
              icon: Icons.rate_review_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              badge: '›',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            value: _languageShort(language),
            label: strings.language,
            icon: Icons.translate_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            value: isDark ? '🌙' : '☀️',
            label: isDark ? strings.darkMode : strings.lightMode,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF4C1D95), const Color(0xFF7C3AED)]
                  : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
    this.badge,
  });

  final String value;
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              if (badge != null)
                Text(
                  badge!,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ──────────────────────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.isDark,
    required this.strings,
    required this.onQrTap,
  });

  final bool isDark;
  final AppStrings strings;
  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.qr_code_scanner_rounded,
            label: strings.scanQr,
            subtitle: strings.scanSubtitle,
            color: const Color(0xFF0EA5E9),
            onTap: onQrTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: Icons.emoji_events_rounded,
            label: strings.ranking,
            subtitle: strings.rankingSubtitle,
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/leaderboard'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: Icons.share_rounded,
            label: strings.share,
            subtitle: strings.shareSubtitle,
            color: const Color(0xFFEC4899),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// BADGES
// ──────────────────────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.earned, required this.locked, required this.strings});
  final List<BadgeDefinition> earned;
  final List<BadgeDefinition> locked;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (earned.isEmpty && locked.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                strings.achievements,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${earned.length}/${allBadges.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.none,
            children: [
              ...earned.map((b) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BadgeCard(badge: b, locked: false, strings: strings),
              )),
              ...locked.map((b) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BadgeCard(badge: b, locked: true, strings: strings),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.locked, required this.strings});
  final BadgeDefinition badge;
  final bool locked;
  final AppStrings strings;

  void _showBadgeDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = locked ? Colors.grey : badge.color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    locked ? Icons.lock_outline_rounded : badge.icon,
                    size: 48,
                    color: color,
                  ),
                ),
                if (!locked) const _RotatingPulseRing(),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetail(
              locked ? strings.achievementLocked : strings.badgeLabel(badge.id),
              locked ? strings.achievementLockedDesc : strings.badgeDesc(badge.id),
              theme,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.1),
                  foregroundColor: color,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(strings.ok, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String desc, ThemeData theme) => Column(
    children: [
      Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        desc,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = locked ? Colors.grey : badge.color;

    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: locked
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.1),
          border: Border.all(
            color: locked ? Colors.grey.withValues(alpha: 0.15) : color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: locked ? 0.07 : 0.15),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : badge.icon,
                    color: color.withValues(alpha: locked ? 0.4 : 1),
                    size: 22,
                  ),
                ),
                if (!locked)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              locked ? '???' : badge.getLabel(strings),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                height: 1.3,
                color: locked ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingPulseRing extends StatefulWidget {
  const _RotatingPulseRing();

  @override
  State<_RotatingPulseRing> createState() => _RotatingPulseRingState();
}

class _RotatingPulseRingState extends State<_RotatingPulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 115,
        height: 115,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SETTINGS SECTION
// ──────────────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.isDark,
    required this.language,
    required this.strings,
    required this.ref,
    required this.context,
  });

  final bool isDark;
  final AppLanguage language;
  final AppStrings strings;
  final WidgetRef ref;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.settings,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.edit_note_rounded,
                iconColor: const Color(0xFF2563EB),
                title: strings.editName,
                subtitle: strings.editNameSubtitle,
                onTap: () async {
                  final profile = await ref.read(currentUserProfileProvider.future);
                  if (context.mounted) {
                    _showEditNameDialog(context, ref, profile.displayName, strings);
                  }
                },
              ),
              _divider(theme),
              _LanguageRow(language: language, strings: strings),
              _divider(theme),
              _SettingRow(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? const Color(0xFF6D28D9) : const Color(0xFFF59E0B),
                title: isDark ? strings.darkMode : strings.lightMode,
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
              _divider(theme),
              _SettingRow(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFFF97316),
                title: strings.helpAndSupport,
                subtitle: strings.helpSubtitle,
                onTap: () => _showHelpSupport(context),
              ),
              _divider(theme),
              _SettingRow(
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF10B981),
                title: strings.privacyPolicy,
                subtitle: strings.privacySubtitle,
                onTap: () => _launchPrivacyPolicy(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) =>
      Divider(height: 1, indent: 56, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5));
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}

class _LanguageRow extends ConsumerWidget {
  const _LanguageRow({required this.language, required this.strings});
  final AppLanguage language;
  final AppStrings strings;

  void _openLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LanguageBottomSheet(
        currentLanguage: language,
        onSelect: (lang) {
          ref.read(appLanguageProvider.notifier).setLanguage(lang);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flagEmoji = _languageFlag(language);

    return ListTile(
      onTap: () => _openLanguagePicker(context, ref),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.language_rounded, color: Color(0xFF059669), size: 20),
      ),
      title: Text(
        strings.language,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        _languageName(language),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flagEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── Language Bottom Sheet ────────────────────────────────────────────────────
class _LanguageBottomSheet extends StatelessWidget {
  const _LanguageBottomSheet({
    required this.currentLanguage,
    required this.onSelect,
  });

  final AppLanguage currentLanguage;
  final void Function(AppLanguage) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = context.strings;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language_rounded, color: Color(0xFF059669), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    strings.chooseLanguage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Language options
            ...AppLanguage.values.map((lang) {
              final isSelected = lang == currentLanguage;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () => onSelect(lang),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isSelected
                          ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB).withValues(alpha: 0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Flag
                        Text(
                          _languageFlag(lang),
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        // Name + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _languageName(lang),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : null,
                                ),
                              ),
                              Text(
                                _languageNativeName(lang),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Checkmark
                        AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2563EB),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

String _languageFlag(AppLanguage language) {
  return switch (language) {
    AppLanguage.kk => '🇰🇿',
    AppLanguage.ru => '🇷🇺',
    AppLanguage.en => '🇬🇧',
  };
}

String _languageNativeName(AppLanguage language) {
  return switch (language) {
    AppLanguage.kk => 'Қазақ тілі',
    AppLanguage.ru => 'Русский язык',
    AppLanguage.en => 'English language',
  };
}


// ──────────────────────────────────────────────────────────────────────────────
// ANIMATED SLIDE HELPER
// ──────────────────────────────────────────────────────────────────────────────
class _AnimatedSlide extends StatefulWidget {
  const _AnimatedSlide({required this.child, required this.delay});
  final Widget child;
  final int delay;

  @override
  State<_AnimatedSlide> createState() => _AnimatedSlideState();
}

class _AnimatedSlideState extends State<_AnimatedSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────────────────────────────────
String _obfuscatedId(String? userId) {
  if (userId == null || userId.length < 8) return 'Anonymous ID';
  return 'ID ${userId.substring(0, 4)}••••${userId.substring(userId.length - 4)}';
}

String _languageShort(AppLanguage language) {
  return switch (language) {
    AppLanguage.kk => 'KZ',
    AppLanguage.ru => 'RU',
    AppLanguage.en => 'EN',
  };
}

String _languageName(AppLanguage language) {
  return switch (language) {
    AppLanguage.kk => 'Қазақша',
    AppLanguage.ru => 'Русский',
    AppLanguage.en => 'English',
  };
}

void _showHelpSupport(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Help & Support is coming soon!')),
  );
}

void _launchPrivacyPolicy(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Privacy Policy is coming soon!')),
  );
}

void _showEditNameDialog(
    BuildContext context, WidgetRef ref, String currentName, AppStrings strings) {
  final controller = TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final isSaving = ref.watch(profileEditProvider).isSaving;
          return AlertDialog(
            title: Text(strings.editName),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: strings.displayName,
                hintText: strings.enterDisplayName,
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        await ref
                            .read(profileEditProvider.notifier)
                            .updateProfile(displayName: controller.text);
                        if (context.mounted &&
                            ref.read(profileEditProvider).error == null) {
                          Navigator.pop(context);
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(strings.save),
              ),
            ],
          );
        },
      );
    },
  );
}
