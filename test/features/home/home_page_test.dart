import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/app/routes.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('renders budget snapshot and primary CTA', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('이번 달 예산'), findsWidgets);
    expect(find.text('이번 달 예산 현황'), findsOneWidget);
    expect(find.text('거래 기록하기'), findsOneWidget);
    expect(find.text('남은 예산'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('다음으로 할 일'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('다음으로 할 일'), findsOneWidget);
  });

  testWidgets('renders english budget dashboard copy', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This month’s budget'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Monthly budget overview'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Monthly budget overview'), findsOneWidget);
    expect(find.text('Remaining budget'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('What to do next'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('What to do next'), findsOneWidget);
  });

  testWidgets('shows actionable empty state when there are no entries', (
    tester,
  ) async {
    final dependencies = buildFakeDependenciesWithSnapshot(
      const LedgerSnapshot(entries: [], monthlyBudgetAmount: 350000),
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: HomePage(dependencies: dependencies),
        routes: {AppRoutes.tool: (_) => ToolPage(dependencies: dependencies)},
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('아직 기록이 없습니다'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final emptyAction = find.widgetWithText(OutlinedButton, '거래 기록하기');

    expect(find.text('아직 기록이 없습니다'), findsOneWidget);
    expect(emptyAction, findsOneWidget);

    await tester.ensureVisible(emptyAction);
  });

  testWidgets('opens transaction detail sheet from home recent entries', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
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

    await tester.tap(find.text('Coffee').first);
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('keeps home card alignment stable on landscape tablet widths', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        mediaQueryData: const MediaQueryData(size: Size(1024, 768)),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This month’s budget'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('What to do next'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('What to do next'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
