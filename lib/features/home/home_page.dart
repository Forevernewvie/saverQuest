import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('home');
  }

  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final l10n = context.l10n;

    void openCalculator() async {
      await widget.dependencies.analyticsService.logEvent(
        AnalyticsEvents.missionCompleted,
        parameters: {'source': 'home_primary'},
      );
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamed(context, AppRoutes.tool);
    }

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
          trailing: const AppHeroIcon(icon: Icons.savings_outlined),
          primaryLabel: l10n.homePrimaryAction,
          secondaryLabel: l10n.homeSecondaryAction,
          primarySemanticLabel: l10n.homePrimaryActionSemantic,
          onPrimary: openCalculator,
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.report),
          pills: [
            AppMetricPill(
              label: l10n.homeStatSavingsLabel,
              value: l10n.homeStatSavingsValue,
            ),
            AppMetricPill(
              label: l10n.homeStatStreakLabel,
              value: l10n.homeStatStreakValue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        AppSectionHeader(title: l10n.homeTodaySectionTitle),
        AppFeatureCard(
          icon: Icons.local_cafe_outlined,
          title: l10n.homeMissionTitle,
          body: l10n.homeMissionBody,
        ),
        AppFeatureCard(
          icon: Icons.show_chart_outlined,
          title: l10n.homeProgressTitle,
          body: l10n.homeProgressBody,
        ),
        const SizedBox(height: AppSpacing.l),
        AppSectionHeader(title: l10n.homeQuickActionsTitle),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            AppQuickActionCard(
              icon: Icons.calculate_outlined,
              label: l10n.navTool,
              body: l10n.homeQuickCalcBody,
              onTap: openCalculator,
            ),
            AppQuickActionCard(
              icon: Icons.receipt_long_outlined,
              label: l10n.navReport,
              body: l10n.homeQuickReportBody,
              onTap: () => Navigator.pushNamed(context, AppRoutes.report),
            ),
            AppQuickActionCard(
              icon: Icons.insights_outlined,
              label: l10n.navInsights,
              body: l10n.homeQuickInsightsBody,
              onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
            ),
          ],
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
