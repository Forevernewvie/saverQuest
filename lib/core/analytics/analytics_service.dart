import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? firebaseAnalytics})
    : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics? _firebaseAnalytics;

  Future<void> setEnvironment(String environmentName) async {
    developer.log('[analytics] env=$environmentName');
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.setUserProperty(
      name: 'app_environment',
      value: environmentName,
    );
  }

  Future<void> logScreen(String screenName) async {
    developer.log('[analytics] screen_view: $screenName');
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    developer.log('[analytics] event: $name | $parameters');
    if (_firebaseAnalytics == null) {
      return;
    }

    await _firebaseAnalytics.logEvent(name: name, parameters: parameters);
  }
}
