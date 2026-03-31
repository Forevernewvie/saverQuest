import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/app/routes.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_saverquest_mvp/features/report/report_page.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_saverquest_mvp/widgets/common/app_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  testWidgets('shows monthly report sections from live ledger data', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('ko'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('이번 달 요약'), findsOneWidget);
    expect(find.text('예산 상태'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('지출 비중'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('지출 비중'), findsOneWidget);
    expect(find.text('카테고리 필터'), findsOneWidget);
    expect(find.text('카테고리별 지출'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('최근 거래'), findsOneWidget);
  });

  testWidgets('shows actionable empty state when there are no report entries', (
    tester,
  ) async {
    final dependencies = buildFakeDependenciesWithSnapshot(
      const LedgerSnapshot(entries: [], monthlyBudgetAmount: 300000),
    );

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('ko'),
        home: ReportPage(dependencies: dependencies),
        routes: {AppRoutes.tool: (_) => ToolPage(dependencies: dependencies)},
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('이번 달 기록이 없습니다'), findsWidgets);
    expect(find.text('거래 기록하기'), findsWidgets);
  });

  testWidgets('filters recent transactions by category chip', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('ko'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTransactionTile), findsNWidgets(4));

    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, '커피'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '커피'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTransactionTile), findsOneWidget);
  });

  testWidgets('opens transaction detail sheet from report recent entries', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recent transactions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppTransactionTile).last);
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('offers a clear reset path when a category has no recent rows', (
    tester,
  ) async {
    final now = DateTime.now();
    final dependencies = buildFakeDependenciesWithSnapshot(
      LedgerSnapshot(
        monthlyBudgetAmount: 500000,
        entries: [
          LedgerEntry(
            id: 'older-shopping',
            type: LedgerEntryType.expense,
            category: LedgerCategory.shopping,
            amount: 91000,
            note: 'Older shopping',
            occurredOn: now.subtract(const Duration(days: 9)),
          ),
          for (var index = 0; index < 8; index++)
            LedgerEntry(
              id: 'recent-$index',
              type: LedgerEntryType.expense,
              category: index.isEven
                  ? LedgerCategory.coffee
                  : LedgerCategory.groceries,
              amount: 4000 + index,
              note: 'Recent $index',
              occurredOn: now.subtract(Duration(days: index)),
            ),
        ],
      ),
    );

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('ko'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, '쇼핑'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '쇼핑'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('선택한 카테고리의 최근 거래가 없습니다'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '전체'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '전체'));
    await tester.pumpAndSettle();

    expect(find.byType(AppTransactionTile), findsNWidgets(8));
  });
}

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({
    required this.home,
    this.locale,
    this.routes = const {},
  });

  final Widget home;
  final Locale? locale;
  final Map<String, WidgetBuilder> routes;

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
      routes: routes,
    );
  }
}
