import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _loading = false;
  bool _bootstrappedConsent = false;

  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('onboarding');
    widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.onboardingViewed,
    );
    unawaited(_bootstrapConsentFlow());
  }

  Future<void> _bootstrapConsentFlow() async {
    if (_bootstrappedConsent || _loading) {
      return;
    }
    _bootstrappedConsent = true;
    setState(() => _loading = true);

    try {
      await widget.dependencies.consentController.refreshConsent();
      await widget.dependencies.consentController.gatherConsentIfRequired();
      await widget.dependencies.attTransparencyService.requestIfNeeded();
    } catch (error, stackTrace) {
      _bootstrappedConsent = false;
      await widget.dependencies.crashReporter.recordNonFatal(error, stackTrace);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _startWithConsent() async {
    if (!widget.dependencies.consentController.state.initialized ||
        widget.dependencies.consentController.state.errorMessage != null) {
      _bootstrappedConsent = false;
      await _bootstrapConsentFlow();
    }

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.onboardingTitle,
      children: [
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.onboardingIntroTitle,
          body: l10n.onboardingIntroBody,
          trailing: const AppHeroIcon(icon: Icons.verified_user_outlined),
          primaryLabel: l10n.onboardingAgreeStart,
          primarySemanticLabel: l10n.onboardingAgreeSemantic,
          onPrimary: _loading
              ? null
              : () {
                  _startWithConsent();
                },
          secondaryLabel: l10n.onboardingLater,
          onSecondary: _loading
              ? null
              : () => Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
        AppSectionHeader(
          title: l10n.onboardingTrustSectionTitle,
          subtitle: l10n.onboardingSettingsHint,
        ),
        AppFeatureCard(
          icon: Icons.visibility_off_outlined,
          title: l10n.onboardingNoAdTitle,
          body: l10n.onboardingNoAdBody,
        ),
        AppFeatureCard(
          icon: Icons.tune_outlined,
          title: l10n.onboardingConsentTitle,
          body: l10n.onboardingConsentBody,
        ),
        if (consentState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              l10n.errorMessage(consentState.errorMessage!),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        if (_loading)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              l10n.onboardingAgreeProcessing,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
