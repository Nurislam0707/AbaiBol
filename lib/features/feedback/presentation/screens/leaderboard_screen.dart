import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/feedback_models.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../../../core/utils/asset_utils.dart';
import '../../domain/models/review_catalog_summary.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

  void _showQuickInfoSheet(BuildContext context, ReviewCatalogSummary summary, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickInfoSheet(summary: summary, strings: strings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(leaderboardTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    final summaryAsync = ref.watch(filteredLeaderboardProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            const _BackgroundDecorations(),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _LeaderboardHeader(isDark: isDark, strings: strings),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _LeaderboardSearchField(
                        onChanged: (val) => ref.read(leaderboardSearchProvider.notifier).state = val,
                        hintText: strings.searchPlaceholder,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          _PremiumTabSwitcher(
                            activeTab: activeTab,
                            onTabChanged: (tab) =>
                                ref.read(leaderboardTabProvider.notifier).state = tab,
                          ),
                          const SizedBox(height: 16),
                          _SortChips(strings: strings),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              summaryAsync.when(
                data: (items) {
                  final podium = items.take(3).toList();
                  final remainder = items.skip(3).toList();
                  final totalReviews = items.fold(0, (sum, item) => sum + item.totalReviews);

                  return SliverToBoxAdapter(
                    key: const ValueKey('leaderboard_content'),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: Column(
                        key: const ValueKey('leaderboard_column'),
                        children: [
                          _AnimatedIn(
                            key: const ValueKey('podium_animated'),
                            delay: 200,
                            child: _LeaderboardPodium(
                              podium: podium,
                              onTap: (s) => _showQuickInfoSheet(context, s, strings),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _AnimatedIn(
                            key: const ValueKey('ranking_header_animated'),
                            delay: 350,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    strings.currentRanking.toUpperCase(),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const _LiveIndicator(),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      strings.totalReviewsCount(totalReviews),
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ...remainder.asMap().entries.map((entry) {
                            return _AnimatedIn(
                              key: ValueKey('leaderboard_item_${entry.value.item.id}'),
                              delay: 400 + (entry.key * 50),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LeaderboardListCard(
                                  summary: entry.value,
                                  index: entry.key + 3,
                                  strings: strings,
                                  onTap: () => _showQuickInfoSheet(context, entry.value, strings),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 12),

                          _AnimatedIn(
                            key: const ValueKey('cta_banner_animated'),
                            delay: 600,
                            child: _CallToActionBanner(
                              strings: strings,
                              activeTab: activeTab,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(child: Text(strings.deletingReviewError)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _QuickInfoSheet extends StatelessWidget {
  const _QuickInfoSheet({required this.summary, required this.strings});
  final ReviewCatalogSummary summary;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Row(
              children: [
                MonogramAvatar(
                  seedText: summary.item.name,
                  size: 80,
                  isCircle: true,
                  showShadow: false,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.item.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.item.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                _QuickStatCard(
                  label: strings.averageRating,
                  value: summary.averageRating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _QuickStatCard(
                  label: strings.reviews,
                  value: summary.totalReviews.toString(),
                  icon: Icons.chat_bubble_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Highlights
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.highlights.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HighlightPill(label: strings.clearMaterial, icon: Icons.lightbulb_outline),
                _HighlightPill(label: strings.fairGrading, icon: Icons.gavel_outlined),
                _HighlightPill(label: strings.fastResponse, icon: Icons.bolt_rounded),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/reviews/${summary.item.targetKind.value}/${summary.item.id}/add');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(strings.addReview),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/reviews/${summary.item.targetKind.value}/${summary.item.id}');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(strings.readReviews),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightPill extends StatelessWidget {
  const _HighlightPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({required this.isDark, required this.strings});
  final bool isDark;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D1A3A), const Color(0xFF1E3A6E)]
              : [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    strings.ranking,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                strings.leaderboardSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumTabSwitcher extends ConsumerWidget {
  const _PremiumTabSwitcher({required this.activeTab, required this.onTabChanged});
  final FeedbackDomain activeTab;
  final ValueChanged<FeedbackDomain> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildTab(context, strings.teachers, FeedbackDomain.teacher),
          _buildTab(context, strings.subjects, FeedbackDomain.subject),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, FeedbackDomain tab) {
    final theme = Theme.of(context);
    final isSelected = activeTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(tab),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortChips extends ConsumerWidget {
  const _SortChips({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSort = ref.watch(leaderboardSortProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SortChip(
            label: strings.topRated,
            icon: Icons.trending_up_rounded,
            isSelected: activeSort == LeaderboardSort.topRated,
            onTap: () => ref.read(leaderboardSortProvider.notifier).state = LeaderboardSort.topRated,
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: strings.mostReviewed,
            icon: Icons.forum_rounded,
            isSelected: activeSort == LeaderboardSort.mostReviewed,
            onTap: () => ref.read(leaderboardSortProvider.notifier).state = LeaderboardSort.mostReviewed,
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: strings.bottomRated,
            icon: Icons.trending_down_rounded,
            isSelected: activeSort == LeaderboardSort.bottomRated,
            onTap: () => ref.read(leaderboardSortProvider.notifier).state = LeaderboardSort.bottomRated,
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSearchField extends StatefulWidget {
  const _LeaderboardSearchField({required this.onChanged, required this.hintText});
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<_LeaderboardSearchField> createState() => _LeaderboardSearchFieldState();
}

class _LeaderboardSearchFieldState extends State<_LeaderboardSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({
    super.key,
    required this.podium,
    required this.onTap,
  });
  final List<ReviewCatalogSummary> podium;
  final ValueChanged<ReviewCatalogSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (podium.length > 1)
            Expanded(
              child: _PodiumItem(
                summary: podium[1],
                rank: 2,
                color: const Color(0xFF94A3B8),
                onTap: () => onTap(podium[1]),
              ),
            ),

          Expanded(
            child: _PodiumItem(
              summary: podium[0],
              rank: 1,
              color: const Color(0xFFFACC15),
              onTap: () => onTap(podium[0]),
            ),
          ),

          if (podium.length > 2)
            Expanded(
              child: _PodiumItem(
                summary: podium[2],
                rank: 3,
                color: const Color(0xFFD97706),
                onTap: () => onTap(podium[2]),
              ),
            )
          else if (podium.length == 1)
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.summary,
    required this.rank,
    required this.color,
    required this.onTap,
  });

  final ReviewCatalogSummary summary;
  final int rank;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = rank == 1;
    final avatarSize = isFirst ? 90.0 : 70.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (isFirst) const _PulseEffect(color: Color(0xFF60A5FA)),
              
              if (isFirst)
                Positioned(
                  top: -16,
                  child: RotationTransition(
                    turns: const AlwaysStoppedAnimation(-15 / 360),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 32,
                      color: const Color(0xFFFACC15),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

              Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: MonogramAvatar(
                    seedText: summary.item.name,
                    imageUrl: summary.item.imageUrl ?? (summary.item.targetKind == ReviewTargetKind.teacher 
                        ? AssetUtils.getTeacherAsset(summary.item.name, faculty: summary.item.department)
                        : summary.item.targetKind == ReviewTargetKind.building 
                            ? AssetUtils.getBuildingAsset(summary.item.name)
                            : null),
                    size: avatarSize,
                    showShadow: false,
                    isCircle: true,
                  ),
                ),
              ),

              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFirst)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.star_rounded, color: Colors.white, size: 10),
                        ),
                      Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            summary.item.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: isFirst ? 14 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppColors.accent, size: 12),
                const SizedBox(width: 3),
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 8, color: theme.colorScheme.outlineVariant),
                const SizedBox(width: 6),
                Text(
                  '${summary.totalReviews}',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardListCard extends StatelessWidget {
  const _LeaderboardListCard({
    super.key,
    required this.summary,
    required this.index,
    required this.strings,
    required this.onTap,
  });
  final ReviewCatalogSummary summary;
  final int index;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnrated = summary.totalReviews == 0;
    final ratingText = isUnrated ? strings.noReviewsShort : summary.averageRating.toStringAsFixed(1);
    final rating = isUnrated ? 0.0 : summary.averageRating;

    Color ratingColor(double r) {
      if (isUnrated) return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
      if (r >= 4.5) return const Color(0xFF10B981);
      if (r >= 4.0) return const Color(0xFF3B82F6);
      if (r >= 3.0) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    }

    return SurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Row(
              children: [
                MonogramAvatar(
                  seedText: summary.item.name,
                  imageUrl: summary.item.imageUrl ?? (summary.item.targetKind == ReviewTargetKind.teacher 
                      ? AssetUtils.getTeacherAsset(summary.item.name, faculty: summary.item.department)
                      : summary.item.targetKind == ReviewTargetKind.building 
                          ? AssetUtils.getBuildingAsset(summary.item.name)
                          : null),
                  size: 48,
                  showShadow: false,
                  isCircle: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              summary.item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: isUnrated ? theme.colorScheme.onSurface.withValues(alpha: 0.7) : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (summary.trendingScore > summary.averageRating + 0.15 && summary.totalReviews >= 3)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: _TrendingBadge(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(child: _CategoryBadge(label: summary.item.subtitle)),
                          const SizedBox(width: 8),
                          Icon(Icons.chat_bubble_outline_rounded, size: 10, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(width: 3),
                          Text(
                            isUnrated ? strings.noReviews : strings.totalReviewsCount(summary.totalReviews),
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _MiniRatingBar(rating: rating, color: ratingColor(rating)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: ratingColor(rating).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isUnrated ? '—' : rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: ratingColor(rating),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        strings.rating.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
                          color: isUnrated ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRatingBar extends StatelessWidget {
  const _MiniRatingBar({required this.rating, required this.color});
  final double rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          FractionallySizedBox(
            widthFactor: rating / 5.0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PulseEffect extends StatefulWidget {
  const _PulseEffect({required this.color});
  final Color color;

  @override
  State<_PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<_PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _scale = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
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
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: 0.4),
                widget.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 200,
            left: -30,
            child: Icon(Icons.school_outlined, size: 150, color: iconColor),
          ),
          Positioned(
            bottom: 100,
            right: -40,
            child: Icon(Icons.menu_book_rounded, size: 200, color: iconColor),
          ),
          Positioned(
            top: 500,
            right: 40,
            child: Icon(Icons.auto_stories_outlined, size: 100, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _CallToActionBanner extends StatelessWidget {
  const _CallToActionBanner({
    super.key,
    required this.strings,
    required this.activeTab,
  });
  final AppStrings strings;
  final FeedbackDomain activeTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rate_review_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            strings.helpImproveLife,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            activeTab == FeedbackDomain.subject
                ? strings.shareSubjectsOpinion
                : strings.rateTeachersFairly,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (activeTab == FeedbackDomain.subject) {
                  context.push('/subjects');
                } else {
                  context.push('/teachers');
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(strings.addReview),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            strings.noReviewsYet,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            strings.beFirstReviewer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIn extends StatefulWidget {
  const _AnimatedIn({
    super.key,
    required this.child,
    required this.delay,
  });
  final Widget child;
  final int delay;

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
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
class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator();

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            context.strings.liveStatus,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _TrendingBadge extends StatelessWidget {
  const _TrendingBadge();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.whatshot_rounded, size: 10, color: Colors.orange),
          const SizedBox(width: 2),
          Text(
            strings.trending,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
