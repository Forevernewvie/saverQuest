import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ads/ad_guardrails.dart';
import '../core/ads/admob_ids.dart';
import '../core/ads/ad_service.dart';
import '../core/ads/google_mobile_ad_service.dart';
import '../core/analytics/analytics_service.dart';
import '../core/config/app_environment.dart';
import '../core/config/app_runtime_options.dart';
import '../core/config/remote_config_service.dart';
import '../core/content/app_content_repository.dart';
import '../core/consent/att_transparency_service.dart';
import '../core/consent/consent_controller.dart';
import '../core/consent/consent_platform.dart';
import '../core/crash/crash_reporter.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/ledger/ledger_controller.dart';
import '../core/ledger/ledger_month_controller.dart';
import '../core/ledger/ledger_models.dart';
import '../core/ledger/ledger_presentation_service.dart';
import '../core/ledger/ledger_repository.dart';
import '../core/ledger/ledger_view_data_factory.dart';
import '../core/logging/app_logger.dart';
import 'app_dependencies.dart';

typedef AdServiceFactory =
    AdService Function({
      required AnalyticsService analyticsService,
      required AppLogger logger,
      required AdGuardrails guardrails,
      required List<String> testDeviceIds,
    });

/// Builds fully initialized application dependencies for the composition root.
class AppBootstrapper {
  /// Creates a bootstrapper with explicit runtime options and logging.
  AppBootstrapper({
    required this.runtimeOptions,
    required this.logger,
    this.sharedPreferencesFactory = SharedPreferences.getInstance,
    this.localeStorage,
    this.consentPlatform = const GoogleMobileAdsConsentPlatform(),
    this.adServiceFactory = _defaultAdServiceFactory,
    this.startupTimeout = const Duration(seconds: 5),
  });

  final AppRuntimeOptions runtimeOptions;
  final AppLogger logger;
  final Future<SharedPreferences> Function() sharedPreferencesFactory;
  final LocaleStorage? localeStorage;
  final ConsentPlatform consentPlatform;
  final AdServiceFactory adServiceFactory;
  final Duration startupTimeout;
  Duration get _consentSdkFlowTimeout {
    final timeoutMs = startupTimeout.inMilliseconds;
    if (timeoutMs <= 1) {
      return startupTimeout;
    }
    if (timeoutMs <= 100) {
      return Duration(milliseconds: timeoutMs ~/ 2);
    }
    return Duration(milliseconds: timeoutMs - 100);
  }

  /// Initializes services, external SDKs, and immutable app dependencies.
  Future<AppDependencies> bootstrap() async {
    final firebaseReady = await _tryInitializeFirebase();

    final analyticsService = AnalyticsService(
      logger: logger,
      firebaseAnalytics: firebaseReady ? FirebaseAnalytics.instance : null,
    );
    await _runStartupStep(
      step: 'analytics.set_environment',
      action: () => analyticsService.setEnvironment(runtimeOptions.environment.name),
    );

    final remoteConfigService = RemoteConfigService(
      logger: logger,
      remoteConfig: firebaseReady ? FirebaseRemoteConfig.instance : null,
    );
    await _runStartupStep(
      step: 'remote_config.initialize',
      action: remoteConfigService.initialize,
    );

    final crashReporter = CrashReporter(
      logger: logger,
      crashlytics: firebaseReady ? FirebaseCrashlytics.instance : null,
    );
    await _runStartupStep(
      step: 'crash.install_global_handlers',
      action: crashReporter.installGlobalHandlers,
    );

    final sharedPreferences = await _runStartupStepWithFallback<SharedPreferences?>(
      step: 'shared_preferences.get_instance',
      action: sharedPreferencesFactory,
      fallbackValue: null,
    );

    final effectiveLocaleStorage =
        localeStorage ??
        (sharedPreferences == null
            ? _InMemoryLocaleStorage()
            : _SharedPreferencesLocaleStorage(sharedPreferences));
    final localeController = AppLocaleController(storage: effectiveLocaleStorage);
    await _runStartupStep(
      step: 'locale.initialize',
      action: localeController.initialize,
    );

    final ledgerController = LedgerController(
      repository: sharedPreferences == null
          ? _InMemoryLedgerRepository()
          : SharedPreferencesLedgerRepository(preferences: sharedPreferences),
      logger: logger,
    );
    await _runStartupStep(
      step: 'ledger.initialize',
      action: ledgerController.initialize,
    );

    final consentController = ConsentController(
      analyticsService: analyticsService,
      logger: logger,
      consentPlatform: consentPlatform,
      sdkFlowTimeout: _consentSdkFlowTimeout,
    );
    final attTransparencyService = AttTransparencyService(
      analyticsService: analyticsService,
    );

    final adGuardrails = AdGuardrails(
      interstitialInterval: remoteConfigService.interstitialInterval,
      interstitialCooldownSec: remoteConfigService.interstitialCooldownSec,
      rewardedDailyCap: remoteConfigService.rewardedDailyCap,
    );

    final adService = adServiceFactory(
      analyticsService: analyticsService,
      logger: logger,
      guardrails: adGuardrails,
      testDeviceIds: runtimeOptions.adTestDeviceIds,
    );

    await _runStartupStep(step: 'ads.initialize', action: adService.initialize);
    _logAdMobIdWarningsIfAny();
    await _runStartupStep(
      step: 'consent.refresh',
      action: consentController.refreshConsent,
    );

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
      ledgerController: ledgerController,
      ledgerMonthController: LedgerMonthController(),
      ledgerPresentationService: const LedgerPresentationService(),
      ledgerViewDataFactory: const LedgerViewDataFactory(),
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

  /// Runs a startup step with timeout/error containment so the app can still boot.
  Future<void> _runStartupStep({
    required String step,
    required Future<void> Function() action,
  }) async {
    await _runStartupStepWithFallback<void>(
      step: step,
      action: action,
      fallbackValue: null,
    );
  }

  /// Runs a startup step and returns a fallback value if it throws or times out.
  Future<T> _runStartupStepWithFallback<T>({
    required String step,
    required Future<T> Function() action,
    required T fallbackValue,
  }) async {
    try {
      return await action().timeout(
        startupTimeout,
        onTimeout: () {
          logger.warning(
            'Startup step timed out. Continuing with fallback.',
            scope: 'bootstrap',
            metadata: {
              'step': step,
              'timeout_ms': startupTimeout.inMilliseconds,
            },
          );
          return fallbackValue;
        },
      );
    } catch (error, stackTrace) {
      logger.warning(
        'Startup step failed. Continuing with fallback.',
        scope: 'bootstrap',
        metadata: {'step': step},
      );
      logger.error(
        'Startup step exception captured.',
        scope: 'bootstrap',
        error: error,
        stackTrace: stackTrace,
        metadata: {'step': step},
      );
      return fallbackValue;
    }
  }

  static AdService _defaultAdServiceFactory({
    required AnalyticsService analyticsService,
    required AppLogger logger,
    required AdGuardrails guardrails,
    required List<String> testDeviceIds,
  }) {
    return GoogleMobileAdService(
      analyticsService: analyticsService,
      logger: logger,
      guardrails: guardrails,
      testDeviceIds: testDeviceIds,
    );
  }
}

class _SharedPreferencesLocaleStorage implements LocaleStorage {
  _SharedPreferencesLocaleStorage(this._preferences);

  static const String _localeCodeKey = 'app_locale_code';
  final SharedPreferences _preferences;

  @override
  Future<String?> loadLocaleCode() async {
    return _preferences.getString(_localeCodeKey);
  }

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    await _preferences.setString(_localeCodeKey, localeCode);
  }
}

class _InMemoryLocaleStorage implements LocaleStorage {
  String? _localeCode;

  @override
  Future<String?> loadLocaleCode() async => _localeCode;

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    _localeCode = localeCode;
  }
}

class _InMemoryLedgerRepository implements LedgerRepository {
  LedgerSnapshot _snapshot = const LedgerSnapshot(
    entries: [],
    monthlyBudgetAmount: 350000,
  );

  @override
  Future<LedgerSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> saveSnapshot(LedgerSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
