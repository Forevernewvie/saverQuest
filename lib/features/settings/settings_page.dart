import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/adaptive_layout.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_locale_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _updatingPrivacyOptions = false;

  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('settings');
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

  /// Opens the in-app privacy policy screen from settings.
  void _openPrivacyPolicy() {
    Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
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
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.settingsTitle,
          body: l10n.settingsHeroBody,
          trailing: const AppHeroIcon(icon: Icons.settings_outlined),
        ),
        AppFeatureCard(
          icon: Icons.verified_user_outlined,
          title: l10n.settingsConsentStateTitle,
          body: l10n.settingsConsentStateBody(
            canRequestAds: consentState.canRequestAds,
            nonPersonalized: consentState.serveNonPersonalizedAds,
            privacyOptionsRequired: consentState.privacyOptionsRequired,
          ),
        ),
        AppFeatureCard(
          icon: Icons.ads_click_outlined,
          title: l10n.settingsAdsInfoTitle,
          body: l10n.settingsAdsInfoBody,
        ),
        AppSectionHeader(title: l10n.settingsManageTitle),
        _SettingsControlCard(
          title: l10n.settingsLanguageTitle,
          subtitle: l10n.settingsLanguageSubtitle,
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
        _SettingsControlCard(
          title: l10n.settingsPrivacyOptionsTitle,
          subtitle: consentState.privacyOptionsRequired
              ? l10n.settingsPrivacyOptionsSubtitleRequired
              : l10n.settingsPrivacyOptionsSubtitleNotRequired,
          trailing: _updatingPrivacyOptions
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: _updatingPrivacyOptions
              ? null
              : () {
                  _openPrivacyOptions();
                },
        ),
        _SettingsControlCard(
          title: l10n.settingsPrivacyPolicyTitle,
          subtitle: l10n.settingsPrivacyPolicySubtitle,
          trailing: const Icon(Icons.chevron_right),
          onTap: _openPrivacyPolicy,
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

class _SettingsControlCard extends StatelessWidget {
  const _SettingsControlCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  /// Returns whether the trailing control should move below the copy block.
  bool _useStackedTrailing(BuildContext context, double availableWidth) {
    return AdaptiveLayout.useStackedLayout(context, availableWidth);
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedTrailing = _useStackedTrailing(
            context,
            constraints.maxWidth,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!useStackedTrailing) ...[
                    const SizedBox(width: AppSpacing.m),
                    trailing,
                  ],
                ],
              ),
              if (useStackedTrailing) ...[
                const SizedBox(height: AppSpacing.s),
                Align(alignment: Alignment.centerRight, child: trailing),
              ],
            ],
          );
        },
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}
