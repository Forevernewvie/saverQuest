import 'dart:developer' as developer;

/// Defines the supported log severity levels.
enum AppLogLevel { debug, info, warning, error }

/// Provides a test-friendly logging contract for application services.
abstract class AppLogger {
  /// Writes a debug-level message for local diagnostics.
  void debug(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  });

  /// Writes an info-level message for normal runtime events.
  void info(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  });

  /// Writes a warning-level message for recoverable anomalies.
  void warning(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  });

  /// Writes an error-level message for failures and unexpected states.
  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  });
}

/// Emits sanitized runtime logs through `dart:developer`.
class DeveloperAppLogger implements AppLogger {
  /// Creates a logger that can suppress verbose logs in production.
  const DeveloperAppLogger({required this.enableDebugLogs});

  final bool enableDebugLogs;

  static const Set<String> _sensitiveKeys = {
    'authorization',
    'password',
    'secret',
    'token',
  };

  @override
  void debug(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {
    if (!enableDebugLogs) {
      return;
    }
    _write(
      level: AppLogLevel.debug,
      scope: scope,
      message: message,
      metadata: metadata,
    );
  }

  @override
  void info(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {
    _write(
      level: AppLogLevel.info,
      scope: scope,
      message: message,
      metadata: metadata,
    );
  }

  @override
  void warning(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {
    _write(
      level: AppLogLevel.warning,
      scope: scope,
      message: message,
      metadata: metadata,
    );
  }

  @override
  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {
    _write(
      level: AppLogLevel.error,
      scope: scope,
      message: message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Serializes and redacts metadata before it reaches the device logs.
  void _write({
    required AppLogLevel level,
    required String scope,
    required String message,
    required Map<String, Object?> metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[${level.name}] $message | ${_sanitizeMetadata(metadata)}',
      name: 'SaverQuest.$scope',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Removes sensitive values from structured logs to reduce leakage risk.
  Map<String, Object?> _sanitizeMetadata(Map<String, Object?> metadata) {
    final sanitized = <String, Object?>{};
    metadata.forEach((key, value) {
      sanitized[key] = _sensitiveKeys.contains(key.toLowerCase())
          ? '<redacted>'
          : value;
    });
    return sanitized;
  }
}

