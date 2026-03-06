import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_locale_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_panel.dart';
import '../../widgets/screen_shell.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _saving = false;
  bool _updatingPrivacyOptions = false;

  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('settings');
  }

  Future<void> _saveGuardrails() async {
    setState(() => _saving = true);

    await widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.settingsSaved,
      parameters: {
        'frequency_cap':
            'banner_1_fixed/interstitial_${widget.dependencies.remoteConfigService.interstitialInterval}_actions/rewarded_${widget.dependencies.remoteConfigService.rewardedDailyCap}_day',
      },
    );

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsGuardrailsSaved)),
    );
  }

  Future<void> _openPrivacyOptions() async {
    if (_updatingPrivacyOptions) {
      return;
    }

    if (!widget.dependencies.consentController.state.privacyOptionsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsPrivacyOptionsNotRequired)),
      );
      return;
    }

    setState(() => _updatingPrivacyOptions = true);
    await widget.dependencies.consentController.showPrivacyOptionsForm();
    final latestState = widget.dependencies.consentController.state;

    if (!mounted) {
      return;
    }

    setState(() => _updatingPrivacyOptions = false);

    if (latestState.errorMessage != null) {
      await widget.dependencies.analyticsService.logEvent(
        AnalyticsEvents.privacyOptionsFailed,
        parameters: {'error': latestState.errorMessage!},
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.settingsPrivacyOptionsFailed(
              latestState.errorMessage!,
            ),
          ),
        ),
      );
      return;
    }

    await widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.privacyOptionsOpened,
      parameters: {
        'can_request_ads': latestState.canRequestAds,
        'non_personalized': latestState.serveNonPersonalizedAds,
      },
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsPrivacyOptionsUpdated)),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    await widget.dependencies.localeController.setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final l10n = context.l10n;
    final currentLanguageCode =
        widget.dependencies.localeController.locale?.languageCode ??
        AppLocaleController.fallbackFor(
          Localizations.localeOf(context),
        ).languageCode;

    return ScreenShell(
      title: l10n.settingsTitle,
      children: [
        AppPanel(
          title: l10n.settingsConsentStateTitle,
          body: l10n.settingsConsentStateBody(
            canRequestAds: consentState.canRequestAds,
            nonPersonalized: consentState.serveNonPersonalizedAds,
            privacyOptionsRequired: consentState.privacyOptionsRequired,
          ),
        ),
        AppPanel(
          title: l10n.settingsFrequencyCapTitle,
          body: l10n.settingsFrequencyCapBody(
            interstitialInterval:
                widget.dependencies.remoteConfigService.interstitialInterval,
            rewardedDailyCap:
                widget.dependencies.remoteConfigService.rewardedDailyCap,
          ),
        ),
        AppPanel(
          title: l10n.settingsPolicyRiskTitle,
          body: l10n.settingsPolicyRiskBody,
        ),
        FilledButton(
          onPressed: _saving ? null : _saveGuardrails,
          child: Text(
            _saving ? l10n.settingsSaving : l10n.settingsSaveGuardrails,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsLanguageTitle),
          subtitle: Text(l10n.settingsLanguageSubtitle),
          trailing: DropdownButton<String>(
            value: currentLanguageCode,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              _changeLanguage(value);
            },
            items: [
              DropdownMenuItem(value: 'ko', child: Text(l10n.languageKorean)),
              DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
            ],
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsPrivacyOptionsTitle),
          subtitle: Text(
            consentState.privacyOptionsRequired
                ? l10n.settingsPrivacyOptionsSubtitleRequired
                : l10n.settingsPrivacyOptionsSubtitleNotRequired,
          ),
          trailing: _updatingPrivacyOptions
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: _updatingPrivacyOptions ? null : _openPrivacyOptions,
        ),
        const SizedBox(height: AppSpacing.s),
        AdBannerSlot(
          adService: widget.dependencies.adService,
          adUnitId: AdMobIds.settingsBanner,
          placement: AdPlacement.settingsBanner,
          routeName: AppRoutes.settings,
          canRequestAds: consentState.canRequestAds,
          nonPersonalizedAds: consentState.serveNonPersonalizedAds,
        ),
      ],
    );
  }
}
