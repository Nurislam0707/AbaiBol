import 'review_target_kind.dart';

class ReviewCatalogItem {
  const ReviewCatalogItem({
    required this.id,
    required this.name,
    required this.targetKind,
    this.department,
    this.imageUrl,
  });

  final String id;
  final String name;
  final ReviewTargetKind targetKind;
  final String? department;
  final String? imageUrl;

  String get subtitle {
    if (department?.trim().isNotEmpty == true) {
      return department!;
    }

    return switch (targetKind) {
      ReviewTargetKind.teacher => 'No department specified',
      ReviewTargetKind.subject => 'Course information',
      ReviewTargetKind.building => 'Building facilities',
      ReviewTargetKind.studentLife => 'Student life review',
      ReviewTargetKind.club => 'Interest club',
    };
  }
}
