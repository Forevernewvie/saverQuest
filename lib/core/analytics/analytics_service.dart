import 'package:firebase_analytics/firebase_analytics.dart';

import '../logging/app_logger.dart';

class AnalyticsService {
  /// Creates an analytics service with optional Firebase backing.
  AnalyticsService({
    required AppLogger logger,
    FirebaseAnalytics? firebaseAnalytics,
  }) : _logger = logger,
       _firebaseAnalytics = firebaseAnalytics;

  final AppLogger _logger;
  final FirebaseAnalytics? _firebaseAnalytics;

  /// Stores the active environment so telemetry can be segmented safely.
  Future<void> setEnvironment(String environmentName) async {
    _logger.info(
      'Analytics environment updated.',
      scope: 'analytics',
      metadata: {'environment': environmentName},
    );
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.setUserProperty(
      name: 'app_environment',
      value: environmentName,
    );
  }

  /// Records a screen view with a consistent logging trail.
  Future<void> logScreen(String screenName) async {
    _logger.debug(
      'Screen view tracked.',
      scope: 'analytics',
      metadata: {'screen': screenName},
    );
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.logScreenView(screenName: screenName);
  }

  /// Records a named analytics event with optional structured parameters.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    _logger.debug(
      'Analytics event tracked.',
      scope: 'analytics',
      metadata: {'event': name, 'parameters': parameters ?? const {}},
    );
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.logEvent(name: name, parameters: parameters);
  }
}
