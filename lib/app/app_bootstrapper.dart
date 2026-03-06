import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../core/ads/ad_guardrails.dart';
import '../core/ads/admob_ids.dart';
import '../core/ads/google_mobile_ad_service.dart';
import '../core/analytics/analytics_service.dart';
import '../core/config/app_environment.dart';
import '../core/config/app_runtime_options.dart';
import '../core/config/remote_config_service.dart';
import '../core/content/app_content_repository.dart';
import '../core/consent/att_transparency_service.dart';
import '../core/consent/consent_controller.dart';
import '../core/crash/crash_reporter.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/logging/app_logger.dart';
import 'app_dependencies.dart';

/// Builds fully initialized application dependencies for the composition root.
class AppBootstrapper {
  /// Creates a bootstrapper with explicit runtime options and logging.
  const AppBootstrapper({
    required this.runtimeOptions,
    required this.logger,
  });

  final AppRuntimeOptions runtimeOptions;
  final AppLogger logger;

  /// Initializes services, external SDKs, and immutable app dependencies.
  Future<AppDependencies> bootstrap() async {
    final firebaseReady = await _tryInitializeFirebase();

    final analyticsService = AnalyticsService(
      logger: logger,
      firebaseAnalytics: firebaseReady ? FirebaseAnalytics.instance : null,
    );
    await analyticsService.setEnvironment(runtimeOptions.environment.name);

    final remoteConfigService = RemoteConfigService(
      logger: logger,
      remoteConfig: firebaseReady ? FirebaseRemoteConfig.instance : null,
    );
    await remoteConfigService.initialize();

    final crashReporter = CrashReporter(
      logger: logger,
      crashlytics: firebaseReady ? FirebaseCrashlytics.instance : null,
    );
    await crashReporter.installGlobalHandlers();

    final localeController = AppLocaleController();
    await localeController.initialize();

    final consentController = ConsentController(
      analyticsService: analyticsService,
    );
    final attTransparencyService = AttTransparencyService(
      analyticsService: analyticsService,
    );

    final adGuardrails = AdGuardrails(
      interstitialInterval: remoteConfigService.interstitialInterval,
      interstitialCooldownSec: remoteConfigService.interstitialCooldownSec,
      rewardedDailyCap: remoteConfigService.rewardedDailyCap,
    );

    final adService = GoogleMobileAdService(
      analyticsService: analyticsService,
      guardrails: adGuardrails,
      testDeviceIds: runtimeOptions.adTestDeviceIds,
    );

    await adService.initialize();
    _logAdMobIdWarningsIfAny();
    await consentController.refreshConsent();

    return AppDependencies(
      environment: runtimeOptions.environment,
      adGuardrails: adGuardrails,
      adService: adService,
      analyticsService: analyticsService,
      remoteConfigService: remoteConfigService,
      consentController: consentController,
      attTransparencyService: attTransparencyService,
      localeController: localeController,
      crashReporter: crashReporter,
      contentRepository: const StaticAppContentRepository(),
      logger: logger,
    );
  }

  /// Tries to initialize Firebase and degrades gracefully when config is absent.
  Future<bool> _tryInitializeFirebase() async {
    try {
      await Firebase.initializeApp();
      logger.info(
        'Firebase initialized successfully.',
        scope: 'bootstrap',
        metadata: {'environment': runtimeOptions.environment.name},
      );
      return true;
    } catch (error, stackTrace) {
      logger.warning(
        'Firebase initialization failed. Continuing without Firebase.',
        scope: 'bootstrap',
        metadata: {'environment': runtimeOptions.environment.name},
      );
      logger.error(
        'Firebase initialization exception captured.',
        scope: 'bootstrap',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Emits production-only warnings for missing or test ad identifiers.
  void _logAdMobIdWarningsIfAny() {
    if (!runtimeOptions.environment.isProd) {
      return;
    }

    final warnings = AdMobIds.productionReadinessWarnings();
    for (final warning in warnings) {
      logger.warning(
        warning,
        scope: 'admob',
        metadata: {'environment': runtimeOptions.environment.name},
      );
    }
  }
}
