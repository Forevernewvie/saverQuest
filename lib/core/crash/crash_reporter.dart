import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReporter {
  CrashReporter({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;

  Future<void> installGlobalHandlers() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log('[crash] FlutterError: ${details.exceptionAsString()}');
      if (_crashlytics != null) {
        unawaited(_crashlytics.recordFlutterFatalError(details));
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      developer.log('[crash] Platform error: $error');
      if (_crashlytics != null) {
        unawaited(_crashlytics.recordError(error, stack, fatal: true));
      }
      return true;
    };
  }

  Future<void> recordNonFatal(Object error, StackTrace stackTrace) async {
    developer.log('[crash] non fatal: $error');
    if (_crashlytics != null) {
      await _crashlytics.recordError(error, stackTrace, fatal: false);
    }
  }
}
