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
      showAppBar: false,
      centerContent: false,
      children: [
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.onboardingIntroTitle,
          body: l10n.onboardingIntroBody,
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
        if (consentState.errorMessage != null)
          _OnboardingStatusCard(
            icon: Icons.error_outline,
            color: AppColors.danger,
            message: l10n.errorMessage(consentState.errorMessage!),
          ),
        if (_loading)
          _OnboardingStatusCard(
            icon: Icons.hourglass_bottom_outlined,
            color: AppColors.textSecondary,
            message: l10n.onboardingAgreeProcessing,
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
          icon: Icons.verified_user_outlined,
          title: l10n.onboardingConsentTitle,
          body: l10n.onboardingConsentBody,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _OnboardingStatusCard extends StatelessWidget {
  const _OnboardingStatusCard({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
