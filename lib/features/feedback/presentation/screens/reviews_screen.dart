import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../domain/models/review_entry.dart';
import '../../domain/models/review_reference.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key, required this.reference});

  final ReviewReference reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewThreadAsync = ref.watch(reviewThreadProvider(reference));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: AppBody(
        bottomPadding: 140,
        slivers: [
          GlassHeader(title: strings.anonymousReviews, canPop: true),
          SliverToBoxAdapter(
            key: const ValueKey('reviews_content'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: reviewThreadAsync.when(
                data: (thread) => Column(
                  key: const ValueKey('reviews_column'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: const ValueKey('reviews_header_card'),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.9),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MonogramAvatar(
                            seedText: thread.item.name,
                            imageUrl: thread.item.imageUrl,
                            size: 72,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread.item.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  thread.item.subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Text(
                                      thread.totalReviews == 0
                                          ? '0.0'
                                          : thread.averageRating.toStringAsFixed(1),
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RatingStars(
                                            rating: thread.totalReviews == 0
                                                ? 0
                                                : thread.averageRating.round(),
                                            size: 18,
                                            activeColor: Colors.amber,
                                            inactiveColor: Colors.white24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            strings.anonymousReviewsCount(thread.totalReviews),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.7),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
                    if (thread.myReview != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      SurfaceCard(
                        key: const ValueKey('my_review_notice'),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.yourReviewExists,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    strings.cooldownMessage(
                                      _getTargetLocalized(strings, reference.targetKind),
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      strings.recentReviews,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (thread.reviews.isEmpty)
                      SurfaceCard(
                        key: const ValueKey('no_reviews_card'),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.noReviewsYet,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.beFirstReviewer,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...thread.reviews.map(
                        (review) => Padding(
                          key: ValueKey('review_${review.id}'),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                  ],
                ),
                loading: () => const Padding(
                  key: ValueKey('reviews_loading'),
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SurfaceCard(
                  key: const ValueKey('reviews_error'),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: reviewThreadAsync.maybeWhen(
        data: (thread) => SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: PrimaryButton(
            label: thread.canSubmitReview
                ? strings.leaveAnonymousReview
                : strings.reviewAlreadySubmitted,
            icon: thread.canSubmitReview
                ? Icons.edit_note_rounded
                : Icons.check_circle_outline_rounded,
            onPressed: thread.canSubmitReview
                ? () => context.push(
                    '/reviews/${reference.targetKind.value}/${reference.targetId}/add',
                  )
                : null,
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({required this.review});

  final ReviewEntry review;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> with TickerProviderStateMixin {
  late bool _isLiked;
  late int _helpfulCount;
  bool _isReported = false;

  late AnimationController _likeController;
  late Animation<double> _likeAnimation;
  late AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.review.isLikedByMe;
    _helpfulCount = widget.review.helpfulCount;

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _likeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 60),
    ]).animate(_likeController);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _helpfulCount += _isLiked ? 1 : -1;
    });

    if (_isLiked) {
      HapticFeedback.mediumImpact();
      _likeController.forward(from: 0.0);
      _burstController.forward(from: 0.0);
    } else {
      _likeController.reverse(from: 0.0);
      _burstController.reset();
    }

    final userId = ref.read(anonymousAuthServiceProvider).currentUserId;
    if (userId != null) {
      ref.read(reviewRemoteServiceProvider).toggleHelpful(
            reviewId: widget.review.id,
            userId: userId,
            removeLike: !_isLiked,
          ).catchError((_) {
        // Optimistic UI rollback
        if (mounted) {
          setState(() {
            _isLiked = !_isLiked;
            _helpfulCount += _isLiked ? 1 : -1;
          });
        }
      });
    }
  }

  void _showReportSheet() {
    final strings = ref.read(appStringsProvider);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return AlertDialog(
          title: Text(strings.reportReview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.whatIsWrong, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _buildReportOption(strings.reportSpam),
              _buildReportOption(strings.reportContent),
              _buildReportOption(strings.reportFalseInfo),
              _buildReportOption(strings.reportOther),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(String reason) {
    final strings = ref.read(appStringsProvider);
    return ListTile(
      title: Text(reason),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () async {
        Navigator.pop(context);
        final userId = ref.read(anonymousAuthServiceProvider).currentUserId;
        bool success = false;
        if (userId != null) {
          await ref.read(reviewRemoteServiceProvider).submitReport(
            reviewId: widget.review.id,
            userId: userId,
            reason: reason,
          );
          success = true;
        }
        setState(() => _isReported = true);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.reportSubmitted)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final theme = Theme.of(context);

    if (_isReported) {
      return SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.sentToModeration,
                  style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.anonymousStudent, style: theme.textTheme.titleSmall),
                    Text(_formatDate(widget.review.createdAt, strings), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Flexible(
                child: RatingStars(
                  rating: widget.review.rating,
                  size: 16, // Slightly smaller to be safer
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _showReportSheet,
                icon: const Icon(Icons.more_vert_rounded),
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          if (widget.review.text.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(widget.review.text, style: theme.textTheme.bodyMedium),
          ],
          
          if (widget.review.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppNetworkImage(
                imageUrl: widget.review.imageUrl!,
                height: 180,
                width: double.infinity,
                placeholderIcon: Icons.image_rounded,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _LikeBurst(controller: _burstController),
                  AnimatedBuilder(
                    animation: _likeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _likeAnimation.value,
                        child: IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            _isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
                            color: _isLiked ? AppColors.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (_helpfulCount > 0)
                Flexible(
                  child: Text(
                    strings.helpfulCountLabel(_helpfulCount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _isLiked ? AppColors.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              Flexible(
                child: TextButton.icon(
                  onPressed: _showReportSheet,
                  icon: Icon(
                    Icons.report_problem_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  label: Text(
                    strings.report,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dateTime, AppStrings strings) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inMinutes < 1) {
    return strings.justNow;
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m';
  }
  if (difference.inDays < 1) {
    return strings.hoursAgo(difference.inHours);
  }
  if (difference.inDays < 7) {
    return strings.daysAgo(difference.inDays);
  }
  return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
}

String _getTargetLocalized(AppStrings strings, ReviewTargetKind kind) {
  return switch (kind) {
    ReviewTargetKind.teacher => strings.teacherReviews,
    ReviewTargetKind.subject => strings.subjectReviews,
    ReviewTargetKind.building => strings.buildingReviews,
    ReviewTargetKind.studentLife => strings.studentLifeReviews,
    ReviewTargetKind.club => strings.clubReviews,
  };
}

class _LikeBurst extends StatelessWidget {
  const _LikeBurst({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.isDismissed) return const SizedBox.shrink();
        return CustomPaint(
          size: const Size(40, 40),
          painter: _LikeBurstPainter(progress: controller.value),
        );
      },
    );
  }
}

class _LikeBurstPainter extends CustomPainter {
  _LikeBurstPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Configurable particle count
    const particleCount = 28;
    final random = math.Random(42); // Consistent look
    
    final rainbow = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
    ];

    for (int i = 0; i < particleCount; i++) {
      final angle = (i * math.pi * 2 / particleCount) + (random.nextDouble() * 0.5);
      
      // Multi-stage movement: expand then drift
      final moveProgress = Curves.easeOutQuart.transform(progress);
      final fadeProgress = Curves.easeIn.transform(progress);
      
      final radius = 10 + (moveProgress * 35);
      final particlePos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final particleSize = (1.0 - fadeProgress) * 4.0;
      paint.color = rainbow[i % rainbow.length].withValues(alpha: 1.0 - progress);
      
      // Draw various shapes for "YouTube" feel
      if (i % 3 == 0) {
        canvas.drawCircle(particlePos, particleSize, paint);
      } else if (i % 3 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: particlePos, width: particleSize * 1.5, height: particleSize * 1.5),
          paint,
        );
      } else {
        // Simple star shape
        final path = Path();
        for (int j = 0; j < 5; j++) {
          final pAngle = (j * math.pi * 2 / 5) - math.pi / 2;
          final px = particlePos.dx + math.cos(pAngle) * particleSize * 1.2;
          final py = particlePos.dy + math.sin(pAngle) * particleSize * 1.2;
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LikeBurstPainter oldDelegate) => oldDelegate.progress != progress;
}
