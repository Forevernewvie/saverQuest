import 'app_environment.dart';

/// Captures environment-derived startup options in a testable object.
class AppRuntimeOptions {
  /// Creates runtime options from explicit values.
  const AppRuntimeOptions({
    required this.environment,
    required this.adTestDeviceIds,
    required this.enableFirebase,
  });

  final AppEnvironment environment;
  final List<String> adTestDeviceIds;
  final bool enableFirebase;

  /// Parses startup options from compile-time environment variables.
  factory AppRuntimeOptions.fromEnvironment({
    String environmentRaw = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    ),
    String adMobTestDeviceIdsRaw = const String.fromEnvironment(
      'ADMOB_TEST_DEVICE_IDS',
      defaultValue: '',
    ),
    String enableFirebaseRaw = const String.fromEnvironment(
      'ENABLE_FIREBASE',
      defaultValue: '',
    ),
  }) {
    final environment = appEnvironmentFromRaw(environmentRaw);
    return AppRuntimeOptions(
      environment: environment,
      adTestDeviceIds: _parseAdTestDeviceIds(
        rawIds: adMobTestDeviceIdsRaw,
        environment: environment,
      ),
      enableFirebase: _parseEnableFirebase(
        rawValue: enableFirebaseRaw,
        environment: environment,
      ),
    );
  }

  /// Normalizes the raw test-device string into a stable list.
  static List<String> _parseAdTestDeviceIds({
    required String rawIds,
    required AppEnvironment environment,
  }) {
    if (environment.isProd) {
      return const [];
    }

    return rawIds
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static bool _parseEnableFirebase({
    required String rawValue,
    required AppEnvironment environment,
  }) {
    final normalized = rawValue.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return environment.isProd;
  }
}
