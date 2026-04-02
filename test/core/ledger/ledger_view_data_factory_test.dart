import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_view_data.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_view_data_factory.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildHomeViewData formats budget and recent entries for display', () {
    const factory = LedgerViewDataFactory();
    final l10n = AppLocalizations(const Locale('ko'));
    final dashboard = LedgerDashboardSummary(
      monthlyBudgetAmount: 400000,
      monthlyExpenseAmount: 160000,
      monthlyIncomeAmount: 2400000,
      remainingBudgetAmount: 240000,
      currentMonthEntries: const [],
      recentEntries: [
        LedgerEntry(
          id: 'expense-1',
          type: LedgerEntryType.expense,
          category: LedgerCategory.coffee,
          amount: 4500,
          note: '아메리카노',
          occurredOn: DateTime(2026, 3, 10),
        ),
      ],
      topExpenseCategory: LedgerCategory.groceries,
      currency: LedgerCurrency.krw,
    );
    final report = LedgerReportSummary(
      monthlyBudgetAmount: 400000,
      monthlyExpenseAmount: 160000,
      monthlyIncomeAmount: 2400000,
      balanceAmount: 2240000,
      currentMonthEntries: const [],
      recentEntries: const [],
      expenseTotals: const [
        LedgerCategoryTotal(
          category: LedgerCategory.groceries,
          amount: 90000,
          entryCount: 2,
        ),
      ],
      dailySpendTotals: const [],
      currency: LedgerCurrency.krw,
    );

    final viewData = factory.buildHomeViewData(
      l10n: l10n,
      dashboard: dashboard,
      report: report,
    );

    expect(viewData.monthlyExpenseValue, l10n.formatCurrency(160000));
    expect(viewData.remainingBudgetValue, l10n.formatCurrency(240000));
    expect(viewData.topCategoryValue, l10n.formatCurrency(90000));
    expect(viewData.recentEntries.single.title, '커피');
  });

  test('buildReportViewData formats category totals and budget body', () {
    const factory = LedgerViewDataFactory();
    final l10n = AppLocalizations(const Locale('en'));
    final summary = LedgerReportSummary(
      monthlyBudgetAmount: 300000,
      monthlyExpenseAmount: 180000,
      monthlyIncomeAmount: 2100000,
      balanceAmount: 1920000,
      currentMonthEntries: const [],
      recentEntries: [
        LedgerEntry(
          id: 'income-1',
          type: LedgerEntryType.income,
          category: LedgerCategory.salary,
          amount: 2100000,
          note: 'salary',
          occurredOn: DateTime(2026, 3, 1),
        ),
      ],
      expenseTotals: const [
        LedgerCategoryTotal(
          category: LedgerCategory.transport,
          amount: 32000,
          entryCount: 3,
        ),
      ],
      dailySpendTotals: const [],
      currency: LedgerCurrency.krw,
    );

    final viewData = factory.buildReportViewData(
      l10n: l10n,
      summary: summary,
      selectedMonth: DateTime(2026, 3, 1),
    );

    expect(viewData.monthlyExpenseValue, l10n.formatCurrency(180000));
    expect(viewData.categoryTotals.single.body, '3 expense entries');
    expect(
      viewData.recentEntries.single.trailing,
      l10n.formatSignedCurrency(type: LedgerEntryType.income, amount: 2100000),
    );
    expect(viewData.budgetStatusBody, contains(l10n.formatCurrency(120000)));
  });

  test(
    'buildReportViewData generates calendar cells and selected-day rows',
    () {
      const factory = LedgerViewDataFactory();
      final l10n = AppLocalizations(const Locale('en'));
      final summary = LedgerReportSummary(
        monthlyBudgetAmount: 90000,
        monthlyExpenseAmount: 32500,
        monthlyIncomeAmount: 0,
        balanceAmount: -32500,
        currentMonthEntries: [
          LedgerEntry(
            id: 'expense-1',
            type: LedgerEntryType.expense,
            category: LedgerCategory.coffee,
            amount: 1250,
            note: 'latte',
            occurredOn: DateTime(2026, 3, 4, 8),
          ),
          LedgerEntry(
            id: 'expense-2',
            type: LedgerEntryType.expense,
            category: LedgerCategory.groceries,
            amount: 31250,
            note: 'market',
            occurredOn: DateTime(2026, 3, 18, 18),
          ),
        ],
        recentEntries: const [],
        expenseTotals: const [],
        dailySpendTotals: [
          LedgerDailySpendTotal(
            date: DateTime(2026, 3, 4),
            amount: 1250,
            entryCount: 1,
          ),
          LedgerDailySpendTotal(
            date: DateTime(2026, 3, 18),
            amount: 31250,
            entryCount: 1,
          ),
        ],
        currency: LedgerCurrency.usd,
      );

      final viewData = factory.buildReportViewData(
        l10n: l10n,
        summary: summary,
        selectedMonth: DateTime(2026, 3, 1),
        selectedDate: DateTime(2026, 3, 18),
      );

      expect(viewData.calendarDays.length, 35);
      expect(
        viewData.calendarDays.whereType<ReportCalendarDayViewData>().any(
          (day) => day.isSelected && day.dayLabel == '18',
        ),
        isTrue,
      );
      expect(viewData.selectedDaySubtitle, contains('Mar 18'));
      expect(viewData.recentEntries.length, 1);
      expect(viewData.recentEntries.single.trailing, '-USD 312.50');
    },
  );
}
