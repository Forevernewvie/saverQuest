import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/ledger/ledger_models.dart';
import '../../core/ledger/ledger_view_data.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/common/ledger_entry_detail_sheet.dart';
import '../../widgets/screen_shell.dart';
import 'widgets/home_dashboard_sections.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Logs the initial home screen impression for analytics.
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('home');
  }

  /// Opens the quick-entry screen and records the source of the CTA.
  Future<void> _openEntry() async {
    await widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.missionCompleted,
      parameters: {'source': 'home_primary'},
    );
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, AppRoutes.tool);
  }

  /// Opens the shared transaction detail sheet from home recent activity.
  Future<void> _showEntryDetails(LedgerEntry entry) async {
    final l10n = context.l10n;
    final rowViewData = widget.dependencies.ledgerViewDataFactory
        .buildTransactionRow(l10n: l10n, entry: entry);

    await showLedgerEntryDetailSheet(
      context: context,
      entry: entry,
      rowViewData: rowViewData,
      onEdit: () => Navigator.pushNamed(context, AppRoutes.tool),
    );
  }

  /// Builds the recent transaction list or a first-run empty state.
  Widget _buildRecentEntries(
    BuildContext context,
    List<LedgerEntry> recentEntries,
  ) {
    final l10n = context.l10n;

    if (recentEntries.isEmpty) {
      return AppEmptyStateCard(
        icon: Icons.edit_note_outlined,
        title: l10n.homeEmptyRecordsTitle,
        body: l10n.homeEmptyRecordsBody,
        actionLabel: l10n.homePrimaryAction,
        onAction: _openEntry,
      );
    }

    return AppTransactionList(
      itemCount: recentEntries.length,
      itemBuilder: (context, index) {
        final entry = recentEntries[index];
        final row = widget.dependencies.ledgerViewDataFactory
            .buildTransactionRow(l10n: l10n, entry: entry);

        return AppTransactionTile(
          key: ValueKey(entry.id),
          icon: row.icon,
          title: row.title,
          subtitle: row.subtitle,
          trailing: row.trailing,
          onTap: () => _showEntryDetails(entry),
        );
      },
    );
  }

  /// Builds the monthly overview block using one or two columns responsively.
  Widget _buildMonthlyOverview(
    BuildContext context,
    AppLocalizations l10n,
    LedgerDashboardSummary dashboard,
    HomeDashboardViewData viewData,
  ) {
    final overview = HomeBudgetOverviewSection(
      monthlyBudgetAmount: dashboard.monthlyBudgetAmount,
      monthlyExpenseAmount: dashboard.monthlyExpenseAmount,
      remainingBudgetAmount: dashboard.remainingBudgetAmount,
      l10n: l10n,
    );
    final focusCard = AppFeatureCard(
      icon: Icons.flag_outlined,
      title: l10n.homeMissionTitle,
      body: viewData.topCategoryBody,
      trailing: Text(
        viewData.topCategoryValue,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return AppResponsiveTwoPane(
      primary: overview,
      secondary: focusCard,
      primaryFlex: 3,
      secondaryFlex: 2,
      spacing: AppSpacing.m,
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
    );
  }

  /// Builds the personalized home dashboard from the live ledger state.
  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final ledgerController = widget.dependencies.ledgerController;
    final monthController = widget.dependencies.ledgerMonthController;

    return AnimatedBuilder(
      animation: Listenable.merge([ledgerController, monthController]),
      builder: (context, _) {
        final l10n = context.l10n;
        final selectedMonth = monthController.selectedMonth;
        final dashboard = ledgerController.dashboardSummary(now: selectedMonth);
        final report = ledgerController.reportSummary(now: selectedMonth);
        final viewData = widget.dependencies.ledgerViewDataFactory
            .buildHomeViewData(
              l10n: l10n,
              dashboard: dashboard,
              report: report,
            );

        return ScreenShell(
          title: l10n.homeTitle,
          primaryNavigationRoute: AppRoutes.home,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          children: [
            AppHeroCard(
              eyebrow: l10n.appTitle,
              title: l10n.homeHeroTitle,
              body: l10n.homeHeroBody,
              primaryLabel: l10n.homePrimaryAction,
              primarySemanticLabel: l10n.homePrimaryActionSemantic,
              onPrimary: _openEntry,
              pills: [
                AppMetricPill(
                  label: l10n.homeStatRemainingLabel,
                  value: viewData.remainingBudgetValue,
                ),
                AppMetricPill(
                  label: l10n.homeStatSavingsLabel,
                  value: viewData.monthlyExpenseValue,
                ),
              ],
            ),
            AppMonthSwitcher(
              label: l10n.formatMonthYear(selectedMonth),
              onPrevious: monthController.showPreviousMonth,
              onNext: monthController.showNextMonth,
              onReset: monthController.resetToCurrentMonth,
              nextEnabled: !monthController.isCurrentMonth,
            ),
            AppSectionHeader(title: l10n.homeTodaySectionTitle),
            _buildMonthlyOverview(context, l10n, dashboard, viewData),
            AppSectionHeader(
              title: l10n.homeRecentEntriesTitle,
              subtitle: l10n.homeRecentEntriesSubtitle,
            ),
            _buildRecentEntries(context, dashboard.recentEntries),
            const SizedBox(height: AppSpacing.m),
            AdBannerSlot(
              adService: widget.dependencies.adService,
              adUnitId: AdMobIds.homeBanner,
              placement: AdPlacement.homeBanner,
              routeName: AppRoutes.home,
              canRequestAds: consentState.canRequestAds,
              nonPersonalizedAds: consentState.serveNonPersonalizedAds,
            ),
          ],
        );
      },
    );
  }
}
