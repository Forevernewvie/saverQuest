import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  testWidgets('renders mission and CTA', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('ko'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 절약 홈'), findsOneWidget);
    expect(find.text('오늘의 미션'), findsOneWidget);
    expect(find.text('지출 10초 기록'), findsOneWidget);
  });

  testWidgets('renders english copy when locale is english', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Savings Home'), findsOneWidget);
    expect(find.text('Today\'s Mission'), findsOneWidget);
    expect(find.text('Log expense in 10 seconds'), findsOneWidget);
  });
}

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({required this.home, this.locale});

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
