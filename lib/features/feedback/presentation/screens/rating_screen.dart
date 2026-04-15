import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/localization/app_strings.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/feedback_models.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/feedback_providers.dart';

class RatingScreenArgs {
  const RatingScreenArgs({
    required this.domain,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.heroTag,
  });

  final FeedbackDomain domain;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? heroTag;
}

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key, required this.args});

  final RatingScreenArgs args;

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> with TickerProviderStateMixin {
  // Creative Tags: Legendary Status
  static const List<Map<String, dynamic>> tags = [
    {'label': '💎 Hidden Gem', 'color': Color(0xFF0EA5E9)},
    {'label': '🔥 Game Changer', 'color': Color(0xFFF43F5E)},
    {'label': '🏆 Legendary', 'color': Color(0xFFF59E0B)},
    {'label': '📚 Clear Path', 'color': Color(0xFF10B981)},
    {'label': '⚡ Fair & Just', 'color': Color(0xFF6366F1)},
    {'label': '✨ Inspiring', 'color': Color(0xFFA855F7)},
  ];

  late AnimationController _stepController;
  late Animation<double> _stepAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _stepAnimation = CurvedAnimation(
        parent: _stepController, curve: Curves.easeOutQuart);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    Future.microtask(() {
      final draft = ref.read(ratingDraftProvider(widget.args.title));
      if (draft.score > 0) _stepController.value = 1.0;
    });
  }

  @override
  void dispose() {
    _stepController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onScoreChanged(int score, RatingDraftNotifier notifier) {
    notifier.setScore(score);
    if (score > 0 && _stepController.status == AnimationStatus.dismissed) {
      _stepController.forward();
    }
  }

  void _handleSubmit() {
    _confettiController.play();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(context.strings.reviewSubmittedAnonymously),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 160),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final draft = ref.watch(ratingDraftProvider(widget.args.title));
    final notifier = ref.read(ratingDraftProvider(widget.args.title).notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseBlue = const Color(0xFF3B82F6);
    final scoreColor = switch (draft.score) {
      0 => theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
      <= 3 => const Color(0xFFF43F5E),
      <= 6 => const Color(0xFFF59E0B),
      _ => baseBlue,
    };

    // Contribution Level Logic
    double contribution = 0.0;
    if (draft.score > 0) contribution += 0.4;
    if (draft.selectedTags.isNotEmpty) contribution += 0.3;
    if (draft.comment.length > 20) contribution += 0.3;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          AppBody(
            bottomPadding: 220,
            slivers: [
              GlassHeader(title: strings.rating, canPop: true),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Social Momentum Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.momentumIndicator(4),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _RatingHero(args: widget.args, scoreColor: scoreColor, score: draft.score),
                      
                      const SizedBox(height: 48),

                      // Section 1: Score with Emotional Ticks
                      _ShadowFreeSection(
                        title: strings.setScore,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 1; i <= 10; i++)
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: GestureDetector(
                                        onTap: () => _onScoreChanged(i, notifier),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          height: 44,
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: draft.score >= i 
                                                ? scoreColor 
                                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$i',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                                color: draft.score >= i ? Colors.white : theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Text(
                              draft.score > 0 ? '${draft.score}.0 / 10' : strings.selectScorePrompt,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                color: scoreColor,
                              ),
                            ),
                            const SizedBox(height: 28),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: scoreColor,
                                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                                trackHeight: 8,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                                overlayColor: scoreColor.withValues(alpha: 0.1),
                              ),
                              child: Slider(
                                value: draft.score.toDouble(),
                                min: 0,
                                max: 10,
                                divisions: 10,
                                onChanged: (v) => _onScoreChanged(v.round(), notifier),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Section 2 & 3: Details
                      SizeTransition(
                        sizeFactor: _stepAnimation,
                        child: FadeTransition(
                          opacity: _stepAnimation,
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _ShadowFreeSection(
                                title: widget.args.domain == FeedbackDomain.teacher ? strings.thisTeacherIs : strings.theSubjectIs,
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: tags.map((tag) {
                                    final isSelected = draft.selectedTags.contains(tag['label']);
                                    final tagColor = tag['color'] as Color;
                                    return GestureDetector(
                                      onTap: () => notifier.toggleTag(tag['label']),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? tagColor.withValues(alpha: 0.1) : theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected ? tagColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          tag['label'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? tagColor : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _ShadowFreeSection(
                                title: strings.shareExperience,
                                child: TextField(
                                  maxLines: 4,
                                  onChanged: notifier.setComment,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    hintText: strings.writeDetailedReview,
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // cinematic Dual Confetti Overlay
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 0, // Shoot to the right
              emissionFrequency: 0.1,
              numberOfParticles: 15,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.2,
              colors: const [Colors.blue, Colors.purple, Colors.orange, Colors.pink, Colors.green],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi, // Shoot to the left
              emissionFrequency: 0.1,
              numberOfParticles: 15,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.2,
              colors: const [Colors.blue, Colors.purple, Colors.orange, Colors.pink, Colors.green],
            ),
          ),

          // Bottom Bar with Contribution Progress
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: draft.score > 0 ? Offset.zero : const Offset(0, 1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Contribution Bar
                          Row(
                            children: [
                              Text(
                                strings.qualityLevel,
                                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: contribution,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: scoreColor,
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: strings.submit,
                            icon: Icons.rocket_launch_rounded,
                            onPressed: _handleSubmit,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                              const SizedBox(width: 4),
                              Text(
                                strings.anonymousAndSafe,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _ShadowFreeSection extends StatelessWidget {
  const _ShadowFreeSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 16,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RatingHero extends StatelessWidget {
  const _RatingHero({required this.args, required this.scoreColor, required this.score});
  final RatingScreenArgs args;
  final Color scoreColor;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTeacher = args.domain == FeedbackDomain.teacher;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Emotional Atmospheric Glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withValues(alpha: score > 0 ? 0.3 : 0),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scoreColor.withValues(alpha: 0.1), width: 8),
              ),
            ),
            if (isTeacher && args.imageUrl != null)
              AppNetworkImage(
                imageUrl: args.imageUrl!,
                width: 110, height: 110,
                borderRadius: BorderRadius.circular(55),
              )
            else
               Container(
                 width: 110, height: 110,
                 decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                 child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 40),
               ),
            if (isTeacher)
              Positioned(
                right: 0, bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 3),
                  ),
                  child: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          args.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        const SizedBox(height: 4),
        Text(
          args.subtitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
