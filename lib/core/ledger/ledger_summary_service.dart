import 'ledger_models.dart';

/// Builds dashboard, report, and insight aggregates from raw ledger entries.
class LedgerSummaryService {
  /// Creates a pure summary service with no mutable state.
  const LedgerSummaryService();

  /// Builds the home dashboard summary for the supplied month.
  LedgerDashboardSummary buildDashboard({
    required LedgerSnapshot snapshot,
    required DateTime now,
  }) {
    final currentMonthEntries = _entriesForMonth(snapshot.entries, now);
    final expenseEntries = currentMonthEntries
        .where((entry) => entry.type == LedgerEntryType.expense)
        .toList();
    final incomeEntries = currentMonthEntries
        .where((entry) => entry.type == LedgerEntryType.income)
        .toList();

    return LedgerDashboardSummary(
      monthlyBudgetAmount: snapshot.monthlyBudgetAmount,
      monthlyExpenseAmount: _sumAmounts(expenseEntries),
      monthlyIncomeAmount: _sumAmounts(incomeEntries),
      remainingBudgetAmount:
          snapshot.monthlyBudgetAmount - _sumAmounts(expenseEntries),
      currentMonthEntries: currentMonthEntries,
      recentEntries: _sortNewestFirst(currentMonthEntries).take(4).toList(),
      topExpenseCategory: _topExpenseCategory(expenseEntries),
      currency: snapshot.currency,
    );
  }

  /// Builds the report summary for the supplied month.
  LedgerReportSummary buildReport({
    required LedgerSnapshot snapshot,
    required DateTime now,
  }) {
    final currentMonthEntries = _entriesForMonth(snapshot.entries, now);
    final expenseEntries = currentMonthEntries
        .where((entry) => entry.type == LedgerEntryType.expense)
        .toList();
    final incomeEntries = currentMonthEntries
        .where((entry) => entry.type == LedgerEntryType.income)
        .toList();
    final expenseTotals = _expenseTotals(expenseEntries);
    final dailySpendTotals = _dailySpendTotals(expenseEntries);

    return LedgerReportSummary(
      monthlyBudgetAmount: snapshot.monthlyBudgetAmount,
      monthlyExpenseAmount: _sumAmounts(expenseEntries),
      monthlyIncomeAmount: _sumAmounts(incomeEntries),
      balanceAmount: _sumAmounts(incomeEntries) - _sumAmounts(expenseEntries),
      currentMonthEntries: currentMonthEntries,
      recentEntries: _sortNewestFirst(currentMonthEntries).take(8).toList(),
      expenseTotals: expenseTotals,
      dailySpendTotals: dailySpendTotals,
      currency: snapshot.currency,
    );
  }

  /// Builds insight inputs that the UI can translate into recommendations.
  LedgerInsightSummary buildInsights({
    required LedgerSnapshot snapshot,
    required DateTime now,
  }) {
    final currentMonthEntries = _entriesForMonth(snapshot.entries, now);
    final expenseEntries = currentMonthEntries
        .where((entry) => entry.type == LedgerEntryType.expense)
        .toList();
    final expenseTotals = _expenseTotals(expenseEntries);

    return LedgerInsightSummary(
      monthlyExpenseAmount: _sumAmounts(expenseEntries),
      monthlyIncomeAmount: _sumAmounts(
        currentMonthEntries.where(
          (entry) => entry.type == LedgerEntryType.income,
        ),
      ),
      remainingBudgetAmount:
          snapshot.monthlyBudgetAmount - _sumAmounts(expenseEntries),
      topExpenseCategory: expenseTotals.isNotEmpty
          ? expenseTotals.first.category
          : null,
      secondaryExpenseCategory: expenseTotals.length > 1
          ? expenseTotals[1].category
          : null,
      recentExpenseCount: expenseEntries.length,
      currency: snapshot.currency,
    );
  }

  /// Returns entries from the same calendar month as the supplied date.
  List<LedgerEntry> _entriesForMonth(List<LedgerEntry> entries, DateTime now) {
    return entries.where((entry) {
      return entry.occurredOn.year == now.year &&
          entry.occurredOn.month == now.month;
    }).toList();
  }

  /// Returns entries sorted from newest to oldest.
  List<LedgerEntry> _sortNewestFirst(List<LedgerEntry> entries) {
    final sortedEntries = [...entries];
    sortedEntries.sort(
      (left, right) => right.occurredOn.compareTo(left.occurredOn),
    );
    return sortedEntries;
  }

  /// Sums the numeric amounts of the supplied entries.
  int _sumAmounts(Iterable<LedgerEntry> entries) {
    return entries.fold(0, (sum, entry) => sum + entry.amount);
  }

  /// Returns the highest-spend category from the supplied expense entries.
  LedgerCategory? _topExpenseCategory(List<LedgerEntry> expenseEntries) {
    final totals = _expenseTotals(expenseEntries);
    return totals.isNotEmpty ? totals.first.category : null;
  }

  /// Aggregates expense entries by category and sorts them descending.
  List<LedgerCategoryTotal> _expenseTotals(List<LedgerEntry> expenseEntries) {
    final Map<LedgerCategory, int> totals = {};
    final Map<LedgerCategory, int> counts = {};

    for (final entry in expenseEntries) {
      totals.update(
        entry.category,
        (amount) => amount + entry.amount,
        ifAbsent: () => entry.amount,
      );
      counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
    }

    final categoryTotals = totals.entries
        .map(
          (entry) => LedgerCategoryTotal(
            category: entry.key,
            amount: entry.value,
            entryCount: counts[entry.key] ?? 0,
          ),
        )
        .toList();

    categoryTotals.sort((left, right) => right.amount.compareTo(left.amount));
    return categoryTotals;
  }

  /// Aggregates expense entries by calendar day for month-view reporting.
  List<LedgerDailySpendTotal> _dailySpendTotals(
    List<LedgerEntry> expenseEntries,
  ) {
    final Map<DateTime, int> totals = {};
    final Map<DateTime, int> counts = {};

    for (final entry in expenseEntries) {
      final dayKey = DateTime(
        entry.occurredOn.year,
        entry.occurredOn.month,
        entry.occurredOn.day,
      );
      totals.update(
        dayKey,
        (amount) => amount + entry.amount,
        ifAbsent: () => entry.amount,
      );
      counts.update(dayKey, (count) => count + 1, ifAbsent: () => 1);
    }

    final dayTotals = totals.entries
        .map(
          (entry) => LedgerDailySpendTotal(
            date: entry.key,
            amount: entry.value,
            entryCount: counts[entry.key] ?? 0,
          ),
        )
        .toList();

    dayTotals.sort((left, right) => left.date.compareTo(right.date));
    return dayTotals;
  }
}
