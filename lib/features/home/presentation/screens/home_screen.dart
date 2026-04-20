import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/feedback/data/mock_feedback_repository.dart';
import '../../../../shared/models/feedback_models.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../../feedback/domain/models/review_catalog_summary.dart';
import '../../../feedback/domain/models/review_target_kind.dart';
import '../../../feedback/providers/feedback_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const repository = MockFeedbackRepository();
    final categories = repository.categories;
    final activitiesAsync = ref.watch(recentActivityProvider);
    final featuredAsync = ref.watch(featuredTeacherProvider);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(
            title: strings.anonymousCampusReviews,
            subtitle: strings.shareFeedbackSafely,
          ),

          SliverToBoxAdapter(
            key: const ValueKey('home_professional_content'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                key: const ValueKey('home_main_column'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // ─── Professional Hub Stats/Actions ──────────────────────────
                  _HomeHub(strings: strings),
                  
                  const SizedBox(height: AppSpacing.xxl),
                
                  SectionHeading(
                    key: const ValueKey('heading_categories'),
                    title: strings.chooseCategory,
                    trailing: TextButton.icon(
                      onPressed: () => context.go('/leaderboard'),
                      icon: const Icon(Icons.leaderboard_rounded, size: 18),
                      label: Text(strings.viewRanking),
                    ),
                  ),
                
                  const SizedBox(height: AppSpacing.md),
                
                  // ─── Professional Grid ──────────────────────────────────
                  _CategoriesGrid(
                    key: const ValueKey('categories_grid'),
                    categories: categories, 
                    strings: strings, 
                    isDark: isDark,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ─── Featured Spotlight ──────────────────────────────
                  featuredAsync.when(
                    data: (featured) => featured != null
                        ? _FeaturedCard(
                            key: ValueKey('featured_${featured.item.id}'),
                            featured: featured, 
                            strings: strings,
                          )
                        : const SizedBox.shrink(),
                    loading: () => const _FeaturedLoading(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  
                  SectionHeading(
                    title: strings.recentActivity,
                    trailing: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.amber),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // --- Recent Activity Feed ---
                  activitiesAsync.when(
                    data: (activities) => Column(
                      children: activities.map(
                        (activity) => Padding(
                          key: ValueKey('activity_${activity.id}'),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ActivityCard(activity: activity, isDark: isDark),
                        ),
                      ).toList(),
                    ),
                    loading: () => Column(
                      children: List.generate(3, (index) => const _ActivityLoading()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _HomeHub extends StatefulWidget {
  const _HomeHub({required this.strings});
  final AppStrings strings;

  @override
  State<_HomeHub> createState() => _HomeHubState();
}

class _HomeHubState extends State<_HomeHub> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _CarouselData(
        tag: '100% ${widget.strings.anonymousStudent.toUpperCase()}',
        title: widget.strings.helpImproveLife,
        subtitle: widget.strings.anonymousExplanation,
        icon: Icons.auto_graph_rounded,
        stats: [
          _HubStatData(label: '12K+', sub: widget.strings.reviews),
          _HubStatData(label: '4.8', sub: widget.strings.happiness),
        ],
      ),
      _CarouselData(
        tag: '🛡️ ${widget.strings.anonymousAndSafe}',
        title: widget.strings.anonymousFeedbackForInstructors,
        subtitle: widget.strings.rateTeachersFairly,
        icon: Icons.school_rounded,
        stats: [
          _HubStatData(label: '500+', sub: widget.strings.teacherReviews),
          _HubStatData(label: '4.6', sub: widget.strings.qualityLevel),
        ],
      ),
      _CarouselData(
        tag: '🏛️ ${widget.strings.scanQr}',
        title: widget.strings.anonymousFeedbackForBuildings,
        subtitle: widget.strings.scanSubtitle,
        icon: Icons.business_rounded,
        stats: [
          _HubStatData(label: '15+', sub: widget.strings.buildingReviews),
          _HubStatData(label: '4.2', sub: widget.strings.cleanliness),
        ],
      ),
      _CarouselData(
        tag: '📚 ${widget.strings.subjectReviews.toUpperCase()}',
        title: widget.strings.anonymousFeedbackForSubjects,
        subtitle: widget.strings.shareSubjectsOpinion,
        icon: Icons.auto_stories_rounded,
        stats: [
          _HubStatData(label: '300+', sub: widget.strings.subjectReviews),
          _HubStatData(label: '4.9', sub: widget.strings.useful),
        ],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: slides.length,
            itemBuilder: (context, index) => _CarouselCard(
              data: slides[index],
              strings: widget.strings,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselData {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_HubStatData> stats;

  _CarouselData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stats,
  });
}

class _HubStatData {
  final String label;
  final String sub;
  _HubStatData({required this.label, required this.sub});
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.data, required this.strings});
  final _CarouselData data;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              data.icon,
              size: 140,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      data.tag,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ...data.stats.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _HubStat(label: s.label, sub: s.sub),
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubStat extends StatelessWidget {
  const _HubStat({required this.label, required this.sub});
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FeaturedLoading extends StatelessWidget {
  const _FeaturedLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
       height: 130,
       decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
         borderRadius: BorderRadius.circular(28),
       ),
       child: const Center(child: CircularProgressIndicator()),
     );
  }
}

// ─── Featured Card ───────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({super.key, required this.featured, required this.strings});
  final ReviewCatalogSummary featured;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'featured-${featured.item.id}',
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push(
          '/reviews/${featured.item.targetKind.value}/${featured.item.id}',
        ),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -20,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🔥 ${strings.teacherOfTheWeek}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      featured.item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          featured.item.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          featured.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${strings.totalReviewsCount(featured.totalReviews)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Categories Grid ─────────────────────────────────────────────────────────
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    super.key,
    required this.categories,
    required this.strings,
    required this.isDark,
  });
  final List<FeedbackCategory> categories;
  final AppStrings strings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 2;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: categories.map((item) {
            final title = switch (item.domain) {
              FeedbackDomain.teacher => strings.teacherReviews,
              FeedbackDomain.subject => strings.subjectReviews,
              FeedbackDomain.building => strings.buildingReviews,
              FeedbackDomain.studentLife => strings.studentLifeReviews,
              FeedbackDomain.club => strings.clubReviews,
            };

            return SizedBox(
              width: itemWidth,
              child: AspectRatio(
                aspectRatio: 0.85,
                child: SurfaceCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    switch (item.domain) {
                      case FeedbackDomain.teacher:
                        context.push('/teachers');
                        return;
                      case FeedbackDomain.subject:
                        context.push('/subjects');
                        return;
                      case FeedbackDomain.building:
                        context.push('/faculties/building');
                        return;
                      case FeedbackDomain.studentLife:
                      case FeedbackDomain.club:
                        context.push('/student-life');
                        return;
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: AppNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.rating}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '• ${item.reviews}',
                                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Activity Card ───────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({super.key, required this.activity, required this.isDark});
  final ActivityFeedItem activity;
  final bool isDark;

  String _getCategoryLabel(String category, AppStrings strings) {
    final lower = category.toLowerCase();
    if (lower.contains('мұғалім') || lower.contains('преподаватель') || lower.contains('teacher')) return strings.teacher;
    if (lower.contains('пән') || lower.contains('предмет') || lower.contains('subject')) return strings.subject;
    if (lower.contains('өмір') || lower.contains('жизнь') || lower.contains('life') || lower.contains('university')) return strings.studentLife;
    if (lower.contains('клуб') || lower.contains('club')) return strings.club;
    if (lower.contains('корпус') || lower.contains('building')) return strings.building;
    return category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              activity.isRating ? Icons.auto_awesome_rounded : Icons.chat_bubble_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getCategoryLabel(activity.category, context.strings).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      activity.time, // This is also hardcoded in mock data, but we'll leave it as semi-dynamic for now
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${activity.text}"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
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

class _ActivityLoading extends StatelessWidget {
  const _ActivityLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80, 
                  height: 10, 
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  )
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, 
                  height: 14, 
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
