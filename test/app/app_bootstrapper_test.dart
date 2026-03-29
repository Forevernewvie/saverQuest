import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_saverquest_mvp/app/app_bootstrapper.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_guardrails.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_placement.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_result.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_service.dart';
import 'package:flutter_saverquest_mvp/core/analytics/analytics_service.dart';
import 'package:flutter_saverquest_mvp/core/config/app_environment.dart';
import 'package:flutter_saverquest_mvp/core/config/app_runtime_options.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_platform.dart';
import 'package:flutter_saverquest_mvp/core/logging/app_logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SilentLogger implements AppLogger {
  @override
  void debug(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void info(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void warning(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}
}

class _HangingConsentPlatform implements ConsentPlatform {
  @override
  Future<bool> canRequestAds() async => false;

  @override
  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus()
    async => PrivacyOptionsRequirementStatus.notRequired;

  @override
  void loadAndShowConsentFormIfRequired(
    void Function(FormError? error) onDone,
  ) {}

  @override
  void requestConsentInfoUpdate({
    required void Function() onConsentInfoUpdateSuccess,
    required void Function(FormError error) onConsentInfoUpdateFailure,
  }) {}

  @override
  Future<void> showPrivacyOptionsForm(void Function(FormError? error) onDone)
    async {}
}

class _NoopAdService implements AdService {
  @override
  BannerAd? buildBannerAd({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
    required void Function(Ad ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<AdShowStatus> showInterstitial({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async => AdShowStatus.blockedUnsupportedPlatform;

  @override
  Future<RewardedAdResult> showRewarded({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async => const RewardedAdResult(
    status: AdShowStatus.blockedUnsupportedPlatform,
    rewardEarned: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runtimeOptions = AppRuntimeOptions(
    environment: AppEnvironment.dev,
    adTestDeviceIds: [],
    enableFirebase: false,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('bootstrap survives a hanging consent refresh', () async {
    final bootstrapper = AppBootstrapper(
      runtimeOptions: runtimeOptions,
      logger: _SilentLogger(),
      consentPlatform: _HangingConsentPlatform(),
      adServiceFactory: ({
        required AnalyticsService analyticsService,
        required AppLogger logger,
        required AdGuardrails guardrails,
        required List<String> testDeviceIds,
      }) => _NoopAdService(),
      startupTimeout: const Duration(milliseconds: 10),
    );

    final dependencies = await bootstrapper.bootstrap();

    expect(dependencies.consentController.state.initialized, isTrue);
    expect(
      dependencies.consentController.state.errorMessage,
      contains('Consent operation timed out: refresh_consent'),
    );
  });

  test('bootstrap falls back when shared preferences never resolve', () async {
    final bootstrapper = AppBootstrapper(
      runtimeOptions: runtimeOptions,
      logger: _SilentLogger(),
      sharedPreferencesFactory: () => Completer<SharedPreferences>().future,
      consentPlatform: _HangingConsentPlatform(),
      adServiceFactory: ({
        required AnalyticsService analyticsService,
        required AppLogger logger,
        required AdGuardrails guardrails,
        required List<String> testDeviceIds,
      }) => _NoopAdService(),
      startupTimeout: const Duration(milliseconds: 10),
    );

    final dependencies = await bootstrapper.bootstrap();

    expect(dependencies.ledgerController.initialized, isTrue);
    expect(dependencies.ledgerController.monthlyBudgetAmount, 350000);
    expect(dependencies.localeController.locale, isNull);
  });
}
