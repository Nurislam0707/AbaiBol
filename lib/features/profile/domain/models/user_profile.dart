class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
}
