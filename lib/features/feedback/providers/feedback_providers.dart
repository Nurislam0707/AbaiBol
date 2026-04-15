import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/repositories/review_repository.dart';
import '../data/services/review_remote_service.dart';
import '../domain/models/review_catalog_item.dart';
import '../domain/models/review_catalog_summary.dart';
import '../domain/models/review_reference.dart';
import '../domain/models/review_target_kind.dart';
import '../domain/models/review_thread.dart';
import '../data/mock_feedback_repository.dart';
import '../../../shared/models/feedback_models.dart';

final reviewRemoteServiceProvider = Provider<ReviewRemoteService>(
  (ref) => ReviewRemoteService(ref.watch(supabaseClientProvider)),
);

final reviewsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.from('reviews').stream(primaryKey: ['id']);
});

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(
    remoteService: ref.watch(reviewRemoteServiceProvider),
    authService: ref.watch(anonymousAuthServiceProvider),
  ),
);

final teacherCatalogProvider = FutureProvider<List<ReviewCatalogItem>>(
  (ref) => ref.watch(reviewRepositoryProvider).fetchTeachers(),
);

final subjectCatalogProvider = FutureProvider<List<ReviewCatalogItem>>(
  (ref) => ref.watch(reviewRepositoryProvider).fetchSubjects(),
);

final buildingCatalogProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref.watch(reviewRepositoryProvider).fetchCatalogSummaries(ReviewTargetKind.building),
);

final studentLifeCatalogProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref.watch(reviewRepositoryProvider).fetchCatalogSummaries(ReviewTargetKind.studentLife),
);

final clubCatalogProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref.watch(reviewRepositoryProvider).fetchCatalogSummaries(ReviewTargetKind.club),
);

final teacherSummaryProvider = FutureProvider<List<ReviewCatalogSummary>>((ref) {
  // Watch the stream to trigger re-runs on any review change
  ref.watch(reviewsStreamProvider);
  
  return ref
      .watch(reviewRepositoryProvider)
      .fetchCatalogSummaries(ReviewTargetKind.teacher);
});

final subjectSummaryProvider = FutureProvider<List<ReviewCatalogSummary>>((ref) {
  // Watch the stream to trigger re-runs on any review change
  ref.watch(reviewsStreamProvider);

  return ref
      .watch(reviewRepositoryProvider)
      .fetchCatalogSummaries(ReviewTargetKind.subject);
});

final buildingSummaryProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref
      .watch(reviewRepositoryProvider)
      .fetchCatalogSummaries(ReviewTargetKind.building),
);

final studentLifeSummaryProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref
      .watch(reviewRepositoryProvider)
      .fetchCatalogSummaries(ReviewTargetKind.studentLife),
);

final clubSummaryProvider = FutureProvider<List<ReviewCatalogSummary>>(
  (ref) => ref
      .watch(reviewRepositoryProvider)
      .fetchCatalogSummaries(ReviewTargetKind.club),
);

final featuredTeacherProvider = FutureProvider<ReviewCatalogSummary?>((ref) async {
  final teachers = await ref.watch(teacherSummaryProvider.future);
  if (teachers.isEmpty) return null;

  final sorted = [...teachers]..sort((a, b) {
    final ratingCmp = b.averageRating.compareTo(a.averageRating);
    if (ratingCmp != 0) return ratingCmp;
    return b.totalReviews.compareTo(a.totalReviews);
  });

  return sorted.first;
});

final campusVibeProvider = StateProvider<CampusVibe>((ref) => CampusVibe.productive);

final trendingKeywordsProvider = Provider<Map<String, double>>((ref) {
  return const MockFeedbackRepository().trendingKeywords;
});

final dailyMysteryProvider = Provider<(ReviewCatalogSummary, String)>((ref) {
  return const MockFeedbackRepository().dailyMystery;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchCatalogProvider = FutureProvider<List<ReviewCatalogSummary>>((
  ref,
) async {
  final teachers = await ref.watch(teacherSummaryProvider.future);
  final subjects = await ref.watch(subjectSummaryProvider.future);
  final buildings = await ref.watch(buildingSummaryProvider.future);
  final studentLife = await ref.watch(studentLifeSummaryProvider.future);
  final clubs = await ref.watch(clubSummaryProvider.future);

  return [...teachers, ...subjects, ...buildings, ...studentLife, ...clubs];
});

final searchResultsProvider = FutureProvider<List<ReviewCatalogSummary>>((ref) async {
  final catalog = await ref.watch(searchCatalogProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(searchFilterProvider);

  return catalog.where((summary) {
    if (filter != null && summary.item.targetKind != filter.toReviewTargetKind()) {
      return false;
    }
    if (query.isEmpty) return true;
    return summary.item.name.toLowerCase().contains(query) ||
        summary.item.subtitle.toLowerCase().contains(query);
  }).toList();
});

final reviewThreadProvider =
    FutureProvider.family<ReviewThread, ReviewReference>(
      (ref, reference) =>
          ref.watch(reviewRepositoryProvider).fetchReviewThread(reference),
    );

final teacherSearchQueryProvider = StateProvider<String>((ref) => '');

final subjectSearchQueryProvider = StateProvider<String>((ref) => '');

final leaderboardTabProvider = StateProvider<FeedbackDomain>(
  (ref) => FeedbackDomain.teacher,
);

final leaderboardSearchProvider = StateProvider<String>((ref) => '');

enum LeaderboardSort { topRated, bottomRated, mostReviewed }

final leaderboardSearchQueryProvider = StateProvider<String>((ref) => '');
final leaderboardSortProvider = StateProvider<LeaderboardSort>((ref) => LeaderboardSort.topRated);

final filteredLeaderboardProvider = FutureProvider<List<ReviewCatalogSummary>>((ref) async {
  final activeTab = ref.watch(leaderboardTabProvider);
  final query = ref.watch(leaderboardSearchQueryProvider).toLowerCase();
  final sort = ref.watch(leaderboardSortProvider);

  final items = await (activeTab == FeedbackDomain.subject
      ? ref.watch(subjectSummaryProvider.future)
      : ref.watch(teacherSummaryProvider.future));

  // Filter by query
  var filtered = items.where((item) {
    if (query.isEmpty) return true;
    return item.item.name.toLowerCase().contains(query) ||
        item.item.subtitle.toLowerCase().contains(query);
  }).toList();

  // Sort
  switch (sort) {
    case LeaderboardSort.topRated:
      filtered.sort((a, b) {
        final cmp = b.averageRating.compareTo(a.averageRating);
        if (cmp != 0) return cmp;
        return b.totalReviews.compareTo(a.totalReviews);
      });
    case LeaderboardSort.bottomRated:
      // For bottom rated, we prioritize items with reviews but low scores.
      // Items with 0 reviews stay at the bottom of the list.
      filtered.sort((a, b) {
        if (a.totalReviews == 0 && b.totalReviews == 0) return 0;
        if (a.totalReviews == 0) return 1;
        if (b.totalReviews == 0) return -1;
        return a.averageRating.compareTo(b.averageRating);
      });
    case LeaderboardSort.mostReviewed:
      filtered.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
  }

  return filtered;
});

final searchFilterProvider = StateProvider<FeedbackDomain?>((ref) => null);

class RatingDraft {
  const RatingDraft({
    this.score = 8,
    this.comment = '',
    this.selectedTags = const <String>{},
  });

  final int score;
  final String comment;
  final Set<String> selectedTags;

  RatingDraft copyWith({
    int? score,
    String? comment,
    Set<String>? selectedTags,
  }) {
    return RatingDraft(
      score: score ?? this.score,
      comment: comment ?? this.comment,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

class RatingDraftNotifier extends FamilyNotifier<RatingDraft, String> {
  @override
  RatingDraft build(String arg) => const RatingDraft();

  void setScore(int value) => state = state.copyWith(score: value);

  void setComment(String value) => state = state.copyWith(comment: value);

  void toggleTag(String tag) {
    final next = <String>{...state.selectedTags};
    if (!next.add(tag)) {
      next.remove(tag);
    }
    state = state.copyWith(selectedTags: next);
  }
}

final ratingDraftProvider =
    NotifierProvider.family<RatingDraftNotifier, RatingDraft, String>(
      RatingDraftNotifier.new,
    );

class ReviewComposerState {
  const ReviewComposerState({
    this.rating = 0,
    this.text = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.submitSucceeded = false,
    this.selectedImage,
  });

  final int rating;
  final String text;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submitSucceeded;
  final XFile? selectedImage;

  bool get canSubmit => rating > 0 && !isSubmitting;

  ReviewComposerState copyWith({
    int? rating,
    String? text,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? submitSucceeded,
    XFile? selectedImage,
    bool clearImage = false,
  }) {
    return ReviewComposerState(
      rating: rating ?? this.rating,
      text: text ?? this.text,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
    );
  }
}

class ReviewComposerNotifier
    extends FamilyNotifier<ReviewComposerState, ReviewReference> {
  ReviewRepository get _repository => ref.read(reviewRepositoryProvider);

  @override
  ReviewComposerState build(ReviewReference arg) => const ReviewComposerState();

  void setRating(int rating) {
    state = state.copyWith(
      rating: rating.clamp(1, 5),
      submitSucceeded: false,
      clearError: true,
    );
  }

  void setText(String value) {
    state = state.copyWith(
      text: value,
      submitSucceeded: false,
      clearError: true,
    );
  }

  void setImage(XFile? image) {
    state = state.copyWith(
      selectedImage: image,
      clearImage: image == null,
      submitSucceeded: false,
      clearError: true,
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(
        errorMessage: 'Please enter a short review before submitting.',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitSucceeded: false,
      clearError: true,
    );

    try {
      String? uploadedImageUrl;
      if (state.selectedImage != null) {
        final bytes = await state.selectedImage!.readAsBytes();
        final ext = state.selectedImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final remoteService = ref.read(reviewRemoteServiceProvider);
        uploadedImageUrl = await remoteService.uploadImage(fileName, bytes);
      }

      await _repository.submitReview(
        reference: arg,
        rating: state.rating,
        text: state.text,
        imageUrl: uploadedImageUrl,
      );
      ref.invalidate(reviewThreadProvider(arg));
      state = state.copyWith(
        isSubmitting: false,
        submitSucceeded: true,
        clearError: true,
      );
    } on DuplicateReviewException {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'You have already submitted a review for this item.',
      );
    } on ReviewRateLimitException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Please wait ${error.retryAfter.inSeconds}s before posting again.',
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong while submitting your review.',
      );
    }
  }
}

final reviewComposerProvider =
    NotifierProvider.family<
      ReviewComposerNotifier,
      ReviewComposerState,
      ReviewReference
    >(ReviewComposerNotifier.new);

ReviewReference buildReviewReference({
  required ReviewTargetKind targetKind,
  required String targetId,
}) {
  return ReviewReference(targetKind: targetKind, targetId: targetId);
}
