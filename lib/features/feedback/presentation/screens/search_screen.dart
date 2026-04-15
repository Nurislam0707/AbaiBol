import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_catalog_summary.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';
import '../../../../shared/models/feedback_models.dart';
import '../../../../shared/widgets/app_network_image.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedDomain = ref.watch(searchFilterProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.search, canPop: false),
          
          // --- Refined Search Header ---
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SearchBar(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                  onClear: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),
          ),

          // --- Animated Focus Filters ---
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _DomainChip(
                    label: strings.all,
                    selected: selectedDomain == null,
                    icon: Icons.auto_awesome_rounded,
                    onTap: () => ref.read(searchFilterProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 12),
                  _DomainChip(
                    label: strings.teacherReviews,
                    selected: selectedDomain == FeedbackDomain.teacher,
                    icon: Icons.school_rounded,
                    onTap: () => ref.read(searchFilterProvider.notifier).state = FeedbackDomain.teacher,
                  ),
                  const SizedBox(width: 12),
                  _DomainChip(
                    label: strings.subjectReviews,
                    selected: selectedDomain == FeedbackDomain.subject,
                    icon: Icons.auto_stories_rounded,
                    onTap: () => ref.read(searchFilterProvider.notifier).state = FeedbackDomain.subject,
                  ),
                  const SizedBox(width: 12),
                  _DomainChip(
                    label: strings.buildingReviews,
                    selected: selectedDomain == FeedbackDomain.building,
                    icon: Icons.apartment_rounded,
                    onTap: () => ref.read(searchFilterProvider.notifier).state = FeedbackDomain.building,
                  ),
                ],
              ),
            ),
          ),

          // --- Search Results with Repaint Boundaries for Stability ---
          resultsAsync.when(
            data: (results) {
              if (results.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(hasQuery: query.isNotEmpty),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _AnimatedIn(
                    key: ValueKey('search_result_${results[i].item.id}'),
                    delay: i * 40, // Snappier delay
                    child: _SearchResultCard(
                      summary: results[i],
                      index: i,
                    ),
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    '${strings.errorOccurred}: $err',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    // Use solid backgrounds to prevent ghosting/artifacts from BackdropFilter
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), // More visible bg
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: _isFocused
              ? Colors.blue.withValues(alpha: 0.6)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: _isFocused ? 2.0 : 1.5, // Thicker border for visibility
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: strings.searchTeacherOrSubject,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.search_rounded,
                    key: ValueKey(_isFocused),
                    size: 22,
                    color: _isFocused ? Colors.blue : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 20),
                  onPressed: widget.onClear,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // Vibrant Blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected 
              ? null 
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: const [], // Shadow removed as requested
          border: Border.all(
            color: selected 
                ? Colors.blue.withValues(alpha: 0.2) 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({
    required this.summary,
    required this.index,
  });

  final ReviewCatalogSummary summary;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final kind = summary.item.targetKind;
    final isTeacher = kind == ReviewTargetKind.teacher;

    final accentColor = isTeacher ? AppColors.primary : const Color(0xFF0EA5E9);

    final rating = summary.averageRating;
    final reviewCount = summary.totalReviews;
    final isTopRated = rating >= 4.5 && reviewCount > 0;

    return RepaintBoundary(
      child: SurfaceCard(
        onTap: () => context.push('/reviews/${kind.value}/${summary.item.id}'),
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with Glow & Repaint Boundary
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isTopRated)
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: AppNetworkImage(
                      imageUrl: summary.item.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                summary.item.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isTopRated)
                               const Padding(
                                 padding: EdgeInsets.only(left: 6),
                                 child: Icon(Icons.verified_rounded, size: 16, color: Color(0xFF3B82F6)),
                               ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          summary.item.subtitle.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _CompactRatingBadge(rating: rating),
                            const SizedBox(width: 12),
                            Text(
                              '• ${strings.totalReviewsCount(reviewCount)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
            
            // Domain Indicator Bubble
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTeacher ? Icons.person_3_rounded : Icons.library_books_rounded,
                      size: 10,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactRatingBadge extends StatelessWidget {
  const _CompactRatingBadge({required this.rating});
  final double rating;

  Color get _color {
    if (rating == 0) return Colors.grey;
    if (rating < 3.0) return const Color(0xFFF43F5E);
    if (rating < 4.0) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            rating == 0 ? '--' : rating.toStringAsFixed(1),
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.manage_search_rounded,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            hasQuery ? strings.noResultsFound : strings.startSearching,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery 
                ? strings.tryOtherKeywords 
                : strings.searchPrompt,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
        vsync: this, duration: const Duration(milliseconds: 400)); // Snappier
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
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
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
