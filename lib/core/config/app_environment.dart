enum AppEnvironment { dev, stage, prod }

extension AppEnvironmentX on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.dev:
        return 'dev';
      case AppEnvironment.stage:
        return 'stage';
      case AppEnvironment.prod:
        return 'prod';
    }
  }

  bool get isProd => this == AppEnvironment.prod;
}

/// Resolves an application environment from a raw string value.
AppEnvironment appEnvironmentFromRaw(String env) {
  switch (env) {
    case 'prod':
      return AppEnvironment.prod;
    case 'stage':
      return AppEnvironment.stage;
    default:
      return AppEnvironment.dev;
  }
}

/// Resolves the application environment from compile-time variables.
AppEnvironment appEnvironmentFromDefine() {
  const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return appEnvironmentFromRaw(env);
}
