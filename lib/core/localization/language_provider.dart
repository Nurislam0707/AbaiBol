import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_language.dart';
import 'language_storage_service.dart';

final languageStorageServiceProvider = Provider<LanguageStorageService>(
  (ref) => const LanguageStorageService(),
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.kk;

  Future<void> load() async {
    state = await ref.read(languageStorageServiceProvider).loadLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await ref.read(languageStorageServiceProvider).saveLanguage(language);
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);
