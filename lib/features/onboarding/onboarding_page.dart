import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_panel.dart';
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

    await widget.dependencies.consentController.refreshConsent();
    await widget.dependencies.consentController.gatherConsentIfRequired();
    await widget.dependencies.attTransparencyService.requestIfNeeded();

    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
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
        AppPanel(
          title: l10n.onboardingNoAdTitle,
          body: l10n.onboardingNoAdBody,
        ),
        AppPanel(
          title: l10n.onboardingConsentTitle,
          body: l10n.onboardingConsentBody,
        ),
        AppPanel(
          title: l10n.onboardingCurrentStatusTitle,
          body: l10n.onboardingCurrentStatusBody(
            initialized: consentState.initialized,
            canRequestAds: consentState.canRequestAds,
            nonPersonalized: consentState.serveNonPersonalizedAds,
          ),
        ),
        if (consentState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              l10n.errorMessage(consentState.errorMessage!),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        Semantics(
          label: l10n.onboardingAgreeSemantic,
          button: true,
          child: FilledButton(
            onPressed: _loading ? null : _startWithConsent,
            child: Text(
              _loading
                  ? l10n.onboardingAgreeProcessing
                  : l10n.onboardingAgreeStart,
            ),
          ),
        ),
        Semantics(
          label: l10n.onboardingLaterSemantic,
          button: true,
          child: OutlinedButton(
            onPressed: _loading
                ? null
                : () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            child: Text(l10n.onboardingLater),
          ),
        ),
      ],
    );
  }
}
