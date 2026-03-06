import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocaleStorage {
  Future<String?> loadLocaleCode();

  Future<void> saveLocaleCode(String localeCode);
}

class SharedPreferencesLocaleStorage implements LocaleStorage {
  const SharedPreferencesLocaleStorage();

  static const String _localeCodeKey = 'app_locale_code';

  @override
  Future<String?> loadLocaleCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_localeCodeKey);
  }

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeCodeKey, localeCode);
  }
}

class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    LocaleStorage storage = const SharedPreferencesLocaleStorage(),
  }) : _storage = storage;

  static const Locale korean = Locale('ko');
  static const Locale english = Locale('en');
  static const List<Locale> supportedLocales = [korean, english];

  final LocaleStorage _storage;

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> initialize() async {
    final storedLocaleCode = await _storage.loadLocaleCode();
    _locale = _resolveLocale(storedLocaleCode);
  }

  Future<void> setLocale(Locale locale) async {
    final resolvedLocale = _resolveLocale(locale.languageCode) ?? english;
    if (_locale == resolvedLocale) {
      return;
    }
    _locale = resolvedLocale;
    notifyListeners();
    await _storage.saveLocaleCode(resolvedLocale.languageCode);
  }

  static Locale fallbackFor(Locale? locale) {
    if (locale?.languageCode == korean.languageCode) {
      return korean;
    }
    return english;
  }

  Locale? _resolveLocale(String? localeCode) {
    switch (localeCode) {
      case 'ko':
        return korean;
      case 'en':
        return english;
      default:
        return null;
    }
  }
}
