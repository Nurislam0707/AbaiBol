import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/search_input.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class ClubsScreen extends ConsumerStatefulWidget {
  const ClubsScreen({super.key});

  @override
  ConsumerState<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends ConsumerState<ClubsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final theme = Theme.of(context);
    final clubsAsync = ref.watch(clubCatalogProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.clubReviews, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            sliver: clubsAsync.when(
              data: (allClubs) {
                final clubs = allClubs
                    .where(
                      (summary) => summary.item.name.toLowerCase().contains(
                        _query.toLowerCase(),
                      ),
                    )
                    .toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      strings.chooseCategory,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SearchInput(
                      hintText: strings.search,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 24),
                    if (clubs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(strings.noReviewsYet),
                        ),
                      )
                    else
                      ...clubs.map(
                        (summary) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SurfaceCard(
                            onTap: () => context.push(
                              '/reviews/${ReviewTargetKind.club.value}/${summary.item.id}',
                            ),
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
                                      const SizedBox(height: 4),
                                      Row(
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
                                      FilledButton.tonal(
                                        onPressed: () => context.push(
                                          '/reviews/${ReviewTargetKind.club.value}/${summary.item.id}',
                                        ),
                                        child: Text(strings.anonymousReviews),
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
                                    placeholderIcon: Icons.groups_rounded,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ]),
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
