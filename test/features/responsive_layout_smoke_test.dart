import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_saverquest_mvp/features/report/report_page.dart';
import 'package:flutter_saverquest_mvp/features/settings/settings_page.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/widget_test_app.dart';

void main() {
  testWidgets('home layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This month'), findsWidgets);
    expect(find.text('Add transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home quick actions remain stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('What to do next'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('What to do next'), findsOneWidget);
    expect(find.text('Entry'), findsWidgets);
    expect(find.text('Report'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
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
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
        home: ToolPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record transaction'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('report layout remains stable on narrow large-text screens', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This month summary'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tool layout remains stable in landscape tablet mode', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _landscapeTabletMediaQuery,
        home: ToolPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1. Add a record'), findsOneWidget);
    expect(find.text('2. Monthly budget'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('report layout remains stable in landscape tablet mode', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _landscapeTabletMediaQuery,
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budget status'), findsWidgets);
    expect(find.text('Spending distribution'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('transaction cards remain stable with long notes and values', (
    tester,
  ) async {
    final dependencies = buildFakeDependenciesWithSnapshot(
      LedgerSnapshot(
        monthlyBudgetAmount: 1250000,
        entries: [
          LedgerEntry(
            id: 'long-1',
            type: LedgerEntryType.expense,
            category: LedgerCategory.shopping,
            amount: 987650,
            note:
                'Bought a very long weekly household essentials bundle for the entire month',
            occurredOn: DateTime.now(),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: _narrowLargeTextMediaQuery,
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recent activity'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Bought a very long weekly h…'), findsOneWidget);
    expect(find.textContaining('bundle for the entire month'), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const MediaQueryData _narrowLargeTextMediaQuery = MediaQueryData(
  size: Size(320, 780),
  textScaler: TextScaler.linear(1.5),
);

const MediaQueryData _landscapeTabletMediaQuery = MediaQueryData(
  size: Size(1024, 768),
  textScaler: TextScaler.linear(1.0),
);
