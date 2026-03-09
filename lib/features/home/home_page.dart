import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/content/app_content_repository.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
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

  /// Opens the calculator and records the source of the primary CTA.
  Future<void> _openCalculator() async {
    await widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.missionCompleted,
      parameters: {'source': 'home_primary'},
    );
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, AppRoutes.tool);
  }

  /// Builds the stack of quick actions for the budgeting dashboard.
  List<HomeQuickActionItem> _buildQuickActions(
    BuildContext context,
    HomeDashboardContent homeContent,
  ) {
    final l10n = context.l10n;
    return [
      HomeQuickActionItem(
        icon: Icons.calculate_outlined,
        label: l10n.navTool,
        categoryLabel: l10n.homeQuickCalcTag,
        trailingValue: l10n.formatCurrency(homeContent.missionSavingsAmount),
        body: l10n.homeQuickCalcBody,
        onTap: _openCalculator,
      ),
      HomeQuickActionItem(
        icon: Icons.receipt_long_outlined,
        label: l10n.navReport,
        categoryLabel: l10n.homeQuickReportTag,
        trailingValue: l10n.homeStatGoalValue(homeContent.goalProgressPercent),
        body: l10n.homeQuickReportBody,
        onTap: () => Navigator.pushNamed(context, AppRoutes.report),
      ),
      HomeQuickActionItem(
        icon: Icons.insights_outlined,
        label: l10n.navInsights,
        categoryLabel: l10n.homeQuickInsightsTag,
        trailingValue: l10n.homeStatStreakValue(homeContent.streakDays),
        body: l10n.homeQuickInsightsBody,
        onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
      ),
    ];
  }

  /// Builds the personalized home dashboard using repository-provided content.
  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final homeContent = widget.dependencies.contentRepository.getHomeContent();
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.homeTitle,
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
          trailing: const AppHeroIcon(
            icon: Icons.account_balance_wallet_outlined,
          ),
          primaryLabel: l10n.homePrimaryAction,
          secondaryLabel: l10n.homeSecondaryAction,
          primarySemanticLabel: l10n.homePrimaryActionSemantic,
          onPrimary: _openCalculator,
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.report),
          pills: [
            AppMetricPill(
              label: l10n.homeStatSavingsLabel,
              value: l10n.homeStatSavingsValue(homeContent.weeklySavingsAmount),
            ),
            AppMetricPill(
              label: l10n.homeStatRemainingLabel,
              value: l10n.homeStatRemainingValue(
                homeContent.remainingBudgetAmount,
              ),
            ),
            AppMetricPill(
              label: l10n.homeStatStreakLabel,
              value: l10n.homeStatStreakValue(homeContent.streakDays),
            ),
          ],
        ),
        AppSectionHeader(title: l10n.homeTodaySectionTitle),
        HomeBudgetOverviewSection(content: homeContent, l10n: l10n),
        AppFeatureCard(
          icon: Icons.savings_outlined,
          title: l10n.homeMissionTitle,
          body: l10n.homeMissionBodyForCategory(
            category: homeContent.missionCategory,
            savingsAmount: homeContent.missionSavingsAmount,
          ),
          trailing: Text(
            l10n.formatCurrency(homeContent.missionSavingsAmount),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        HomeQuickActionsSection(
          title: l10n.homeQuickActionsTitle,
          subtitle: l10n.homeQuickActionsSubtitle,
          actions: _buildQuickActions(context, homeContent),
        ),
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
  }
}
