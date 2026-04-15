import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class StudentLifeCategoriesScreen extends ConsumerWidget {
  const StudentLifeCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(studentLifeCatalogProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.studentLifeReviews, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            sliver: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
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
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final summary = items[index];
                    return SurfaceCard(
                      child: Row(
                        children: [
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
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber,
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
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {
                                    if (summary.item.id == 'clubs') {
                                      context.push('/clubs');
                                    } else {
                                      context.push(
                                        '/reviews/${ReviewTargetKind.studentLife.value}/${summary.item.id}',
                                      );
                                    }
                                  },
                                  child: Text(strings.view),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (summary.item.imageUrl != null)
                            AppNetworkImage(
                              imageUrl: summary.item.imageUrl!,
                              width: 96,
                              height: 96,
                              borderRadius: BorderRadius.circular(18),
                              placeholderIcon: Icons.auto_awesome_rounded,
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
