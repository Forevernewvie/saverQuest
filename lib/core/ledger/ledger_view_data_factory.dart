import '../localization/app_localizations.dart';
import 'ledger_models.dart';
import 'ledger_presentation_service.dart';
import 'ledger_view_data.dart';

/// Builds screen-specific immutable view data from ledger domain summaries.
class LedgerViewDataFactory {
  /// Creates a stateless factory for ledger screen presentation models.
  const LedgerViewDataFactory({LedgerPresentationService? presentationService})
    : _presentationService =
          presentationService ?? const LedgerPresentationService();

  final LedgerPresentationService _presentationService;

  /// Builds the localized home-screen view model from dashboard and report data.
  HomeDashboardViewData buildHomeViewData({
    required AppLocalizations l10n,
    required LedgerDashboardSummary dashboard,
    required LedgerReportSummary report,
  }) {
    final topCategoryTotal = report.expenseTotals.isNotEmpty
        ? report.expenseTotals.first.amount
        : 0;

    return HomeDashboardViewData(
      monthlyExpenseValue: l10n.homeStatSavingsValue(
        dashboard.monthlyExpenseAmount,
        currency: dashboard.currency,
      ),
      remainingBudgetValue: l10n.homeStatRemainingValue(
        dashboard.remainingBudgetAmount,
        currency: dashboard.currency,
      ),
      monthlyIncomeValue: l10n.homeStatSavingsValue(
        dashboard.monthlyIncomeAmount,
        currency: dashboard.currency,
      ),
      topCategoryValue: dashboard.topExpenseCategory == null
          ? l10n.noData
          : l10n.formatCurrency(topCategoryTotal, currency: dashboard.currency),
      topCategoryBody: l10n.homeTopCategoryBody(
        category: dashboard.topExpenseCategory,
        amount: topCategoryTotal,
        currency: dashboard.currency,
      ),
      recentEntries: dashboard.recentEntries
          .map(
            (entry) => _buildTransactionRowViewData(
              l10n: l10n,
              entry: entry,
              currency: dashboard.currency,
            ),
          )
          .toList(),
    );
  }

  /// Builds the localized report-screen view model from report data.
  LedgerReportViewData buildReportViewData({
    required AppLocalizations l10n,
    required LedgerReportSummary summary,
    required DateTime selectedMonth,
    DateTime? selectedDate,
    LedgerCategory? selectedCategory,
  }) {
    final remainingBudgetAmount =
        summary.monthlyBudgetAmount - summary.monthlyExpenseAmount;
    final maxExpenseAmount = summary.expenseTotals.isEmpty
        ? 0
        : summary.expenseTotals.first.amount;
    final filteredEntries = selectedCategory == null
        ? summary.recentEntries
        : summary.recentEntries
              .where((entry) => entry.category == selectedCategory)
              .toList();
    final selectedDay = selectedDate == null
        ? null
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final dayFilteredEntries = selectedDay == null
        ? filteredEntries
        : summary.currentMonthEntries
              .where(
                (entry) =>
                    entry.occurredOn.year == selectedDay.year &&
                    entry.occurredOn.month == selectedDay.month &&
                    entry.occurredOn.day == selectedDay.day,
              )
              .toList();

    return LedgerReportViewData(
      monthlyExpenseValue: l10n.formatCurrency(
        summary.monthlyExpenseAmount,
        currency: summary.currency,
      ),
      monthlyIncomeValue: l10n.formatCurrency(
        summary.monthlyIncomeAmount,
        currency: summary.currency,
      ),
      balanceValue: l10n.formatCurrency(
        summary.balanceAmount,
        currency: summary.currency,
      ),
      budgetStatusBody: l10n.reportBudgetStatusBody(
        remainingBudgetAmount: remainingBudgetAmount,
        balanceAmount: summary.balanceAmount,
        currency: summary.currency,
      ),
      categoryFilters: [
        ReportCategoryFilterViewData(
          label: l10n.reportFilterAllLabel,
          category: null,
          isSelected: selectedCategory == null,
        ),
        ...summary.expenseTotals.map(
          (total) => ReportCategoryFilterViewData(
            label: l10n.ledgerCategoryLabel(total.category),
            category: total.category,
            isSelected: selectedCategory == total.category,
          ),
        ),
      ],
      chartRows: summary.expenseTotals
          .map(
            (total) => ReportCategoryChartRowViewData(
              icon: _presentationService.iconForCategory(total.category),
              label: l10n.ledgerCategoryLabel(total.category),
              amountLabel: l10n.formatCurrency(
                total.amount,
                currency: summary.currency,
              ),
              progress: maxExpenseAmount <= 0
                  ? 0
                  : total.amount / maxExpenseAmount,
              isHighlighted:
                  selectedCategory == null ||
                  selectedCategory == total.category,
            ),
          )
          .toList(),
      categoryTotals: summary.expenseTotals
          .map(
            (total) => ReportCategoryCardViewData(
              icon: _presentationService.iconForCategory(total.category),
              title: l10n.ledgerCategoryLabel(total.category),
              body: l10n.reportEntryCountLabel(total.entryCount),
              trailing: l10n.formatCurrency(
                total.amount,
                currency: summary.currency,
              ),
            ),
          )
          .toList(),
      calendarDays: _buildCalendarDays(
        l10n: l10n,
        summary: summary,
        selectedMonth: selectedMonth,
        selectedDay: selectedDay,
      ),
      selectedDaySubtitle: selectedDay == null
          ? null
          : l10n.reportSelectedDaySubtitle(selectedDay),
      recentEntries: dayFilteredEntries
          .map(
            (entry) => _buildTransactionRowViewData(
              l10n: l10n,
              entry: entry,
              currency: summary.currency,
            ),
          )
          .toList(),
    );
  }

  List<ReportCalendarDayViewData> _buildCalendarDays({
    required AppLocalizations l10n,
    required LedgerReportSummary summary,
    required DateTime selectedMonth,
    required DateTime? selectedDay,
  }) {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final leadingEmptyCells = firstDay.weekday % 7;
    final trailingEmptyCells =
        (7 - ((leadingEmptyCells + lastDay.day) % 7)) % 7;
    final today = DateTime.now();
    final totalsByDay = {
      for (final total in summary.dailySpendTotals)
        DateTime(total.date.year, total.date.month, total.date.day): total,
    };
    final maxDailyAmount = summary.dailySpendTotals.isEmpty
        ? 0
        : summary.dailySpendTotals
              .map((total) => total.amount)
              .reduce((left, right) => left > right ? left : right);

    ReportCalendarDayViewData buildDay(
      DateTime date, {
      required bool isCurrentMonth,
    }) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final total = totalsByDay[normalizedDate];
      final amount = total?.amount ?? 0;
      return ReportCalendarDayViewData(
        date: normalizedDate,
        dayLabel: '${normalizedDate.day}',
        totalLabel: amount <= 0
            ? null
            : l10n.formatCurrency(amount, currency: summary.currency),
        hasSpend: amount > 0,
        isCurrentMonth: isCurrentMonth,
        isToday:
            today.year == normalizedDate.year &&
            today.month == normalizedDate.month &&
            today.day == normalizedDate.day,
        isSelected:
            selectedDay != null &&
            selectedDay.year == normalizedDate.year &&
            selectedDay.month == normalizedDate.month &&
            selectedDay.day == normalizedDate.day,
        intensity: maxDailyAmount <= 0 ? 0 : amount / maxDailyAmount,
      );
    }

    final previousMonthLastDay = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      0,
    ).day;

    return [
      for (var index = leadingEmptyCells - 1; index >= 0; index--)
        buildDay(
          DateTime(
            selectedMonth.year,
            selectedMonth.month - 1,
            previousMonthLastDay - index,
          ),
          isCurrentMonth: false,
        ),
      for (var day = 1; day <= lastDay.day; day++)
        buildDay(
          DateTime(selectedMonth.year, selectedMonth.month, day),
          isCurrentMonth: true,
        ),
      for (var day = 1; day <= trailingEmptyCells; day++)
        buildDay(
          DateTime(selectedMonth.year, selectedMonth.month + 1, day),
          isCurrentMonth: false,
        ),
    ];
  }

  /// Builds the localized insights-screen view model from insight data.
  LedgerInsightsViewData buildInsightsViewData({
    required AppLocalizations l10n,
    required LedgerInsightSummary summary,
  }) {
    final hasEntries =
        summary.recentExpenseCount > 0 ||
        summary.monthlyIncomeAmount > 0 ||
        summary.monthlyExpenseAmount > 0;

    return LedgerInsightsViewData(
      hasEntries: hasEntries,
      primaryBody: l10n.insightsPrimaryBodyFor(
        topExpenseCategory: summary.topExpenseCategory,
        monthlyExpenseAmount: summary.monthlyExpenseAmount,
        currency: summary.currency,
      ),
      secondaryBody: l10n.insightsSecondaryBodyFor(
        secondaryExpenseCategory: summary.secondaryExpenseCategory,
        recentExpenseCount: summary.recentExpenseCount,
      ),
      budgetBody: l10n.insightsBudgetBodyFor(
        summary.remainingBudgetAmount,
        currency: summary.currency,
      ),
    );
  }

  /// Builds the localized transaction-row view model used across screens.
  LedgerTransactionRowViewData buildTransactionRow({
    required AppLocalizations l10n,
    required LedgerEntry entry,
    LedgerCurrency currency = LedgerCurrency.krw,
  }) {
    return _buildTransactionRowViewData(
      l10n: l10n,
      entry: entry,
      currency: currency,
    );
  }

  /// Creates the shared transaction row representation for list surfaces.
  LedgerTransactionRowViewData _buildTransactionRowViewData({
    required AppLocalizations l10n,
    required LedgerEntry entry,
    required LedgerCurrency currency,
  }) {
    return LedgerTransactionRowViewData(
      icon: _presentationService.iconForCategory(entry.category),
      title: l10n.ledgerCategoryLabel(entry.category),
      subtitle: _presentationService.subtitleForEntry(l10n: l10n, entry: entry),
      trailing: l10n.formatSignedCurrency(
        type: entry.type,
        amount: entry.amount,
        currency: currency,
      ),
    );
  }
}
