import '../core/ads/ad_guardrails.dart';
import '../core/ads/ad_service.dart';
import '../core/analytics/analytics_service.dart';
import '../core/config/app_environment.dart';
import '../core/config/remote_config_service.dart';
import '../core/consent/att_transparency_service.dart';
import '../core/consent/consent_controller.dart';
import '../core/crash/crash_reporter.dart';
import '../core/localization/app_locale_controller.dart';

class AppDependencies {
  const AppDependencies({
    required this.environment,
    required this.adGuardrails,
    required this.adService,
    required this.analyticsService,
    required this.remoteConfigService,
    required this.consentController,
    required this.attTransparencyService,
    required this.localeController,
    required this.crashReporter,
  });

  final AppEnvironment environment;
  final AdGuardrails adGuardrails;
  final AdService adService;
  final AnalyticsService analyticsService;
  final RemoteConfigService remoteConfigService;
  final ConsentController consentController;
  final AttTransparencyService attTransparencyService;
  final AppLocaleController localeController;
  final CrashReporter crashReporter;
}
