import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/app/routes.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/features/insights/insights_page.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_saverquest_mvp/widgets/common/app_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('shows actionable empty state when no insight data exists', (
    tester,
  ) async {
    final dependencies = buildFakeDependenciesWithSnapshot(
      const LedgerSnapshot(entries: [], monthlyBudgetAmount: 280000),
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: InsightsPage(dependencies: dependencies),
        routes: {AppRoutes.tool: (_) => ToolPage(dependencies: dependencies)},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('아직 기록이 없습니다'), findsOneWidget);
    expect(find.text('거래 기록하기'), findsOneWidget);
  });

  testWidgets('renders insight cards with seeded ledger data', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: InsightsPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('절약 인사이트'), findsWidgets);
    expect(find.byType(AppFeatureCard), findsNWidgets(3));
    expect(find.text('다음으로 볼 항목'), findsOneWidget);
  });

  testWidgets(
    'keeps insights card alignment stable on landscape tablet widths',
    (tester) async {
      final dependencies = buildFakeDependencies();

      await tester.pumpWidget(
        WidgetTestApp(
          locale: const Locale('en'),
          mediaQueryData: const MediaQueryData(size: Size(1024, 768)),
          home: InsightsPage(dependencies: dependencies),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spending insights'), findsWidgets);
      expect(find.byType(AppFeatureCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
}
