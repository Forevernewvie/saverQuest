import 'package:flutter_saverquest_mvp/core/config/app_environment.dart';
import 'package:flutter_saverquest_mvp/core/config/app_runtime_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses non-production test device ids from raw environment values', () {
    final options = AppRuntimeOptions.fromEnvironment(
      environmentRaw: 'stage',
      adMobTestDeviceIdsRaw: 'abc, def ,,ghi ',
    );

    expect(options.environment, AppEnvironment.stage);
    expect(options.adTestDeviceIds, ['abc', 'def', 'ghi']);
  });

  test('strips test device ids in production', () {
    final options = AppRuntimeOptions.fromEnvironment(
      environmentRaw: 'prod',
      adMobTestDeviceIdsRaw: 'abc,def',
    );

    expect(options.environment, AppEnvironment.prod);
    expect(options.adTestDeviceIds, isEmpty);
  });
}

