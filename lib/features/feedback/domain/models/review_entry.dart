import 'review_target_kind.dart';

class ReviewEntry {
  const ReviewEntry({
    required this.id,
    required this.userId,
    required this.rating,
    required this.text,
    required this.createdAt,
    required this.targetKind,
    required this.targetId,
    this.imageUrl,
    this.helpfulCount = 0,
    this.isLikedByMe = false,
  });

  final String id;
  final String userId;
  final int rating;
  final String text;
  final DateTime createdAt;
  final ReviewTargetKind targetKind;
  final String targetId;
  final String? imageUrl;
  final int helpfulCount;
  final bool isLikedByMe;
}
