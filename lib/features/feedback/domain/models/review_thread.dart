import 'review_catalog_item.dart';
import 'review_entry.dart';

class ReviewThread {
  const ReviewThread({
    required this.item,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.canSubmitReview,
    this.myReview,
  });

  final ReviewCatalogItem item;
  final List<ReviewEntry> reviews;
  final double averageRating;
  final int totalReviews;
  final bool canSubmitReview;
  final ReviewEntry? myReview;
}
