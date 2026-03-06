import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_locale_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryLocaleStorage implements LocaleStorage {
  String? localeCode;

  @override
  Future<String?> loadLocaleCode() async => localeCode;

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    this.localeCode = localeCode;
  }
}

void main() {
  test('initializes from stored locale code', () async {
    final storage = _MemoryLocaleStorage()..localeCode = 'ko';
    final controller = AppLocaleController(storage: storage);

    await controller.initialize();

    expect(controller.locale, const Locale('ko'));
  });

  test('persists locale changes', () async {
    final storage = _MemoryLocaleStorage();
    final controller = AppLocaleController(storage: storage);

    await controller.setLocale(const Locale('en'));

    expect(controller.locale, const Locale('en'));
    expect(storage.localeCode, 'en');
  });
}
