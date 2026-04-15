import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../localization/language_provider.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(anonymousAuthServiceProvider).ensureSignedIn();
  await ref.read(appLanguageProvider.notifier).load();
  await ref.read(profileRepositoryProvider).ensureProfile();
});
