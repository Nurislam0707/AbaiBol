class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
