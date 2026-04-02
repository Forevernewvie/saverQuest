import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'buildDashboard aggregates monthly expense, income, and top category',
    () {
      const service = LedgerSummaryService();
      final now = DateTime(2026, 3, 10);
      final snapshot = LedgerSnapshot(
        monthlyBudgetAmount: 400000,
        entries: [
          LedgerEntry(
            id: 'income-1',
            type: LedgerEntryType.income,
            category: LedgerCategory.salary,
            amount: 2500000,
            note: 'salary',
            occurredOn: DateTime(2026, 3, 1),
          ),
          LedgerEntry(
            id: 'expense-1',
            type: LedgerEntryType.expense,
            category: LedgerCategory.groceries,
            amount: 50000,
            note: 'groceries',
            occurredOn: DateTime(2026, 3, 2),
          ),
          LedgerEntry(
            id: 'expense-2',
            type: LedgerEntryType.expense,
            category: LedgerCategory.dining,
            amount: 90000,
            note: 'dining',
            occurredOn: DateTime(2026, 3, 3),
          ),
        ],
      );

      final summary = service.buildDashboard(snapshot: snapshot, now: now);

      expect(summary.monthlyExpenseAmount, 140000);
      expect(summary.monthlyIncomeAmount, 2500000);
      expect(summary.remainingBudgetAmount, 260000);
      expect(summary.topExpenseCategory, LedgerCategory.dining);
      expect(summary.recentEntries.length, 3);
    },
  );

  test('buildReport aggregates daily spend totals for calendar rendering', () {
    const service = LedgerSummaryService();
    final now = DateTime(2026, 3, 10);
    final snapshot = LedgerSnapshot(
      monthlyBudgetAmount: 400000,
      entries: [
        LedgerEntry(
          id: 'expense-1',
          type: LedgerEntryType.expense,
          category: LedgerCategory.groceries,
          amount: 50000,
          note: 'groceries',
          occurredOn: DateTime(2026, 3, 2, 9),
        ),
        LedgerEntry(
          id: 'expense-2',
          type: LedgerEntryType.expense,
          category: LedgerCategory.coffee,
          amount: 4500,
          note: 'coffee',
          occurredOn: DateTime(2026, 3, 2, 18),
        ),
        LedgerEntry(
          id: 'expense-3',
          type: LedgerEntryType.expense,
          category: LedgerCategory.transport,
          amount: 18000,
          note: 'transport',
          occurredOn: DateTime(2026, 3, 5),
        ),
      ],
    );

    final summary = service.buildReport(snapshot: snapshot, now: now);

    expect(summary.dailySpendTotals.length, 2);
    expect(summary.dailySpendTotals.first.amount, 54500);
    expect(summary.dailySpendTotals.first.entryCount, 2);
    expect(summary.dailySpendTotals.last.date, DateTime(2026, 3, 5));
  });
}
