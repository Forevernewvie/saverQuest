import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_saverquest_mvp/app/app_dependencies.dart';
import 'package:flutter_saverquest_mvp/app/routes.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_guardrails.dart';
import 'package:flutter_saverquest_mvp/core/analytics/analytics_service.dart';
import 'package:flutter_saverquest_mvp/core/config/app_environment.dart';
import 'package:flutter_saverquest_mvp/core/config/remote_config_service.dart';
import 'package:flutter_saverquest_mvp/core/consent/att_transparency_service.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_controller.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_state.dart';
import 'package:flutter_saverquest_mvp/core/content/app_content_repository.dart';
import 'package:flutter_saverquest_mvp/core/crash/crash_reporter.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_locale_controller.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_saverquest_mvp/features/settings/privacy_policy_page.dart';
import 'package:flutter_saverquest_mvp/features/settings/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

class _TestConsentController extends ConsentController {
  _TestConsentController({
    required super.analyticsService,
    required super.logger,
    required ConsentState state,
  }) : _state = state;

  final ConsentState _state;
  int showPrivacyOptionsCalls = 0;

  @override
  ConsentState get state => _state;

  @override
  Future<void> refreshConsent() async {}

  @override
  Future<void> gatherConsentIfRequired() async {}

  @override
  Future<void> showPrivacyOptionsForm() async {
    showPrivacyOptionsCalls += 1;
  }
}

class _TestAttTransparencyService extends AttTransparencyService {
  _TestAttTransparencyService({required super.analyticsService});

  @override
  Future<void> requestIfNeeded() async {}
}

/// Builds settings dependencies with customizable consent state for widget tests.
Future<
  ({AppDependencies dependencies, _TestConsentController consentController})
>
_buildDependencies({required ConsentState consentState}) async {
  final logger = FakeLogger();
  final analytics = AnalyticsService(logger: logger);
  final localeController = AppLocaleController(storage: FakeLocaleStorage());
  await localeController.setLocale(const Locale('ko'));

  final consentController = _TestConsentController(
    analyticsService: analytics,
    logger: logger,
    state: consentState,
  );

  return (
    dependencies: AppDependencies(
      environment: AppEnvironment.dev,
      adGuardrails: AdGuardrails(
        interstitialInterval: 3,
        interstitialCooldownSec: 45,
        rewardedDailyCap: 2,
      ),
      adService: FakeAdService(),
      analyticsService: analytics,
      remoteConfigService: RemoteConfigService(logger: logger),
      consentController: consentController,
      attTransparencyService: _TestAttTransparencyService(
        analyticsService: analytics,
      ),
      localeController: localeController,
      crashReporter: CrashReporter(logger: logger),
      contentRepository: const StaticAppContentRepository(),
      logger: logger,
    ),
    consentController: consentController,
  );
}

void main() {
  testWidgets('renders privacy-ready copy when ad consent is active', (
    tester,
  ) async {
    final context = await _buildDependencies(
      consentState: const ConsentState(
        initialized: true,
        canRequestAds: true,
        serveNonPersonalizedAds: false,
        privacyOptionsRequired: true,
      ),
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: SettingsPage(dependencies: context.dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('개인정보 설정'), findsOneWidget);
    expect(find.text('동의 철회/재설정을 즉시 반영합니다.'), findsOneWidget);
    expect(
      find.text('현재 개인정보 설정이 적용되어 있습니다. 필요하면 아래에서 언제든 변경할 수 있어요.'),
      findsOneWidget,
    );
  });

  testWidgets('shows snackbar when privacy options are not required', (
    tester,
  ) async {
    final context = await _buildDependencies(
      consentState: const ConsentState(
        initialized: true,
        canRequestAds: false,
        serveNonPersonalizedAds: true,
        privacyOptionsRequired: false,
      ),
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: SettingsPage(dependencies: context.dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('개인정보 설정 변경'));
    await tester.pumpAndSettle();

    expect(context.consentController.showPrivacyOptionsCalls, 0);
    expect(find.text('현재는 추가로 바꿀 개인정보 옵션이 없습니다.'), findsOneWidget);
  });

  testWidgets('navigates to the privacy policy page from settings', (
    tester,
  ) async {
    final context = await _buildDependencies(
      consentState: const ConsentState(
        initialized: true,
        canRequestAds: true,
        serveNonPersonalizedAds: false,
        privacyOptionsRequired: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          '/': (_) => SettingsPage(dependencies: context.dependencies),
          AppRoutes.privacyPolicy: (_) => const PrivacyPolicyPage(),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('개인정보 처리방침'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('개인정보 처리방침'));
    await tester.pumpAndSettle();

    expect(find.text('앱에서 어떤 정보를 어떻게 다루는지 안내합니다'), findsOneWidget);
    expect(find.text('주요 정책 항목'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining(
        'https://forevernewvie.github.io/saverQuest/privacy/',
      ),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.textContaining(
        'https://forevernewvie.github.io/saverQuest/privacy/',
      ),
      findsOneWidget,
    );
  });
}
