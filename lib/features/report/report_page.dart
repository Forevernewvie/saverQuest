import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/ad_result.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_panel.dart';
import '../../widgets/screen_shell.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _unlocked = false;
  bool _loading = false;
  AdShowStatus? _lastRewardStatus;

  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('report');
  }

  Future<void> _unlockWithRewarded() async {
    final l10n = context.l10n;
    setState(() => _loading = true);

    if (!AdMobIds.hasReportRewarded) {
      if (!mounted) {
        return;
      }
      setState(() {
        _unlocked = false;
        _loading = false;
        _lastRewardStatus = AdShowStatus.loadFailed;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportRewardUnitMissing)));
      return;
    }

    final consentState = widget.dependencies.consentController.state;
    final result = await widget.dependencies.adService.showRewarded(
      adUnitId: AdMobIds.reportRewarded,
      placement: AdPlacement.reportRewarded,
      routeName: AppRoutes.report,
      canRequestAds: consentState.canRequestAds,
      nonPersonalizedAds: consentState.serveNonPersonalizedAds,
    );

    if (result.rewardEarned) {
      await widget.dependencies.analyticsService.logEvent(
        AnalyticsEvents.reportUnlocked,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _unlocked = result.rewardEarned;
      _loading = false;
      _lastRewardStatus = result.status;
    });

    if (!result.rewardEarned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.reportRewardBlocked(l10n.adStatusLabel(result.status)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.reportTitle,
      children: [
        AppPanel(
          title: l10n.reportFreeSummaryTitle,
          body: l10n.reportFreeSummaryBody,
        ),
        AppPanel(
          title: _unlocked ? l10n.reportUnlockedTitle : l10n.reportLockedTitle,
          body: _unlocked ? l10n.reportUnlockedBody : l10n.reportLockedBody,
        ),
        FilledButton(
          onPressed: _loading ? null : _unlockWithRewarded,
          child: Text(_loading ? l10n.reportLoadingAd : l10n.reportWatchAd),
        ),
        OutlinedButton(onPressed: () {}, child: Text(l10n.reportKeepSummary)),
        const SizedBox(height: AppSpacing.s),
        AppPanel(
          title: l10n.reportFlowTitle,
          body: l10n.reportFlowBody(l10n.adStatusLabel(_lastRewardStatus)),
        ),
        const SizedBox(height: AppSpacing.s),
        AdBannerSlot(
          adService: widget.dependencies.adService,
          adUnitId: AdMobIds.reportBanner,
          placement: AdPlacement.reportBanner,
          routeName: AppRoutes.report,
          canRequestAds: consentState.canRequestAds,
          nonPersonalizedAds: consentState.serveNonPersonalizedAds,
        ),
      ],
    );
  }
}
