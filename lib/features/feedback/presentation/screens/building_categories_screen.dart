import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class BuildingCategoriesScreen extends ConsumerWidget {
  const BuildingCategoriesScreen({super.key, required this.facultyId});

  final String facultyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final buildingsAsync = ref.watch(buildingCatalogProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.buildingReviews, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            sliver: buildingsAsync.when(
              data: (buildings) {
                // We filter by faculty if needed, but the user requested sections "inside" the building.
                // For now we show all buildings/sections registered in the DB.
                if (buildings.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.noReviewsYet,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList.separated(
                  itemCount: buildings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final summary = buildings[index];
                    return SurfaceCard(
                      onTap: () => context.push(
                        '/reviews/${ReviewTargetKind.building.value}/${summary.item.id}',
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            ),
                            child: Icon(
                              Icons.apartment_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.item.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${summary.averageRating.toStringAsFixed(1)} • ${strings.anonymousReviewsCount(summary.totalReviews)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text(error.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
