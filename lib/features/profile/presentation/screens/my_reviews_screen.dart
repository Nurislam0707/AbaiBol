import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/feedback_models.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/my_review_item.dart';
import '../../providers/profile_providers.dart';
import '../../../feedback/presentation/screens/rating_screen.dart';
import '../../../../core/localization/app_strings.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      body: AppBody(
        slivers: [
          GlassHeader(title: strings.reviewHistory, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.reviews_outlined,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            strings.noReviewsWritten,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.allReviewsSafe,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList.separated(
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _SlidableReviewItem(review: reviews[index]);
                  },
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    error.toString(),
                    style: theme.textTheme.bodyMedium,
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

class _SlidableReviewItem extends ConsumerWidget {
  const _SlidableReviewItem({required this.review});
  final MyReviewItem review;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteReview),
        content: Text(strings.confirmDeleteReview),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(reviewActionProvider.notifier).deleteReview(review.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.reviewDeleted)),
        );
      }
    }
  }

  void _onEdit(BuildContext context) {
    // Navigate to RatingScreen with existing data
    final domain = switch (review.targetKind) {
      'teacher' => FeedbackDomain.teacher,
      'subject' => FeedbackDomain.subject,
      'building' => FeedbackDomain.building,
      'studentLife' => FeedbackDomain.studentLife,
      'club' => FeedbackDomain.club,
      _ => FeedbackDomain.studentLife,
    };

    context.push(
      '/rating',
      extra: RatingScreenArgs(
        domain: domain,
        title: review.targetName,
        subtitle: review.targetName, // Use same for subtitle if unknown
        imageUrl: review.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return Slidable(
      key: ValueKey(review.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(), // Telegram/WhatsApp style staggered motion
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: _onEdit,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: strings.edit,
            // Match card rounding on the left to avoid "sharp corner" clash
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
          ),
          SlidableAction(
            onPressed: (context) => _confirmDelete(context, ref),
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: strings.delete,
            // Match card rounding on the right
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
          ),
        ],
      ),
      child: _MyReviewCard(review: review),
    );
  }
}

class _MyReviewCard extends StatelessWidget {
  const _MyReviewCard({required this.review});

  final MyReviewItem review;

  Color _ratingColor(int rating) {
    if (rating <= 2) return AppColors.danger;
    if (rating == 3) return AppColors.accent;
    return AppColors.success;
  }

  IconData _targetIcon(String kind) {
    return switch (kind) {
      'teacher' => Icons.school_rounded,
      'subject' => Icons.menu_book_rounded,
      'building' => Icons.apartment_rounded,
      'studentLife' => Icons.emoji_events_rounded,
      _ => Icons.group_rounded,
    };
  }

  String _targetLabel(String kind, AppStrings strings) {
    return switch (kind) {
      'teacher' => strings.teacher,
      'subject' => strings.subject,
      'building' => strings.building,
      'studentLife' => strings.studentLife,
      _ => strings.club,
    };
  }

  String _formatDate(DateTime dt, AppStrings strings) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays < 1) return strings.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return strings.daysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    final ratingColor = _ratingColor(review.rating);

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with colored accent
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: ratingColor.withValues(alpha: 0.07),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _targetIcon(review.targetKind),
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.targetName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _targetLabel(review.targetKind, strings),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Rating badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: ratingColor.withValues(alpha: 0.15),
                    border: Border.all(color: ratingColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: ratingColor),
                      const SizedBox(width: 4),
                      Text(
                        '${review.rating}/5',
                        style: TextStyle(
                          color: ratingColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.text.trim().isNotEmpty)
                  Text(
                    review.text,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  )
                else
                  Text(
                    strings.textlessReview,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                if (review.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppNetworkImage(
                      imageUrl: review.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      placeholderIcon: Icons.image_rounded,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(review.createdAt, strings),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                if (review.helpfulCount > 0) ...[
                  const Spacer(),
                  Icon(
                    Icons.thumb_up_alt_rounded,
                    size: 13,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    strings.helpfulCountLabel(review.helpfulCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Swipe Indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(Icons.keyboard_double_arrow_left_rounded, 
                   size: 10, 
                   color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                 ),
                 const SizedBox(width: 4),
                 Text(
                   strings.swipeToManage,
                   style: theme.textTheme.labelSmall?.copyWith(
                     fontSize: 8,
                     fontWeight: FontWeight.w900,
                     letterSpacing: 0.5,
                     color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
