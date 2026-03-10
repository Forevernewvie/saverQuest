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
      ),
      remainingBudgetValue: l10n.homeStatRemainingValue(
        dashboard.remainingBudgetAmount,
      ),
      monthlyIncomeValue: l10n.homeStatSavingsValue(
        dashboard.monthlyIncomeAmount,
      ),
      topCategoryValue: dashboard.topExpenseCategory == null
          ? l10n.noData
          : l10n.formatCurrency(topCategoryTotal),
      topCategoryBody: l10n.homeTopCategoryBody(
        category: dashboard.topExpenseCategory,
        amount: topCategoryTotal,
      ),
      recentEntries: dashboard.recentEntries
          .map(
            (entry) => _buildTransactionRowViewData(l10n: l10n, entry: entry),
          )
          .toList(),
    );
  }

  /// Builds the localized report-screen view model from report data.
  LedgerReportViewData buildReportViewData({
    required AppLocalizations l10n,
    required LedgerReportSummary summary,
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

    return LedgerReportViewData(
      monthlyExpenseValue: l10n.formatCurrency(summary.monthlyExpenseAmount),
      monthlyIncomeValue: l10n.formatCurrency(summary.monthlyIncomeAmount),
      balanceValue: l10n.formatCurrency(summary.balanceAmount),
      budgetStatusBody: l10n.reportBudgetStatusBody(
        remainingBudgetAmount: remainingBudgetAmount,
        balanceAmount: summary.balanceAmount,
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
              amountLabel: l10n.formatCurrency(total.amount),
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
              trailing: l10n.formatCurrency(total.amount),
            ),
          )
          .toList(),
      recentEntries: filteredEntries
          .map(
            (entry) => _buildTransactionRowViewData(l10n: l10n, entry: entry),
          )
          .toList(),
    );
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
      ),
      secondaryBody: l10n.insightsSecondaryBodyFor(
        secondaryExpenseCategory: summary.secondaryExpenseCategory,
        recentExpenseCount: summary.recentExpenseCount,
      ),
      budgetBody: l10n.insightsBudgetBodyFor(summary.remainingBudgetAmount),
    );
  }

  /// Builds the localized transaction-row view model used across screens.
  LedgerTransactionRowViewData buildTransactionRow({
    required AppLocalizations l10n,
    required LedgerEntry entry,
  }) {
    return _buildTransactionRowViewData(l10n: l10n, entry: entry);
  }

  /// Creates the shared transaction row representation for list surfaces.
  LedgerTransactionRowViewData _buildTransactionRowViewData({
    required AppLocalizations l10n,
    required LedgerEntry entry,
  }) {
    return LedgerTransactionRowViewData(
      icon: _presentationService.iconForCategory(entry.category),
      title: l10n.ledgerCategoryLabel(entry.category),
      subtitle: _presentationService.subtitleForEntry(l10n: l10n, entry: entry),
      trailing: l10n.formatSignedCurrency(
        type: entry.type,
        amount: entry.amount,
      ),
    );
  }
}
