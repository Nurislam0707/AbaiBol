import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/models/my_review_item.dart';

class ProfileRemoteService {
  const ProfileRemoteService(this._client);

  final SupabaseClient _client;

  Future<UserProfile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return UserProfile(
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String,
      avatarUrl: row['avatar_url'] as String?,
      coverUrl: row['cover_url'] as String?,
      bio: row['bio'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
    );
  }

  Future<void> createProfile({
    required String userId,
    required String displayName,
  }) {
    return _client.from('profiles').insert({
      'user_id': userId,
      'display_name': displayName,
    });
  }

  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
  }) {
    return _client
        .from('profiles')
        .update({
          'display_name': displayName,
          'bio': bio,
          'avatar_url': avatarUrl,
          'cover_url': coverUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  Future<int> fetchReviewCount(String userId) async {
    final response = await _client
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<List<MyReviewItem>> fetchMyReviews(String userId) async {
    final rows = await _client
        .from('reviews')
        .select(
            'id, rating, text, created_at, image_url, helpful_count, '
            'teacher_id, subject_id, building_id, student_life_id, club_id, '
            'teachers(name), subjects(name), buildings(name), student_life_items(name), clubs(name)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).cast<Map<String, dynamic>>().map((row) {
      final teacherName = (row['teachers'] as Map<String, dynamic>?)?['name'] as String?;
      final subjectName = (row['subjects'] as Map<String, dynamic>?)?['name'] as String?;
      final buildingName = (row['buildings'] as Map<String, dynamic>?)?['name'] as String?;
      final studentLifeName = (row['student_life_items'] as Map<String, dynamic>?)?['name'] as String?;
      final clubName = (row['clubs'] as Map<String, dynamic>?)?['name'] as String?;

      final targetName = teacherName ?? subjectName ?? buildingName ?? studentLifeName ?? clubName ?? 'Unknown';

      final targetKind = teacherName != null
          ? 'teacher'
          : subjectName != null
              ? 'subject'
              : buildingName != null
                  ? 'building'
                  : studentLifeName != null
                      ? 'studentLife'
                      : 'club';

      return MyReviewItem(
        id: row['id'] as String,
        rating: row['rating'] as int,
        text: row['text'] as String? ?? '',
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        targetName: targetName,
        targetKind: targetKind,
        helpfulCount: row['helpful_count'] as int? ?? 0,
        imageUrl: row['image_url'] as String?,
      );
    }).toList();
  }
  Future<void> deleteReview(String reviewId) {
    return _client.from('reviews').delete().eq('id', reviewId);
  }
}
