import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class LanguageStorageService {
  const LanguageStorageService();

  static const _languageKey = 'app_language';

  Future<AppLanguage> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLanguageX.fromCode(preferences.getString(_languageKey));
  }

  Future<void> saveLanguage(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language.code);
  }
}
