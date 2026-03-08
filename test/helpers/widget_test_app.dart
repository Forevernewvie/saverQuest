import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';

/// Wraps widget-under-test with localized Material scaffolding used across widget tests.
class WidgetTestApp extends StatelessWidget {
  const WidgetTestApp({super.key, required this.home, this.locale});

  final Widget home;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }
}
