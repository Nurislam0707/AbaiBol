import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/repositories/profile_repository.dart';
import '../data/services/profile_remote_service.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/my_review_item.dart';

final profileRemoteServiceProvider = Provider<ProfileRemoteService>(
  (ref) => ProfileRemoteService(ref.watch(supabaseClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    remoteService: ref.watch(profileRemoteServiceProvider),
    authService: ref.watch(anonymousAuthServiceProvider),
  ),
);

final currentUserProfileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).fetchProfile(),
);

final myReviewCountProvider = FutureProvider<int>(
  (ref) => ref.watch(profileRepositoryProvider).fetchMyReviewCount(),
);

final myReviewsProvider = FutureProvider<List<MyReviewItem>>(
  (ref) => ref.watch(profileRepositoryProvider).fetchMyReviews(),
);

class ProfileEditState {
  const ProfileEditState({
    this.isSaving = false,
    this.error,
    this.saved = false,
  });

  final bool isSaving;
  final String? error;
  final bool saved;

  ProfileEditState copyWith({
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? saved,
  }) {
    return ProfileEditState(
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
      saved: saved ?? this.saved,
    );
  }
}

class ProfileEditNotifier extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  Future<void> saveDisplayName(String value) async {
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      state = state.copyWith(error: 'Display name is too short.');
      return;
    }

    state = state.copyWith(isSaving: true, saved: false, clearError: true);
    try {
      await ref.read(profileRepositoryProvider).updateDisplayName(trimmed);
      ref.invalidate(currentUserProfileProvider);
      state = state.copyWith(isSaving: false, saved: true, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        error: 'Could not update display name.',
      );
    }
  }

  void reset() {
    state = const ProfileEditState();
  }
}

final profileEditProvider =
    NotifierProvider<ProfileEditNotifier, ProfileEditState>(
      ProfileEditNotifier.new,
    );

final reviewActionProvider =
    NotifierProvider<ReviewActionNotifier, ProfileEditState>(
      ReviewActionNotifier.new,
    );

class ReviewActionNotifier extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  Future<bool> deleteReview(String reviewId) async {
    state = state.copyWith(isSaving: true, saved: false, clearError: true);
    try {
      await ref.read(profileRepositoryProvider).deleteReview(reviewId);
      ref.invalidate(myReviewsProvider);
      ref.invalidate(myReviewCountProvider);
      state = state.copyWith(isSaving: false, saved: true);
      return true;
    } catch (e) {
      final strings = ref.read(appStringsProvider);
      state = state.copyWith(
        isSaving: false,
        error: strings.deletingReviewError,
      );
      return false;
    }
  }

  void reset() => state = const ProfileEditState();
}
