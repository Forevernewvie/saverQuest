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

AppEnvironment appEnvironmentFromDefine() {
  const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  switch (env) {
    case 'prod':
      return AppEnvironment.prod;
    case 'stage':
      return AppEnvironment.stage;
    default:
      return AppEnvironment.dev;
  }
}
