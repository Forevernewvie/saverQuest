import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
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
    );
    final report = LedgerReportSummary(
      monthlyBudgetAmount: 400000,
      monthlyExpenseAmount: 160000,
      monthlyIncomeAmount: 2400000,
      balanceAmount: 2240000,
      recentEntries: const [],
      expenseTotals: const [
        LedgerCategoryTotal(
          category: LedgerCategory.groceries,
          amount: 90000,
          entryCount: 2,
        ),
      ],
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
    );

    final viewData = factory.buildReportViewData(l10n: l10n, summary: summary);

    expect(viewData.monthlyExpenseValue, l10n.formatCurrency(180000));
    expect(viewData.categoryTotals.single.body, '3 expense entries');
    expect(
      viewData.recentEntries.single.trailing,
      l10n.formatSignedCurrency(type: LedgerEntryType.income, amount: 2100000),
    );
    expect(viewData.budgetStatusBody, contains(l10n.formatCurrency(120000)));
  });
}
