import 'package:flutter/material.dart';

import 'ledger_models.dart';

/// Carries the presentation data for a single transaction row.
class LedgerTransactionRowViewData {
  /// Creates an immutable transaction-row view model.
  const LedgerTransactionRowViewData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
}

/// Carries the presentation data for the home dashboard.
class HomeDashboardViewData {
  /// Creates an immutable home dashboard view model.
  const HomeDashboardViewData({
    required this.monthlyExpenseValue,
    required this.remainingBudgetValue,
    required this.monthlyIncomeValue,
    required this.topCategoryValue,
    required this.topCategoryBody,
    required this.recentEntries,
  });

  final String monthlyExpenseValue;
  final String remainingBudgetValue;
  final String monthlyIncomeValue;
  final String topCategoryValue;
  final String topCategoryBody;
  final List<LedgerTransactionRowViewData> recentEntries;
}

/// Carries the presentation data for one category total card in reports.
class ReportCategoryCardViewData {
  /// Creates an immutable report category-card view model.
  const ReportCategoryCardViewData({
    required this.icon,
    required this.title,
    required this.body,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String body;
  final String trailing;
}

/// Carries the presentation data for one report filter option.
class ReportCategoryFilterViewData {
  /// Creates an immutable report filter-chip view model.
  const ReportCategoryFilterViewData({
    required this.label,
    required this.category,
    required this.isSelected,
  });

  final String label;
  final LedgerCategory? category;
  final bool isSelected;
}

/// Carries the presentation data for one chart row in the report screen.
class ReportCategoryChartRowViewData {
  /// Creates an immutable category chart-row view model.
  const ReportCategoryChartRowViewData({
    required this.icon,
    required this.label,
    required this.amountLabel,
    required this.progress,
    required this.isHighlighted,
  });

  final IconData icon;
  final String label;
  final String amountLabel;
  final double progress;
  final bool isHighlighted;
}

/// Carries the presentation data for the monthly report screen.
class LedgerReportViewData {
  /// Creates an immutable report-screen view model.
  const LedgerReportViewData({
    required this.monthlyExpenseValue,
    required this.monthlyIncomeValue,
    required this.balanceValue,
    required this.budgetStatusBody,
    required this.categoryFilters,
    required this.chartRows,
    required this.categoryTotals,
    required this.recentEntries,
  });

  final String monthlyExpenseValue;
  final String monthlyIncomeValue;
  final String balanceValue;
  final String budgetStatusBody;
  final List<ReportCategoryFilterViewData> categoryFilters;
  final List<ReportCategoryChartRowViewData> chartRows;
  final List<ReportCategoryCardViewData> categoryTotals;
  final List<LedgerTransactionRowViewData> recentEntries;
}

/// Carries the presentation data for the insights screen.
class LedgerInsightsViewData {
  /// Creates an immutable insights-screen view model.
  const LedgerInsightsViewData({
    required this.hasEntries,
    required this.primaryBody,
    required this.secondaryBody,
    required this.budgetBody,
  });

  final bool hasEntries;
  final String primaryBody;
  final String secondaryBody;
  final String budgetBody;
}
