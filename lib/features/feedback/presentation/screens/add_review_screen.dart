import 'dart:io';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_body.dart';
import '../../../../shared/widgets/glass_header.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/surface_card.dart';
import '../../domain/models/review_reference.dart';
import '../../domain/models/review_target_kind.dart';
import '../../providers/feedback_providers.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  const AddReviewScreen({super.key, required this.reference});

  final ReviewReference reference;

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> with SingleTickerProviderStateMixin {
  final Set<String> _selectedTags = {};
  String _customText = '';
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<String> _getAvailableTags(AppStrings strings) {
    switch (widget.reference.targetKind) {
      case ReviewTargetKind.teacher:
        return [strings.clearMaterial, strings.strict, strings.fairGrading, strings.interesting, strings.experienced, strings.difficult];
      case ReviewTargetKind.subject:
        return [strings.useful, strings.manyTasks, strings.interesting, strings.necessary, strings.difficult];
      case ReviewTargetKind.building:
        return [strings.cleanliness, strings.comfortable, strings.cold, strings.new_, strings.crowded];
      case ReviewTargetKind.studentLife:
      case ReviewTargetKind.club:
        return [strings.active, strings.useful, strings.friendly, strings.interesting, strings.expensive];
    }
  }

  Color _getRatingColor(int rating) {
    if (rating == 0) return AppColors.textSecondary.withValues(alpha: 0.3);
    if (rating <= 2) return AppColors.danger;
    if (rating == 3) return AppColors.accent;
    return AppColors.success;
  }

  String _getRatingText(int rating, AppStrings strings) {
    if (rating == 0) return strings.rating;
    return strings.ratingLabel(rating);
  }

  void _submitReview() {
    final composerNotifier = ref.read(reviewComposerProvider(widget.reference).notifier);
    
    // Combine tags and text
    String finalReviewText = '';
    if (_selectedTags.isNotEmpty) {
      finalReviewText += '[${_selectedTags.join(', ')}] ';
    }
    finalReviewText += _customText.trim();
    
    composerNotifier.setText(finalReviewText);
    composerNotifier.submit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    ref.listen(reviewComposerProvider(widget.reference), (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.submitSucceeded && previous?.submitSucceeded != true) {
        _confettiController.play();
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(strings.reviewSubmittedAnonymously),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                duration: const Duration(seconds: 2),
              ),
            );
            navigator.pop();
          }
        });
      }
    });

    final reviewThreadAsync = ref.watch(reviewThreadProvider(widget.reference));
    final composer = ref.watch(reviewComposerProvider(widget.reference));
    final composerNotifier = ref.read(reviewComposerProvider(widget.reference).notifier);

    final ratingColor = _getRatingColor(composer.rating);
    final isRatingGiven = composer.rating > 0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
      Scaffold(
      body: AppBody(
        bottomPadding: 150,
        slivers: [
          GlassHeader(title: strings.addReview, canPop: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            sliver: SliverList.list(
              children: [
                // 100% Anonymous Security Badge
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '100% ${strings.anonymousStudent}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                reviewThreadAsync.when(
                  data: (thread) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Contextual Target info
                      SurfaceCard(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          children: [
                            MonogramAvatar(
                              seedText: thread.item.name,
                              imageUrl: thread.item.imageUrl,
                              size: 84,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              thread.item.name,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              thread.item.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Interactive Big Rating Widget
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isRatingGiven ? ratingColor.withValues(alpha: 0.5) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isRatingGiven)
                              BoxShadow(
                                color: ratingColor.withValues(alpha: 0.15),
                                blurRadius: 40,
                              ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: isRatingGiven ? ratingColor : theme.textTheme.titleMedium?.color,
                                fontWeight: isRatingGiven ? FontWeight.bold : FontWeight.normal,
                              ),
                              child: Text(_getRatingText(composer.rating, strings)),
                            ),
                            const SizedBox(height: 20),
                            RatingStars(
                              rating: composer.rating,
                              size: 48,
                              activeColor: ratingColor,
                              onRatingSelected: composerNotifier.setRating,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Step-by-Step Reveal
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        child: !isRatingGiven
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Quick Tags
                                  SurfaceCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${strings.reviewsHeader}:', style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _getAvailableTags(strings).map((tag) {
                                            final isSelected = _selectedTags.contains(tag);
                                            return ChoiceChip(
                                              label: Text(tag),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (selected) {
                                                    _selectedTags.add(tag);
                                                  } else {
                                                    _selectedTags.remove(tag);
                                                  }
                                                });
                                              },
                                              selectedColor: ratingColor.withValues(alpha: 0.2),
                                              backgroundColor: isDark ? AppColors.darkMuted : AppColors.surfaceMuted,
                                              labelStyle: TextStyle(
                                                color: isSelected ? ratingColor : null,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: isSelected ? ratingColor : Colors.transparent,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  
                                  // Text Field
                                  SurfaceCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${strings.expressOpinion}:', style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 14),
                                        TextField(
                                          minLines: 4,
                                          maxLines: 6,
                                          onChanged: (text) => _customText = text,
                                          decoration: InputDecoration(
                                            hintText: strings.writeYourReview,
                                            filled: true,
                                            fillColor: isDark ? AppColors.darkMuted : AppColors.surfaceMuted,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  
                                  // Image Picker
                                  if (composer.selectedImage == null)
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final picker = ImagePicker();
                                        final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                                        if (file != null) {
                                          composerNotifier.setImage(file);
                                        }
                                      },
                                      icon: const Icon(Icons.add_photo_alternate_outlined),
                                      label: Text(strings.uploadImageLabel),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    )
                                  else
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(composer.selectedImage!.path),
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton.filled(
                                            onPressed: () => composerNotifier.setImage(null),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black54,
                                              foregroundColor: Colors.white,
                                            ),
                                            icon: const Icon(Icons.close_rounded),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => SurfaceCard(
                    child: Text(error.toString(), style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: composer.rating > 0
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getRatingColor(composer.rating).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: composer.isSubmitting ? null : _submitReview,
                  style: FilledButton.styleFrom(
                    backgroundColor: _getRatingColor(composer.rating),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: composer.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    composer.isSubmitting ? strings.submitting : strings.submitAnonymously,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
      ),
      // Confetti overlay on top of Scaffold
      IgnorePointer(
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2, // downward
          emissionFrequency: 0.05,
          numberOfParticles: 25,
          maxBlastForce: 30,
          minBlastForce: 10,
          gravity: 0.3,
          colors: const [
            Color(0xFF2563EB),
            Color(0xFF7C3AED),
            Color(0xFF059669),
            Color(0xFFF59E0B),
            Color(0xFFEC4899),
          ],
        ),
      ),
    ],
    );
  }
}
