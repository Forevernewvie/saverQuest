import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_bootstrapper.dart';
import 'core/config/app_environment.dart';
import 'core/config/app_runtime_options.dart';
import 'core/logging/app_logger.dart';

/// Boots the application with fully initialized dependencies.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final runtimeOptions = AppRuntimeOptions.fromEnvironment();
  final logger = DeveloperAppLogger(
    enableDebugLogs: !runtimeOptions.environment.isProd,
  );
  final bootstrapper = AppBootstrapper(
    runtimeOptions: runtimeOptions,
    logger: logger,
  );
  final dependencies = await bootstrapper.bootstrap();

  runZonedGuarded(
    () {
      runApp(
        SaverQuestApp(
          dependencies: dependencies,
        ),
      );
    },
    (error, stack) {
      dependencies.crashReporter.recordNonFatal(error, stack);
    },
  );
}
