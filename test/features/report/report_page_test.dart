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

    expect(find.text('이번 달 기록을 숫자로 정리했어요'), findsOneWidget);
    expect(find.text('예산 상태'), findsWidgets);
    expect(find.text('지출 달력'), findsOneWidget);
    expect(find.text('이번 달 패턴'), findsOneWidget);
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
      find.text('카테고리 필터'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, '커피'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '커피'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('최근 거래'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('커피'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('교통'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('식료품'),
      ),
      findsNothing,
    );
  });

  testWidgets('filters recent transactions by search query', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Search transactions'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recent transactions'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('Coffee'),
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('Transit'),
      ),
      findsNothing,
    );
  });

  testWidgets('shows an empty state when search finds no transactions', (
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
      find.text('Search transactions'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz-not-found');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('No transactions match your search'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No transactions match your search'), findsOneWidget);
  });

  testWidgets('filters recent transactions by tapping a calendar day', (
    tester,
  ) async {
    final month = DateTime(2026, 3, 1);
    final dependencies = buildFakeDependenciesWithSnapshot(
      LedgerSnapshot(
        monthlyBudgetAmount: 400000,
        entries: [
          LedgerEntry(
            id: 'day-15-a',
            type: LedgerEntryType.expense,
            category: LedgerCategory.coffee,
            amount: 4500,
            note: 'Coffee',
            occurredOn: DateTime(2026, 3, 15, 9),
          ),
          LedgerEntry(
            id: 'day-16-a',
            type: LedgerEntryType.expense,
            category: LedgerCategory.transport,
            amount: 12000,
            note: 'Bus',
            occurredOn: DateTime(2026, 3, 16, 9),
          ),
        ],
      ),
    );
    dependencies.ledgerMonthController.setMonth(month);

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Spending calendar'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final dayCell = find.byKey(const ValueKey('calendar-day-2026-3-15'));
    final dayInkWell = tester.widget<InkWell>(
      find.descendant(of: dayCell, matching: find.byType(InkWell)),
    );
    dayInkWell.onTap!.call();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recent transactions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Showing only the transactions on Mar 15.'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('Coffee'),
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.text('Transport'),
      ),
      findsNothing,
    );
  });

  testWidgets('opens a selected-day bottom sheet from the calendar', (
    tester,
  ) async {
    final month = DateTime(2026, 3, 1);
    final dependencies = buildFakeDependenciesWithSnapshot(
      LedgerSnapshot(
        monthlyBudgetAmount: 400000,
        entries: [
          LedgerEntry(
            id: 'day-18-a',
            type: LedgerEntryType.expense,
            category: LedgerCategory.groceries,
            amount: 12500,
            note: 'Market',
            occurredOn: DateTime(2026, 3, 18, 18),
          ),
        ],
      ),
    );
    dependencies.ledgerMonthController.setMonth(month);

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Spending calendar'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final dayCell = find.byKey(const ValueKey('calendar-day-2026-3-18'));
    final dayInkWell = tester.widget<InkWell>(
      find.descendant(of: dayCell, matching: find.byType(InkWell)),
    );
    dayInkWell.onTap!.call();
    await tester.pumpAndSettle();

    expect(find.text('Mar 18'), findsAtLeastNWidgets(1));
    expect(find.text('Daily spend'), findsOneWidget);
    expect(find.text('KRW 12,500'), findsAtLeastNWidgets(1));
    expect(find.text('Entries'), findsOneWidget);
    expect(find.text('1'), findsAtLeastNWidgets(1));
    expect(find.text('Top category'), findsOneWidget);
    expect(find.text('Groceries'), findsAtLeastNWidgets(1));
    expect(
      find.descendant(
        of: find.byType(AppTransactionTile),
        matching: find.byKey(const ValueKey('selected-day-day-18-a')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows monthly calendar pattern stats', (tester) async {
    final month = DateTime(2026, 3, 1);
    final dependencies = buildFakeDependenciesWithSnapshot(
      LedgerSnapshot(
        monthlyBudgetAmount: 400000,
        entries: [
          LedgerEntry(
            id: 'day-4',
            type: LedgerEntryType.expense,
            category: LedgerCategory.coffee,
            amount: 4500,
            note: 'Coffee',
            occurredOn: DateTime(2026, 3, 4, 9),
          ),
          LedgerEntry(
            id: 'day-18',
            type: LedgerEntryType.expense,
            category: LedgerCategory.groceries,
            amount: 12500,
            note: 'Market',
            occurredOn: DateTime(2026, 3, 18, 18),
          ),
        ],
      ),
    );
    dependencies.ledgerMonthController.setMonth(month);

    await tester.pumpWidget(
      _LocalizedTestApp(
        locale: const Locale('en'),
        home: ReportPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('This month patterns'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Highest spend day'), findsOneWidget);
    expect(find.text('USD 125.00'), findsNothing);
    expect(find.text('KRW 12,500'), findsAtLeastNWidgets(1));
    expect(find.text('Spend days'), findsOneWidget);
    expect(find.text('No-spend days'), findsOneWidget);
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
            occurredOn: now.subtract(const Duration(minutes: 9)),
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
              occurredOn: now.subtract(Duration(minutes: index)),
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
      find.text('카테고리 필터'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, '쇼핑'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '쇼핑'));
    await tester.pumpAndSettle();

    expect(find.text('선택한 카테고리의 최근 거래가 없습니다'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '전체'), findsOneWidget);

    final resetButton = find.widgetWithText(OutlinedButton, '전체');
    final resetControl = tester.widget<OutlinedButton>(resetButton);
    resetControl.onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.text('선택한 카테고리의 최근 거래가 없습니다'), findsNothing);
    expect(find.byType(AppTransactionTile), findsAtLeastNWidgets(1));
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
