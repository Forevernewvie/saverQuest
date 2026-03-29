import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import '../logging/app_logger.dart';
import 'consent_platform.dart';
import 'consent_state.dart';

class ConsentController extends ChangeNotifier {
  /// Creates a consent controller with explicit analytics, logging, and platform access.
  ConsentController({
    required AnalyticsService analyticsService,
    required AppLogger logger,
    ConsentPlatform consentPlatform = const GoogleMobileAdsConsentPlatform(),
    Duration sdkFlowTimeout = const Duration(seconds: 5),
  }) : _analyticsService = analyticsService,
       _logger = logger,
       _consentPlatform = consentPlatform,
       _sdkFlowTimeout = sdkFlowTimeout;

  final AnalyticsService _analyticsService;
  final AppLogger _logger;
  final ConsentPlatform _consentPlatform;
  final Duration _sdkFlowTimeout;

  ConsentState _state = ConsentState.initial();
  ConsentState get state => _state;

  /// Refreshes consent metadata from the SDK and keeps cached state on failure.
  Future<void> refreshConsent() async {
    await _runSdkFlow(
      operation: 'refresh_consent',
      execute: (complete) {
        _consentPlatform.requestConsentInfoUpdate(
          onConsentInfoUpdateSuccess: () => complete(),
          onConsentInfoUpdateFailure: (FormError error) =>
              complete(error.message),
        );
      },
    );
  }

  /// Presents the consent form when required and records the final SDK state.
  Future<void> gatherConsentIfRequired() async {
    await _runSdkFlow(
      operation: 'gather_consent',
      execute: (complete) {
        _consentPlatform.loadAndShowConsentFormIfRequired(
          (FormError? error) => complete(error?.message),
        );
      },
    );
    await _logConsentUpdatedEvent();
  }

  /// Reopens privacy options and synchronizes the resulting SDK state.
  Future<void> showPrivacyOptionsForm() async {
    try {
      await _consentPlatform.showPrivacyOptionsForm((FormError? error) async {
        await _syncStateFromSdk(errorMessage: error?.message);
        await _logConsentUpdatedEvent();
      });
    } catch (error, stackTrace) {
      _logger.error(
        'Privacy options form failed.',
        scope: 'consent',
        error: error,
        stackTrace: stackTrace,
      );
      await _syncStateFromSdk(errorMessage: error.toString());
    }
  }

  /// Bridges callback-based SDK APIs into a single awaitable flow with logging.
  Future<void> _runSdkFlow({
    required String operation,
    required void Function(
      Future<void> Function([String? errorMessage]) complete,
    )
    execute,
  }) async {
    final completer = Completer<void>();
    final timeoutMessage = 'Consent operation timed out: $operation';

    Future<void> complete([String? errorMessage]) async {
      await _syncStateFromSdk(errorMessage: errorMessage);
      _logger.info(
        'Consent SDK flow completed.',
        scope: 'consent',
        metadata: {'operation': operation, 'hasError': errorMessage != null},
      );
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    try {
      execute(complete);
    } catch (error, stackTrace) {
      _logger.error(
        'Consent SDK flow threw an exception.',
        scope: 'consent',
        error: error,
        stackTrace: stackTrace,
        metadata: {'operation': operation},
      );
      await complete(error.toString());
    }

    await completer.future.timeout(
      _sdkFlowTimeout,
      onTimeout: () async {
        _logger.warning(
          'Consent SDK flow timed out.',
          scope: 'consent',
          metadata: {
            'operation': operation,
            'timeout_ms': _sdkFlowTimeout.inMilliseconds,
          },
        );
        await complete(timeoutMessage);
      },
    );
  }

  /// Synchronizes consent flags from the SDK while preserving safe fallbacks.
  Future<void> _syncStateFromSdk({String? errorMessage}) async {
    var canRequestAds = _state.canRequestAds;
    var privacyOptionsRequired = _state.privacyOptionsRequired;

    // Keep previous in-memory state if SDK lookups fail.
    try {
      canRequestAds = await _consentPlatform.canRequestAds();
    } catch (_) {}

    try {
      final privacyStatus = await _consentPlatform
          .getPrivacyOptionsRequirementStatus();
      privacyOptionsRequired =
          privacyStatus == PrivacyOptionsRequirementStatus.required;
    } catch (_) {}

    _state = _state.copyWith(
      initialized: true,
      canRequestAds: canRequestAds,
      serveNonPersonalizedAds: !canRequestAds,
      privacyOptionsRequired: privacyOptionsRequired,
      errorMessage: errorMessage,
    );
    notifyListeners();
  }

  /// Emits a normalized analytics event after a consent-changing operation.
  Future<void> _logConsentUpdatedEvent() async {
    await _analyticsService.logEvent(
      AnalyticsEvents.consentUpdated,
      parameters: {
        'can_request_ads': _state.canRequestAds,
        'non_personalized': _state.serveNonPersonalizedAds,
        'privacy_options_required': _state.privacyOptionsRequired,
        'has_error': _state.errorMessage != null,
      },
    );
  }
}
