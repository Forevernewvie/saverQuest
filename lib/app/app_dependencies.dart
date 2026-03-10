import '../core/ads/ad_guardrails.dart';
import '../core/ads/ad_service.dart';
import '../core/analytics/analytics_service.dart';
import '../core/config/app_environment.dart';
import '../core/config/remote_config_service.dart';
import '../core/content/app_content_repository.dart';
import '../core/consent/att_transparency_service.dart';
import '../core/consent/consent_controller.dart';
import '../core/crash/crash_reporter.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/ledger/ledger_controller.dart';
import '../core/ledger/ledger_month_controller.dart';
import '../core/ledger/ledger_presentation_service.dart';
import '../core/ledger/ledger_view_data_factory.dart';
import '../core/logging/app_logger.dart';

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
    required this.contentRepository,
    required this.ledgerController,
    required this.ledgerMonthController,
    required this.ledgerPresentationService,
    required this.ledgerViewDataFactory,
    required this.logger,
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
  final AppContentRepository contentRepository;
  final LedgerController ledgerController;
  final LedgerMonthController ledgerMonthController;
  final LedgerPresentationService ledgerPresentationService;
  final LedgerViewDataFactory ledgerViewDataFactory;
  final AppLogger logger;
}
