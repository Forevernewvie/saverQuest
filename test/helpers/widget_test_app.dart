import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';

/// Wraps widget-under-test with localized Material scaffolding used across widget tests.
class WidgetTestApp extends StatelessWidget {
  const WidgetTestApp({
    super.key,
    required this.home,
    this.locale,
    this.routes = const {},
    this.mediaQueryData,
  });

  final Widget home;
  final Locale? locale;
  final Map<String, WidgetBuilder> routes;
  final MediaQueryData? mediaQueryData;

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
      home: mediaQueryData == null
          ? home
          : MediaQuery(data: mediaQueryData!, child: home),
      routes: routes,
    );
  }
}
