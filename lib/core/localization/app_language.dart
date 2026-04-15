enum AppLanguage { kk, ru, en }

extension AppLanguageX on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.kk:
        return 'kk';
      case AppLanguage.ru:
        return 'ru';
      case AppLanguage.en:
        return 'en';
    }
  }

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'ru' => AppLanguage.ru,
      'en' => AppLanguage.en,
      _ => AppLanguage.kk,
    };
  }
}
