import '../../domain/models/user_profile.dart';
import '../../domain/models/my_review_item.dart';
import '../services/profile_remote_service.dart';
import '../../../auth/data/services/anonymous_auth_service.dart';

class ProfileRepository {
  const ProfileRepository({
    required ProfileRemoteService remoteService,
    required AnonymousAuthService authService,
  }) : _remoteService = remoteService,
       _authService = authService;

  final ProfileRemoteService _remoteService;
  final AnonymousAuthService _authService;

  Future<UserProfile> ensureProfile() async {
    final user = await _authService.ensureSignedIn();
    final existing = await _remoteService.fetchProfile(user.id);
    if (existing != null) {
      return existing;
    }

    final defaultName = _buildDefaultName(user.id);
    await _remoteService.createProfile(
      userId: user.id,
      displayName: defaultName,
    );
    final created = await _remoteService.fetchProfile(user.id);
    if (created == null) {
      throw StateError('Profile was not created.');
    }
    return created;
  }

  Future<UserProfile> fetchProfile() async {
    final user = await _authService.ensureSignedIn();
    final profile = await _remoteService.fetchProfile(user.id);
    if (profile == null) {
      return ensureProfile();
    }
    return profile;
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = await _authService.ensureSignedIn();
    await _remoteService.updateDisplayName(
      userId: user.id,
      displayName: displayName.trim(),
    );
  }

  Future<int> fetchMyReviewCount() async {
    final user = await _authService.ensureSignedIn();
    return _remoteService.fetchReviewCount(user.id);
  }

  Future<List<MyReviewItem>> fetchMyReviews() async {
    final user = await _authService.ensureSignedIn();
    return _remoteService.fetchMyReviews(user.id);
  }

  Future<void> deleteReview(String reviewId) async {
    await _remoteService.deleteReview(reviewId);
  }

  String _buildDefaultName(String userId) {
    final suffix = userId.replaceAll('-', '').substring(0, 4).toUpperCase();
    return 'Student$suffix';
  }
}
