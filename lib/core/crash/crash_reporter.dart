import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

class CrashReporter {
  /// Creates a crash reporter with optional Firebase Crashlytics forwarding.
  CrashReporter({required AppLogger logger, FirebaseCrashlytics? crashlytics})
    : _logger = logger,
      _crashlytics = crashlytics;

  final AppLogger _logger;
  final FirebaseCrashlytics? _crashlytics;

  /// Installs global handlers for framework and platform-level uncaught errors.
  Future<void> installGlobalHandlers() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.error(
        'Flutter framework error captured.',
        scope: 'crash',
        error: details.exception,
        stackTrace: details.stack,
      );
      if (_crashlytics != null) {
        unawaited(_crashlytics.recordFlutterFatalError(details));
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.error(
        'Platform error captured.',
        scope: 'crash',
        error: error,
        stackTrace: stack,
      );
      if (_crashlytics != null) {
        unawaited(_crashlytics.recordError(error, stack, fatal: true));
      }
      return true;
    };
  }

  /// Records non-fatal exceptions so recoverable issues remain observable.
  Future<void> recordNonFatal(Object error, StackTrace stackTrace) async {
    _logger.error(
      'Non-fatal error captured.',
      scope: 'crash',
      error: error,
      stackTrace: stackTrace,
    );
    if (_crashlytics != null) {
      await _crashlytics.recordError(error, stackTrace, fatal: false);
    }
  }
}
