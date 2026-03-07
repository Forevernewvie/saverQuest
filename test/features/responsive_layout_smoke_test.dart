import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_saverquest_mvp/features/report/report_page.dart';
import 'package:flutter_saverquest_mvp/features/settings/settings_page.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('home layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _ResponsiveLocalizedTestApp(
        locale: const Locale('en'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Savings'), findsOneWidget);
    expect(find.text('Estimate your savings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _ResponsiveLocalizedTestApp(
        locale: const Locale('en'),
        home: SettingsPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy & app settings'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tool layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _ResponsiveLocalizedTestApp(
        locale: const Locale('en'),
        home: ToolPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Savings Calculator'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('report layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _ResponsiveLocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weekly Savings Report'), findsAtLeastNWidgets(1));
    expect(
      find.text('See your weekly savings trend at a glance'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _ResponsiveLocalizedTestApp extends StatelessWidget {
  const _ResponsiveLocalizedTestApp({required this.home, required this.locale});

  static const Size _narrowViewport = Size(320, 780);
  static const double _largeTextScale = 1.5;

  final Widget home;
  final Locale locale;

  /// Builds a localized test harness that simulates narrow large-text devices.
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
      home: MediaQuery(
        data: const MediaQueryData(
          size: _narrowViewport,
          textScaler: TextScaler.linear(_largeTextScale),
        ),
        child: home,
      ),
    );
  }
}
