import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ledger/ledger_models.dart';
import '../../../widgets/common/app_blocks.dart';

/// Renders the monthly budget overview section for the home dashboard.
class HomeBudgetOverviewSection extends StatelessWidget {
  /// Creates the budget overview section with home content and localization.
  const HomeBudgetOverviewSection({
    super.key,
    required this.monthlyBudgetAmount,
    required this.monthlyExpenseAmount,
    required this.remainingBudgetAmount,
    required this.currency,
    required this.l10n,
  });

  final int monthlyBudgetAmount;
  final int monthlyExpenseAmount;
  final int remainingBudgetAmount;
  final LedgerCurrency currency;
  final AppLocalizations l10n;

  /// Builds the budget overview card with progress and summary figures.
  @override
  Widget build(BuildContext context) {
    return AppBudgetOverviewCard(
      title: l10n.homeBudgetOverviewTitle,
      body: l10n.homeBudgetOverviewBody,
      progressValue: monthlyBudgetAmount <= 0
          ? 0
          : monthlyExpenseAmount / monthlyBudgetAmount,
      remainingLabel: l10n.homeStatRemainingLabel,
      remainingValue: l10n.homeStatRemainingValue(
        remainingBudgetAmount,
        currency: currency,
      ),
      spentLabel: l10n.homeBudgetSpentLabel,
      spentValue: l10n.formatCurrency(monthlyExpenseAmount, currency: currency),
      limitLabel: l10n.homeBudgetLimitLabel,
      limitValue: l10n.formatCurrency(monthlyBudgetAmount, currency: currency),
    );
  }
}
