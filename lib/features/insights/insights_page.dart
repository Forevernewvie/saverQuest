import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/ledger/ledger_view_data.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  /// Logs the initial insights screen impression for analytics.
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('insights');
  }

  /// Builds narrative insight cards in one column or two responsive columns.
  Widget _buildInsightCards(
    BuildContext context,
    AppLocalizations l10n,
    LedgerInsightsViewData viewData,
  ) {
    final primaryStack = Column(
      children: [
        AppFeatureCard(
          icon: Icons.flag_outlined,
          title: l10n.insightsSegmentATitle,
          body: viewData.primaryBody,
        ),
        AppFeatureCard(
          icon: Icons.tune_outlined,
          title: l10n.insightsSegmentBTitle,
          body: viewData.secondaryBody,
        ),
      ],
    );
    final budgetCard = AppFeatureCard(
      icon: Icons.account_balance_wallet_outlined,
      title: l10n.insightsResultTitle,
      body: viewData.budgetBody,
    );

    return AppResponsiveTwoPane(
      primary: primaryStack,
      secondary: budgetCard,
      primaryFlex: 3,
      secondaryFlex: 2,
      spacing: AppSpacing.s,
    );
  }

  /// Builds the insights screen from the live ledger state.
  @override
  Widget build(BuildContext context) {
    final ledgerController = widget.dependencies.ledgerController;
    final monthController = widget.dependencies.ledgerMonthController;

    return AnimatedBuilder(
      animation: Listenable.merge([ledgerController, monthController]),
      builder: (context, _) {
        final l10n = context.l10n;
        final selectedMonth = monthController.selectedMonth;
        final summary = ledgerController.insightSummary(now: selectedMonth);
        final viewData = widget.dependencies.ledgerViewDataFactory
            .buildInsightsViewData(l10n: l10n, summary: summary);

        return ScreenShell(
          title: l10n.insightsTitle,
          children: [
            AppHeroCard(
              eyebrow: l10n.appTitle,
              title: l10n.insightsTitle,
              body: l10n.insightsHeroBody,
              trailing: const AppHeroIcon(icon: Icons.insights_outlined),
            ),
            AppMonthSwitcher(
              label: l10n.formatMonthYear(selectedMonth),
              onPrevious: monthController.showPreviousMonth,
              onNext: monthController.showNextMonth,
              onReset: monthController.resetToCurrentMonth,
              nextEnabled: !monthController.isCurrentMonth,
            ),
            AppSectionHeader(
              title: l10n.insightsNoAdTitle,
              subtitle: l10n.insightsNoAdBody,
            ),
            if (!viewData.hasEntries)
              AppEmptyStateCard(
                icon: Icons.insights_outlined,
                title: l10n.homeEmptyRecordsTitle,
                body: l10n.homeEmptyRecordsBody,
                actionLabel: l10n.homePrimaryAction,
                onAction: () => Navigator.pushNamed(context, AppRoutes.tool),
              )
            else
              _buildInsightCards(context, l10n, viewData),
          ],
        );
      },
    );
  }
}
