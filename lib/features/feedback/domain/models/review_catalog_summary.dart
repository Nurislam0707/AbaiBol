import 'review_catalog_item.dart';

class ReviewCatalogSummary {
  const ReviewCatalogSummary({
    required this.item,
    required this.averageRating,
    required this.totalReviews,
    this.trendingScore = 0.0,
  });

  final ReviewCatalogItem item;
  final double averageRating;
  final int totalReviews;
  final double trendingScore;
}
