import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/review_catalog_item.dart';
import '../../domain/models/review_entry.dart';
import '../../domain/models/review_reference.dart';
import '../../domain/models/review_target_kind.dart';

class ReviewRemoteService {
  const ReviewRemoteService(this._client);

  final SupabaseClient _client;

  Future<List<ReviewCatalogItem>> fetchTeachers() async {
    final rows = await _client
        .from('teachers')
        .select('id, name, department, image_url')
        .order('name');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ReviewCatalogItem(
            id: row['id'] as String,
            name: row['name'] as String,
            department: row['department'] as String?,
            imageUrl: row['image_url'] as String?,
            targetKind: ReviewTargetKind.teacher,
          ),
        )
        .toList();
  }

  Future<List<ReviewCatalogItem>> fetchSubjects() async {
    final rows = await _client
        .from('subjects')
        .select('id, name, image_url')
        .order('name');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ReviewCatalogItem(
            id: row['id'] as String,
            name: row['name'] as String,
            imageUrl: row['image_url'] as String?,
            targetKind: ReviewTargetKind.subject,
          ),
        )
        .toList();
  }

  Future<List<ReviewCatalogItem>> fetchBuildings() async {
    final rows = await _client
        .from('buildings')
        .select('id, name, category, image_url')
        .order('name');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ReviewCatalogItem(
            id: row['id'] as String,
            name: row['name'] as String,
            department: row['category'] as String?,
            imageUrl: row['image_url'] as String?,
            targetKind: ReviewTargetKind.building,
          ),
        )
        .toList();
  }

  Future<List<ReviewCatalogItem>> fetchStudentLife() async {
    final rows = await _client
        .from('student_life_items')
        .select('id, name, description, image_url')
        .order('name');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ReviewCatalogItem(
            id: row['id'] as String,
            name: row['name'] as String,
            department: row['description'] as String?,
            imageUrl: row['image_url'] as String?,
            targetKind: ReviewTargetKind.studentLife,
          ),
        )
        .toList();
  }

  Future<List<ReviewCatalogItem>> fetchClubs() async {
    final rows = await _client
        .from('clubs')
        .select('id, name, category, image_url')
        .order('name');

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ReviewCatalogItem(
            id: row['id'] as String,
            name: row['name'] as String,
            department: row['category'] as String?,
            imageUrl: row['image_url'] as String?,
            targetKind: ReviewTargetKind.club,
          ),
        )
        .toList();
  }

  Future<ReviewCatalogItem?> fetchItem(ReviewReference reference) async {
    final table = switch (reference.targetKind) {
      ReviewTargetKind.teacher => 'teachers',
      ReviewTargetKind.subject => 'subjects',
      ReviewTargetKind.building => 'buildings',
      ReviewTargetKind.studentLife => 'student_life_items',
      ReviewTargetKind.club => 'clubs',
    };

    final columns = switch (reference.targetKind) {
      ReviewTargetKind.teacher => 'id, name, department, image_url',
      ReviewTargetKind.subject => 'id, name, image_url',
      ReviewTargetKind.building => 'id, name, category, image_url',
      ReviewTargetKind.studentLife => 'id, name, description, image_url',
      ReviewTargetKind.club => 'id, name, category, image_url',
    };

    final row = await _client
        .from(table)
        .select(columns)
        .eq('id', reference.targetId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return ReviewCatalogItem(
      id: row['id'] as String,
      name: row['name'] as String,
      department: (row['department'] ?? row['category'] ?? row['description']) as String?,
      imageUrl: row['image_url'] as String?,
      targetKind: reference.targetKind,
    );
  }

  Future<List<ReviewEntry>> fetchReviews(ReviewReference reference, String currentUserId) async {
    final targetColumn = _getTargetColumn(reference.targetKind);
    final rows = await _client
        .from('reviews')
        .select('id, user_id, teacher_id, subject_id, building_id, student_life_id, club_id, text, rating, created_at, image_url, helpful_count, review_likes(user_id)')
        .eq(targetColumn, reference.targetId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (row) {
            final likes = (row['review_likes'] as List<dynamic>?) ?? [];
            final isLikedByMe = likes.any((like) => like['user_id'] == currentUserId);
            
            return ReviewEntry(
              id: row['id'] as String,
              userId: row['user_id'] as String,
              rating: row['rating'] as int,
              text: row['text'] as String? ?? '',
              createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
              targetKind: reference.targetKind,
              targetId: row[targetColumn] as String,
              imageUrl: row['image_url'] as String?,
              helpfulCount: row['helpful_count'] as int? ?? 0,
              isLikedByMe: isLikedByMe,
            );
          },
        )
        .toList();
  }

  Future<DateTime?> fetchLatestReviewTimestamp(String userId) async {
    final row = await _client
        .from('reviews')
        .select('created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return DateTime.parse(row['created_at'] as String).toLocal();
  }

  Future<List<Map<String, dynamic>>> fetchRatingsForTargetKind(
    ReviewTargetKind targetKind,
  ) async {
    final targetColumn = _getTargetColumn(targetKind);

    final rows = await _client
        .from('reviews')
        .select('$targetColumn, rating, created_at')
        .not(targetColumn, 'is', null);

    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> insertReview({
    required ReviewReference reference,
    required String userId,
    required int rating,
    required String text,
    String? imageUrl,
  }) {
    final payload = <String, dynamic>{
      'user_id': userId,
      'rating': rating,
      'text': text,
      if (imageUrl != null) 'image_url': imageUrl,
      'teacher_id': reference.targetKind == ReviewTargetKind.teacher ? reference.targetId : null,
      'subject_id': reference.targetKind == ReviewTargetKind.subject ? reference.targetId : null,
      'building_id': reference.targetKind == ReviewTargetKind.building ? reference.targetId : null,
      'student_life_id': reference.targetKind == ReviewTargetKind.studentLife ? reference.targetId : null,
      'club_id': reference.targetKind == ReviewTargetKind.club ? reference.targetId : null,
    };

    return _client.from('reviews').insert(payload).then((_) {});
  }

  Future<void> toggleHelpful({required String reviewId, required String userId, required bool removeLike}) async {
    if (removeLike) {
      await _client.from('review_likes').delete().match({'review_id': reviewId, 'user_id': userId});
    } else {
      await _client.from('review_likes').insert({'review_id': reviewId, 'user_id': userId});
    }
  }

  Future<void> submitReport({required String reviewId, required String userId, required String reason}) async {
    await _client.from('review_reports').insert({
      'review_id': reviewId,
      'user_id': userId,
      'reason': reason,
    });
  }

  Future<String> uploadImage(String filePath, dynamic fileBytes) async {
    // Requires dart:io File bytes
    await _client.storage.from('review_images').uploadBinary(filePath, fileBytes);
    return _client.storage.from('review_images').getPublicUrl(filePath);
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
}
