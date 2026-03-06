import 'dart:developer' as developer;
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'core/ads/ad_guardrails.dart';
import 'core/ads/admob_ids.dart';
import 'core/ads/google_mobile_ad_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/config/app_environment.dart';
import 'core/config/remote_config_service.dart';
import 'core/consent/att_transparency_service.dart';
import 'core/consent/consent_controller.dart';
import 'core/crash/crash_reporter.dart';
import 'core/localization/app_locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = appEnvironmentFromDefine();
  final firebaseReady = await _tryInitializeFirebase();

  final analyticsService = AnalyticsService(
    firebaseAnalytics: firebaseReady ? FirebaseAnalytics.instance : null,
  );
  await analyticsService.setEnvironment(environment.name);

  final remoteConfigService = RemoteConfigService(
    remoteConfig: firebaseReady ? FirebaseRemoteConfig.instance : null,
  );
  await remoteConfigService.initialize();

  final crashReporter = CrashReporter(
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
    testDeviceIds: _resolveAdTestDeviceIds(environment),
  );

  await adService.initialize();
  _logAdMobIdWarningsIfAny(environment);
  await consentController.refreshConsent();

  runZonedGuarded(
    () {
      runApp(
        SaverQuestApp(
          dependencies: AppDependencies(
            environment: environment,
            adGuardrails: adGuardrails,
            adService: adService,
            analyticsService: analyticsService,
            remoteConfigService: remoteConfigService,
            consentController: consentController,
            attTransparencyService: attTransparencyService,
            localeController: localeController,
            crashReporter: crashReporter,
          ),
        ),
      );
    },
    (error, stack) {
      crashReporter.recordNonFatal(error, stack);
    },
  );
}

Future<bool> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (error) {
    developer.log(
      '[firebase] initialize failed. continue without firebase: $error',
    );
    return false;
  }
}

List<String> _resolveAdTestDeviceIds(AppEnvironment environment) {
  if (environment.isProd) {
    return const [];
  }

  const raw = String.fromEnvironment('ADMOB_TEST_DEVICE_IDS', defaultValue: '');
  return raw
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

void _logAdMobIdWarningsIfAny(AppEnvironment environment) {
  if (!environment.isProd) {
    return;
  }

  final warnings = AdMobIds.productionReadinessWarnings();
  for (final warning in warnings) {
    developer.log('[admob] $warning');
  }
}
