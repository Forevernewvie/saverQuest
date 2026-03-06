import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import 'consent_platform.dart';
import 'consent_state.dart';

class ConsentController extends ChangeNotifier {
  ConsentController({
    required AnalyticsService analyticsService,
    ConsentPlatform consentPlatform = const GoogleMobileAdsConsentPlatform(),
  }) : _analyticsService = analyticsService,
       _consentPlatform = consentPlatform;

  final AnalyticsService _analyticsService;
  final ConsentPlatform _consentPlatform;

  ConsentState _state = ConsentState.initial();
  ConsentState get state => _state;

  Future<void> refreshConsent() async {
    final completer = Completer<void>();

    try {
      _consentPlatform.requestConsentInfoUpdate(
        onConsentInfoUpdateSuccess: () async {
          await _syncStateFromSdk();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onConsentInfoUpdateFailure: (FormError error) async {
          await _syncStateFromSdk(errorMessage: error.message);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (error) {
      await _syncStateFromSdk(errorMessage: error.toString());
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
  }

  Future<void> gatherConsentIfRequired() async {
    final completer = Completer<void>();

    try {
      _consentPlatform.loadAndShowConsentFormIfRequired((
        FormError? error,
      ) async {
        await _syncStateFromSdk(errorMessage: error?.message);
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    } catch (error) {
      await _syncStateFromSdk(errorMessage: error.toString());
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
    await _logConsentUpdatedEvent();
  }

  Future<void> showPrivacyOptionsForm() async {
    await _consentPlatform.showPrivacyOptionsForm((FormError? error) async {
      await _syncStateFromSdk(errorMessage: error?.message);
      await _logConsentUpdatedEvent();
    });
  }

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
