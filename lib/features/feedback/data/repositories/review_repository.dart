import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/data/services/anonymous_auth_service.dart';
import '../../domain/models/review_catalog_item.dart';
import '../../domain/models/review_catalog_summary.dart';
import '../../domain/models/review_reference.dart';
import '../../domain/models/review_thread.dart';
import '../../domain/models/review_target_kind.dart';
import '../services/review_remote_service.dart';

class DuplicateReviewException implements Exception {
  const DuplicateReviewException();
}

class ReviewRateLimitException implements Exception {
  const ReviewRateLimitException(this.retryAfter);

  final Duration retryAfter;
}

class ReviewRepository {
  const ReviewRepository({
    required ReviewRemoteService remoteService,
    required AnonymousAuthService authService,
  }) : _remoteService = remoteService,
       _authService = authService;

  final ReviewRemoteService _remoteService;
  final AnonymousAuthService _authService;

  Future<List<ReviewCatalogItem>> fetchTeachers() => _remoteService.fetchTeachers();
  Future<List<ReviewCatalogItem>> fetchSubjects() => _remoteService.fetchSubjects();
  Future<List<ReviewCatalogItem>> fetchBuildings() => _remoteService.fetchBuildings();
  Future<List<ReviewCatalogItem>> fetchStudentLifeItems() => _remoteService.fetchStudentLife();
  Future<List<ReviewCatalogItem>> fetchClubs() => _remoteService.fetchClubs();

  Future<List<ReviewCatalogSummary>> fetchCatalogSummaries(
    ReviewTargetKind targetKind,
  ) async {
    final items = await switch (targetKind) {
      ReviewTargetKind.teacher => fetchTeachers(),
      ReviewTargetKind.subject => fetchSubjects(),
      ReviewTargetKind.building => fetchBuildings(),
      ReviewTargetKind.studentLife => fetchStudentLifeItems(),
      ReviewTargetKind.club => fetchClubs(),
    };
    final ratings = await _remoteService.fetchRatingsForTargetKind(targetKind);

    final totals = <String, double>{};
    final counts = <String, int>{};
    final weightedTotals = <String, double>{};
    final weightedCounts = <String, double>{};
    
    final targetColumn = _getTargetColumn(targetKind);
    final now = DateTime.now();

    for (final row in ratings) {
      final targetId = row[targetColumn] as String;
      final rating = (row['rating'] as int).toDouble();
      final createdAt = DateTime.parse(row['created_at'] as String);
      
      // Basic aggregation
      totals[targetId] = (totals[targetId] ?? 0.0) + rating;
      counts[targetId] = (counts[targetId] ?? 0) + 1;

      // Trending analysis (last 7 days get 2x weight)
      final isRecent = now.difference(createdAt).inDays <= 7;
      final weight = isRecent ? 2.0 : 1.0;
      
      weightedTotals[targetId] = (weightedTotals[targetId] ?? 0.0) + (rating * weight);
      weightedCounts[targetId] = (weightedCounts[targetId] ?? 0.0) + weight;
    }

    return items.map((item) {
      final totalReviews = counts[item.id] ?? 0;
      final averageRating = totalReviews == 0
          ? 0.0
          : (totals[item.id] ?? 0.0) / totalReviews;
          
      final trendingScore = totalReviews == 0
          ? 0.0
          : (weightedTotals[item.id] ?? 0.0) / (weightedCounts[item.id] ?? 1.0);
          
      return ReviewCatalogSummary(
        item: item,
        averageRating: averageRating,
        totalReviews: totalReviews,
        trendingScore: trendingScore,
      );
    }).toList();
  }

  Future<ReviewThread> fetchReviewThread(ReviewReference reference) async {
    final userId = _authService.currentUserId;
    final item = await _remoteService.fetchItem(reference);
    if (item == null) {
      throw StateError('Review target was not found.');
    }

    final reviews = await _remoteService.fetchReviews(reference, userId ?? '');
    final myReview = userId == null
        ? null
        : reviews.where((review) => review.userId == userId).firstOrNull;

    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
              reviews.length;

    // Users can submit a review if they haven't submitted one yet,
    // OR if their last review for this target is more than 7 days old.
    final canSubmitReview = myReview == null ||
        DateTime.now().difference(myReview.createdAt).inDays >= 7;

    return ReviewThread(
      item: item,
      reviews: reviews,
      averageRating: averageRating,
      totalReviews: reviews.length,
      canSubmitReview: canSubmitReview,
      myReview: myReview,
    );
  }

  String _getTargetColumn(ReviewTargetKind kind) {
    return switch (kind) {
      ReviewTargetKind.teacher => 'teacher_id',
      ReviewTargetKind.subject => 'subject_id',
      ReviewTargetKind.building => 'building_id',
      ReviewTargetKind.studentLife => 'student_life_id',
      ReviewTargetKind.club => 'club_id',
    };
  }

  Future<void> submitReview({
    required ReviewReference reference,
    required int rating,
    required String text,
    String? imageUrl,
  }) async {
    final user = await _authService.ensureSignedIn();

    // 1. Spam protection (30s cooldown between ANY review)
    final latestReviewAt = await _remoteService.fetchLatestReviewTimestamp(user.id);
    if (latestReviewAt != null) {
      final elapsed = DateTime.now().difference(latestReviewAt);
      const cooldown = Duration(seconds: 30);
      if (elapsed < cooldown) {
        throw ReviewRateLimitException(cooldown - elapsed);
      }
    }

    // 2. 7-day cooldown check for THIS specific target
    final reviews = await _remoteService.fetchReviews(reference, user.id);
    final myRecentReview = reviews
        .where((r) => r.userId == user.id)
        .where((r) => DateTime.now().difference(r.createdAt).inDays < 7)
        .firstOrNull;

    if (myRecentReview != null) {
      throw const DuplicateReviewException();
    }

    try {
      await _remoteService.insertReview(
        reference: reference,
        userId: user.id,
        rating: rating,
        text: text.trim(),
        imageUrl: imageUrl,
      );
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const DuplicateReviewException();
      }
      rethrow;
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
