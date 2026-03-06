import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_saverquest_mvp/core/analytics/analytics_events.dart';
import 'package:flutter_saverquest_mvp/core/analytics/analytics_service.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_controller.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_platform.dart';
import 'package:flutter_saverquest_mvp/core/logging/app_logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _FakeAnalyticsService extends AnalyticsService {
  _FakeAnalyticsService() : super(logger: _SilentLogger());

  final List<Map<String, Object?>> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add({'name': name, 'parameters': parameters});
  }
}

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

class _FakeConsentPlatform implements ConsentPlatform {
  bool canRequestAdsValue = false;
  PrivacyOptionsRequirementStatus privacyStatus =
      PrivacyOptionsRequirementStatus.notRequired;
  FormError? refreshFailure;
  FormError? gatherError;

  @override
  Future<bool> canRequestAds() async => canRequestAdsValue;

  @override
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async {
    return privacyStatus;
  }

  @override
  void loadAndShowConsentFormIfRequired(
    void Function(FormError? error) onDone,
  ) {
    onDone(gatherError);
  }

  @override
  void requestConsentInfoUpdate({
    required void Function() onConsentInfoUpdateSuccess,
    required void Function(FormError error) onConsentInfoUpdateFailure,
  }) {
    if (refreshFailure != null) {
      onConsentInfoUpdateFailure(refreshFailure!);
      return;
    }
    onConsentInfoUpdateSuccess();
  }

  @override
  Future<void> showPrivacyOptionsForm(
    void Function(FormError? error) onDone,
  ) async {
    onDone(null);
  }
}

void main() {
  test('refreshConsent updates state on success', () async {
    final analytics = _FakeAnalyticsService();
    final platform = _FakeConsentPlatform()
      ..canRequestAdsValue = true
      ..privacyStatus = PrivacyOptionsRequirementStatus.required;

    final controller = ConsentController(
      analyticsService: analytics,
      consentPlatform: platform,
    );

    await controller.refreshConsent();

    expect(controller.state.initialized, isTrue);
    expect(controller.state.canRequestAds, isTrue);
    expect(controller.state.serveNonPersonalizedAds, isFalse);
    expect(controller.state.privacyOptionsRequired, isTrue);
    expect(controller.state.errorMessage, isNull);
  });

  test('refreshConsent keeps SDK cached consent when update fails', () async {
    final analytics = _FakeAnalyticsService();
    final platform = _FakeConsentPlatform()
      ..canRequestAdsValue = true
      ..privacyStatus = PrivacyOptionsRequirementStatus.notRequired
      ..refreshFailure = FormError(errorCode: 3, message: 'network down');

    final controller = ConsentController(
      analyticsService: analytics,
      consentPlatform: platform,
    );

    await controller.refreshConsent();

    expect(controller.state.initialized, isTrue);
    expect(controller.state.canRequestAds, isTrue);
    expect(controller.state.errorMessage, 'network down');
  });

  test(
    'gatherConsentIfRequired logs consent event with updated state',
    () async {
      final analytics = _FakeAnalyticsService();
      final platform = _FakeConsentPlatform()
        ..canRequestAdsValue = true
        ..privacyStatus = PrivacyOptionsRequirementStatus.required;

      final controller = ConsentController(
        analyticsService: analytics,
        consentPlatform: platform,
      );

      await controller.gatherConsentIfRequired();

      expect(analytics.events, isNotEmpty);
      final event = analytics.events.last;
      expect(event['name'], AnalyticsEvents.consentUpdated);

      final parameters = event['parameters']! as Map<String, Object>;
      expect(parameters['can_request_ads'], isTrue);
      expect(parameters['non_personalized'], isFalse);
      expect(parameters['privacy_options_required'], isTrue);
      expect(parameters['has_error'], isFalse);
    },
  );
}
