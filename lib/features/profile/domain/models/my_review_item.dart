class MyReviewItem {
  const MyReviewItem({
    required this.id,
    required this.rating,
    required this.text,
    required this.createdAt,
    required this.targetName,
    required this.targetKind,
    this.helpfulCount = 0,
    this.imageUrl,
  });

  final String id;
  final int rating;
  final String text;
  final DateTime createdAt;
  final String targetName;
  final String targetKind;
  final int helpfulCount;
  final String? imageUrl;
}
