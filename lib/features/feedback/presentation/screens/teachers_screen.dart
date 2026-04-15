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

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key, this.facultyId});

  final String? facultyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teacherCatalogProvider);
    final query = ref.watch(teacherSearchQueryProvider).trim().toLowerCase();
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(
            title: strings.teacherReviews,
            subtitle: strings.anonymousFeedbackForInstructors,
            canPop: true,
          ),
          SliverToBoxAdapter(
            key: const ValueKey('teachers_catalog_content'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                key: const ValueKey('teachers_column'),
                children: [
                  SearchInput(
                    key: const ValueKey('teacher_search_input'),
                    hintText: strings.searchTeachersOrDepartments,
                    onChanged: (value) =>
                        ref.read(teacherSearchQueryProvider.notifier).state =
                            value,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  teachersAsync.when(
                    data: (teachers) {
                      final filtered = teachers.where((teacher) {
                        if (query.isEmpty) {
                          return true;
                        }
                        return teacher.name.toLowerCase().contains(query) ||
                            (teacher.department ?? '').toLowerCase().contains(
                              query,
                            );
                      }).toList();

                      if (filtered.isEmpty) {
                        return _CatalogEmptyState(
                          key: const ValueKey('teachers_empty_state'),
                          title: strings.noTeachersFound,
                          subtitle: strings.emptyTeachersSubtitle,
                        );
                      }

                      return Column(
                        key: const ValueKey('teachers_list_container'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CatalogHero(
                            key: const ValueKey('teachers_hero'),
                            title: strings.teacherReviews,
                            subtitle: strings.teachersAvailable(filtered.length),
                            icon: Icons.school_rounded,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ...filtered.map(
                            (teacher) => Padding(
                              key: ValueKey('teacher_card_${teacher.id}'),
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _CatalogCard(
                                item: teacher,
                                onTap: () => context.push(
                                  '/reviews/${ReviewTargetKind.teacher.value}/${teacher.id}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const _CatalogLoadingState(
                      key: ValueKey('teachers_loading'),
                    ),
                    error: (error, _) => _CatalogEmptyState(
                      key: const ValueKey('teachers_error_state'),
                      title: strings.unableToLoadTeachers,
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
            color: AppColors.primary.withValues(alpha: 0.22),
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
      child: Column(
        children: [
          Row(
            children: [
              MonogramAvatar(
                seedText: item.name,
                imageUrl: item.imageUrl,
                size: 62,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                      child: Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetaChip(icon: Icons.visibility_outlined, label: 'Open reviews'),
              const SizedBox(width: 8),
              _MetaChip(icon: Icons.shield_outlined, label: 'Anonymous'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Colors.black.withValues(alpha: 0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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
          const Icon(Icons.forum_outlined, size: 40, color: AppColors.primary),
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
