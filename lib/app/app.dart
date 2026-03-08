import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/app_localizations.dart';
import '../core/design/app_theme.dart';
import '../features/home/home_page.dart';
import '../features/insights/insights_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/report/report_page.dart';
import '../features/settings/privacy_policy_page.dart';
import '../features/settings/settings_page.dart';
import '../features/tool/tool_page.dart';
import 'app_dependencies.dart';
import 'routes.dart';

class SaverQuestApp extends StatelessWidget {
  const SaverQuestApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dependencies.localeController,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: dependencies.localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.onboarding,
          routes: {
            AppRoutes.onboarding: (_) =>
                OnboardingPage(dependencies: dependencies),
            AppRoutes.home: (_) => HomePage(dependencies: dependencies),
            AppRoutes.tool: (_) => ToolPage(dependencies: dependencies),
            AppRoutes.report: (_) => ReportPage(dependencies: dependencies),
            AppRoutes.insights: (_) => InsightsPage(dependencies: dependencies),
            AppRoutes.settings: (_) => SettingsPage(dependencies: dependencies),
            AppRoutes.privacyPolicy: (_) => const PrivacyPolicyPage(),
          },
        );
      },
    );
  }
}
