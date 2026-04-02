import 'dart:async';

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
import 'package:flutter_saverquest_mvp/core/ledger/ledger_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_month_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_presentation_service.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_view_data_factory.dart';
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
    this.onShowPrivacyOptionsForm,
  }) : _state = state;

  final ConsentState _state;
  final Future<void> Function()? onShowPrivacyOptionsForm;
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
    await onShowPrivacyOptionsForm?.call();
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
      ledgerController: LedgerController(
        repository: InMemoryLedgerRepository(
          snapshot: const LedgerSnapshot(
            entries: [],
            monthlyBudgetAmount: 350000,
          ),
        ),
        logger: logger,
      ),
      ledgerMonthController: LedgerMonthController(
        initialMonth: DateTime.now(),
      ),
      ledgerPresentationService: const LedgerPresentationService(),
      ledgerViewDataFactory: const LedgerViewDataFactory(),
      logger: logger,
    ),
    consentController: consentController,
  );
}

Future<
  ({AppDependencies dependencies, _TestConsentController consentController})
>
_buildDependenciesWithHandler({
  required ConsentState consentState,
  Future<void> Function()? onShowPrivacyOptionsForm,
}) async {
  final logger = FakeLogger();
  final analytics = AnalyticsService(logger: logger);
  final localeController = AppLocaleController(storage: FakeLocaleStorage());
  await localeController.setLocale(const Locale('ko'));

  final consentController = _TestConsentController(
    analyticsService: analytics,
    logger: logger,
    state: consentState,
    onShowPrivacyOptionsForm: onShowPrivacyOptionsForm,
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
      ledgerController: LedgerController(
        repository: InMemoryLedgerRepository(
          snapshot: const LedgerSnapshot(
            entries: [],
            monthlyBudgetAmount: 350000,
          ),
        ),
        logger: logger,
      ),
      ledgerMonthController: LedgerMonthController(
        initialMonth: DateTime.now(),
      ),
      ledgerPresentationService: const LedgerPresentationService(),
      ledgerViewDataFactory: const LedgerViewDataFactory(),
      logger: logger,
    ),
    consentController: consentController,
  );
}

void main() {
  Finder currencyDropdown() {
    return find.byWidgetPredicate(
      (widget) => widget is DropdownButton<LedgerCurrency>,
      description: 'currency dropdown',
    );
  }

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
    expect(find.text('기본 통화'), findsOneWidget);
    expect(find.text('원화 (KRW)'), findsOneWidget);
    expect(find.text('동의 철회/재설정을 즉시 반영합니다.'), findsOneWidget);
    expect(
      find.text('현재 개인정보 설정이 적용되어 있습니다. 필요하면 아래에서 언제든 변경할 수 있어요.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a warning dialog before changing the base currency', (
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

    final currencyDropdownWidget = tester
        .widget<DropdownButton<LedgerCurrency>>(currencyDropdown());
    currencyDropdownWidget.onChanged!.call(LedgerCurrency.usd);
    await tester.pumpAndSettle();

    expect(find.text('기본 통화를 변경할까요?'), findsOneWidget);
    expect(find.textContaining('기존 금액은 자동 환산되지 않으며'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '변경하기'));
    await tester.pumpAndSettle();

    expect(context.dependencies.ledgerController.currency, LedgerCurrency.usd);
    expect(find.textContaining('달러 (USD)로 변경했습니다'), findsOneWidget);
  });

  testWidgets('keeps the current currency when the dialog is cancelled', (
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

    final currencyDropdownWidget = tester
        .widget<DropdownButton<LedgerCurrency>>(currencyDropdown());
    currencyDropdownWidget.onChanged!.call(LedgerCurrency.jpy);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();

    expect(context.dependencies.ledgerController.currency, LedgerCurrency.krw);
    expect(find.text('기본 통화를 변경할까요?'), findsNothing);
  });

  testWidgets('hides the privacy options card when it is not required', (
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

    expect(context.consentController.showPrivacyOptionsCalls, 0);
    expect(find.text('개인정보 설정 변경'), findsNothing);
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

    final privacyPolicyCard = find.ancestor(
      of: find.text('개인정보 처리방침'),
      matching: find.byType(InkWell),
    );
    await tester.scrollUntilVisible(
      privacyPolicyCard,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final privacyPolicyInkWell = tester.widget<InkWell>(privacyPolicyCard);
    privacyPolicyInkWell.onTap!.call();
    await tester.pumpAndSettle();

    expect(find.text('How the app handles information'), findsNothing);
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

  testWidgets('restores the privacy options control when the dialog throws', (
    tester,
  ) async {
    final error = StateError('privacy dialog failed');
    final dialogCompleter = Completer<void>();
    final context = await _buildDependenciesWithHandler(
      consentState: const ConsentState(
        initialized: true,
        canRequestAds: true,
        serveNonPersonalizedAds: false,
        privacyOptionsRequired: true,
      ),
      onShowPrivacyOptionsForm: () => dialogCompleter.future,
    );

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: SettingsPage(dependencies: context.dependencies),
      ),
    );
    await tester.pumpAndSettle();

    final privacyOptionsCard = find.ancestor(
      of: find.text('개인정보 설정 변경'),
      matching: find.byType(InkWell),
    );
    await tester.scrollUntilVisible(
      privacyOptionsCard,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final privacyOptionsInkWell = tester.widget<InkWell>(privacyOptionsCard);
    privacyOptionsInkWell.onTap!.call();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    dialogCompleter.completeError(error);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
  });
}
