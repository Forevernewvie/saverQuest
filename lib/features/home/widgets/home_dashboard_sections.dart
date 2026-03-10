import 'package:flutter/material.dart';

import '../../../core/design/adaptive_layout.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/app_blocks.dart';

/// Carries the display data for one quick action entry on the home dashboard.
class HomeQuickActionItem {
  /// Creates an immutable quick action descriptor.
  const HomeQuickActionItem({
    required this.icon,
    required this.label,
    required this.categoryLabel,
    required this.trailingValue,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String categoryLabel;
  final String trailingValue;
  final String body;
  final VoidCallback onTap;
}

/// Renders the monthly budget overview section for the home dashboard.
class HomeBudgetOverviewSection extends StatelessWidget {
  /// Creates the budget overview section with home content and localization.
  const HomeBudgetOverviewSection({
    super.key,
    required this.monthlyBudgetAmount,
    required this.monthlyExpenseAmount,
    required this.remainingBudgetAmount,
    required this.l10n,
  });

  final int monthlyBudgetAmount;
  final int monthlyExpenseAmount;
  final int remainingBudgetAmount;
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
      remainingValue: l10n.homeStatRemainingValue(remainingBudgetAmount),
      spentLabel: l10n.homeBudgetSpentLabel,
      spentValue: l10n.formatCurrency(monthlyExpenseAmount),
      limitLabel: l10n.homeBudgetLimitLabel,
      limitValue: l10n.formatCurrency(monthlyBudgetAmount),
    );
  }
}

/// Renders the quick-action section for the home dashboard.
class HomeQuickActionsSection extends StatelessWidget {
  /// Creates the quick-action section from a list of immutable action items.
  const HomeQuickActionsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<HomeQuickActionItem> actions;

  /// Builds a single-column mobile stack or a two-column wide-screen action grid.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoPane = AdaptiveLayout.useTwoPaneLayout(
          context,
          constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(title: title, subtitle: subtitle),
            if (!useTwoPane)
              for (var index = 0; index < actions.length; index++) ...[
                AppQuickActionCard(
                  icon: actions[index].icon,
                  label: actions[index].label,
                  categoryLabel: actions[index].categoryLabel,
                  trailingValue: actions[index].trailingValue,
                  body: actions[index].body,
                  onTap: actions[index].onTap,
                ),
                if (index < actions.length - 1)
                  const SizedBox(height: AppSpacing.s),
              ]
            else
              ..._buildGridRows(),
          ],
        );
      },
    );
  }

  /// Groups action cards into responsive two-column rows for wider screens.
  List<Widget> _buildGridRows() {
    final rows = <Widget>[];

    for (var index = 0; index < actions.length; index += 2) {
      final rowActions = actions.skip(index).take(2).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: index + 2 < actions.length ? AppSpacing.s : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (
                var itemIndex = 0;
                itemIndex < rowActions.length;
                itemIndex++
              ) ...[
                Expanded(
                  child: AppQuickActionCard(
                    icon: rowActions[itemIndex].icon,
                    label: rowActions[itemIndex].label,
                    categoryLabel: rowActions[itemIndex].categoryLabel,
                    trailingValue: rowActions[itemIndex].trailingValue,
                    body: rowActions[itemIndex].body,
                    onTap: rowActions[itemIndex].onTap,
                  ),
                ),
                if (itemIndex < rowActions.length - 1)
                  const SizedBox(width: AppSpacing.s),
              ],
              if (rowActions.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return rows;
  }
}
