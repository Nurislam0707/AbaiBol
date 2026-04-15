import 'review_target_kind.dart';

class ReviewReference {
  const ReviewReference({required this.targetKind, required this.targetId});

  final ReviewTargetKind targetKind;
  final String targetId;

  String get providerKey => '${targetKind.value}:$targetId';
}
