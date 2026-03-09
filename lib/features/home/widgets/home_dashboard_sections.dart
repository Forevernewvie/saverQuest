import 'package:flutter/material.dart';

import '../../../core/content/app_content_repository.dart';
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
    required this.content,
    required this.l10n,
  });

  final HomeDashboardContent content;
  final AppLocalizations l10n;

  /// Builds the budget overview card with progress and summary figures.
  @override
  Widget build(BuildContext context) {
    return AppBudgetOverviewCard(
      title: l10n.homeBudgetOverviewTitle,
      body: l10n.homeBudgetOverviewBody,
      progressValue: content.monthlySpentAmount / content.monthlyBudgetAmount,
      remainingLabel: l10n.homeStatRemainingLabel,
      remainingValue: l10n.homeStatRemainingValue(
        content.remainingBudgetAmount,
      ),
      spentLabel: l10n.homeBudgetSpentLabel,
      spentValue: l10n.formatCurrency(content.monthlySpentAmount),
      limitLabel: l10n.homeBudgetLimitLabel,
      limitValue: l10n.formatCurrency(content.monthlyBudgetAmount),
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

  /// Builds a single-column quick-action stack optimized for mobile use.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        for (var index = 0; index < actions.length; index++) ...[
          AppQuickActionCard(
            icon: actions[index].icon,
            label: actions[index].label,
            categoryLabel: actions[index].categoryLabel,
            trailingValue: actions[index].trailingValue,
            body: actions[index].body,
            onTap: actions[index].onTap,
          ),
          if (index < actions.length - 1) const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}
