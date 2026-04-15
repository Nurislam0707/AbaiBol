import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../../../shared/widgets/search_input.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_catalog_item.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectCatalogProvider);
    final query = ref.watch(subjectSearchQueryProvider).trim().toLowerCase();
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(
            title: strings.subjectReviews,
            subtitle: strings.anonymousFeedbackForSubjects,
            canPop: true,
          ),
          SliverToBoxAdapter(
            key: const ValueKey('subjects_catalog_content'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                key: const ValueKey('subjects_column'),
                children: [
                  SearchInput(
                    key: const ValueKey('subjects_search_input'),
                    hintText: strings.searchSubjects,
                    onChanged: (value) =>
                        ref.read(subjectSearchQueryProvider.notifier).state =
                            value,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  subjectsAsync.when(
                    data: (subjects) {
                      final filtered = subjects.where((subject) {
                        if (query.isEmpty) {
                          return true;
                        }
                        return subject.name.toLowerCase().contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return _CatalogEmptyState(
                          key: const ValueKey('subjects_empty_state'),
                          title: strings.noSubjectsFound,
                          subtitle: strings.emptySubjectsSubtitle,
                        );
                      }

                      return Column(
                        key: const ValueKey('subjects_list_container'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CatalogHero(
                            key: const ValueKey('subjects_hero'),
                            title: strings.subjectReviews,
                            subtitle: strings.subjectsAvailable(filtered.length),
                            icon: Icons.menu_book_rounded,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ...filtered.map(
                            (subject) => Padding(
                              key: ValueKey('subject_card_${subject.id}'),
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _CatalogCard(
                                item: subject,
                                onTap: () => context.push(
                                  '/reviews/${ReviewTargetKind.subject.value}/${subject.id}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const _CatalogLoadingState(
                      key: ValueKey('subjects_loading'),
                    ),
                    error: (error, _) => _CatalogEmptyState(
                      key: const ValueKey('subjects_error_state'),
                      title: strings.unableToLoadSubjects,
                      subtitle: error.toString(),
                    ),
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

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(icon, size: 46, color: Colors.white70),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({super.key, required this.item, required this.onTap});

  final ReviewCatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          MonogramAvatar(seedText: item.name, size: 62),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 16,
                        color: Color(0xFF0EA5E9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Open reviews',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: const Color(0xFF0EA5E9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _CatalogLoadingState extends StatelessWidget {
  const _CatalogLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
