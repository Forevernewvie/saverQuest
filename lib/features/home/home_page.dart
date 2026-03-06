import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_panel.dart';
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

    return ScreenShell(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      children: [
        AppPanel(title: l10n.homeMissionTitle, body: l10n.homeMissionBody),
        AppPanel(title: l10n.homeProgressTitle, body: l10n.homeProgressBody),
        Semantics(
          label: l10n.homePrimaryActionSemantic,
          button: true,
          child: FilledButton(
            onPressed: () async {
              await widget.dependencies.analyticsService.logEvent(
                AnalyticsEvents.missionCompleted,
                parameters: {'source': 'home_primary'},
              );
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamed(context, AppRoutes.tool);
            },
            child: Text(l10n.homePrimaryAction),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.report),
          child: Text(l10n.homeSecondaryAction),
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
        const SizedBox(height: AppSpacing.l),
        Wrap(
          spacing: AppSpacing.s,
          children: [
            _NavChip(
              label: l10n.navTool,
              onTap: () => Navigator.pushNamed(context, AppRoutes.tool),
            ),
            _NavChip(
              label: l10n.navReport,
              onTap: () => Navigator.pushNamed(context, AppRoutes.report),
            ),
            _NavChip(
              label: l10n.navInsights,
              onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
