import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/ad_result.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
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
    final hasRewarded = AdMobIds.hasReportRewarded;
    final detailStatus = _unlocked
        ? l10n.reportDetailReadyValue
        : hasRewarded
        ? l10n.reportDetailLockedValue
        : l10n.reportDetailComingSoonValue;

    return ScreenShell(
      title: l10n.reportTitle,
      children: [
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.reportHeroTitle,
          body: l10n.reportHeroBody,
          trailing: const AppHeroIcon(icon: Icons.insights_outlined),
          pills: [
            AppMetricPill(
              label: l10n.reportStatSavingsLabel,
              value: '63,200원',
            ),
            AppMetricPill(
              label: l10n.reportStatTopCategoryLabel,
              value: l10n.reportStatTopCategoryValue,
            ),
            AppMetricPill(
              label: l10n.reportStatDetailLabel,
              value: detailStatus,
            ),
          ],
        ),
        AppSectionHeader(title: l10n.reportFreeSummaryTitle),
        AppFeatureCard(
          icon: Icons.savings_outlined,
          title: l10n.reportFreeSummaryTitle,
          body: l10n.reportFreeSummaryBody,
        ),
        if (_unlocked) ...[
          AppFeatureCard(
            icon: Icons.auto_graph_outlined,
            title: l10n.reportUnlockedTrendTitle,
            body: l10n.reportUnlockedTrendBody,
          ),
          AppFeatureCard(
            icon: Icons.track_changes_outlined,
            title: l10n.reportUnlockedFocusTitle,
            body: l10n.reportUnlockedFocusBody,
          ),
        ] else if (hasRewarded) ...[
          AppFeatureCard(
            icon: Icons.lock_open_outlined,
            title: l10n.reportLockedTitle,
            body: l10n.reportLockedBody,
          ),
          FilledButton(
            onPressed: _loading ? null : _unlockWithRewarded,
            child: Text(_loading ? l10n.reportLoadingAd : l10n.reportWatchAd),
          ),
        ] else ...[
          AppFeatureCard(
            icon: Icons.schedule_outlined,
            title: l10n.reportPreviewTitle,
            body: l10n.reportPreviewBody,
          ),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.insights),
            child: Text(l10n.reportPreviewAction),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        AppSectionHeader(
          title: hasRewarded ? l10n.reportFlowTitle : l10n.reportNextSectionTitle,
        ),
        AppFeatureCard(
          icon: hasRewarded ? Icons.play_circle_outline : Icons.lightbulb_outline,
          title: hasRewarded ? l10n.reportFlowTitle : l10n.reportNextSectionTitle,
          body: hasRewarded
              ? l10n.reportFlowBody(l10n.adStatusLabel(_lastRewardStatus))
              : l10n.reportNextSectionBody,
        ),
        if (!_unlocked && hasRewarded)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              l10n.reportKeepSummary,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
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
