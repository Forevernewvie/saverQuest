import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/app/app.dart';
import 'package:flutter_saverquest_mvp/app/app_dependencies.dart';
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
import 'package:flutter_saverquest_mvp/core/ledger/ledger_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_month_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_presentation_service.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_view_data_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class _TestConsentController extends ConsentController {
  _TestConsentController({
    required super.analyticsService,
    required super.logger,
    required ConsentState state,
  }) : _state = state;

  final ConsentState _state;
  int refreshCalls = 0;
  int gatherCalls = 0;
  bool throwOnFirstRefresh = false;

  @override
  ConsentState get state => _state;

  @override
  Future<void> refreshConsent() async {
    refreshCalls += 1;
    if (throwOnFirstRefresh && refreshCalls == 1) {
      throw StateError('network unavailable');
    }
  }

  @override
  Future<void> gatherConsentIfRequired() async {
    gatherCalls += 1;
  }
}

class _TestAttTransparencyService extends AttTransparencyService {
  _TestAttTransparencyService({required super.analyticsService});

  int requestCalls = 0;

  @override
  Future<void> requestIfNeeded() async {
    requestCalls += 1;
  }
}

/// Builds onboarding dependencies with observable consent and ATT doubles.
Future<
  ({
    AppDependencies dependencies,
    _TestConsentController consentController,
    _TestAttTransparencyService attService,
  })
>
_buildDependencies({ConsentState? consentState}) async {
  final logger = FakeLogger();
  final analytics = AnalyticsService(logger: logger);
  final localeController = AppLocaleController(storage: FakeLocaleStorage());
  await localeController.setLocale(const Locale('ko'));

  final consentController = _TestConsentController(
    analyticsService: analytics,
    logger: logger,
    state: consentState ?? ConsentState.initial(),
  );
  final attService = _TestAttTransparencyService(analyticsService: analytics);

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
      attTransparencyService: attService,
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
    attService: attService,
  );
}

void main() {
  testWidgets('bootstraps consent flow once on first render', (tester) async {
    final context = await _buildDependencies();

    await tester.pumpWidget(SaverQuestApp(dependencies: context.dependencies));
    await tester.pumpAndSettle();

    expect(context.consentController.refreshCalls, 1);
    expect(context.consentController.gatherCalls, 1);
    expect(context.attService.requestCalls, 1);
    expect(find.text('SaverQuest 시작하기'), findsOneWidget);
    expect(find.text('시작 전에 필요한 설정만 확인할게요'), findsOneWidget);
  });

  testWidgets('navigates to home when continue is tapped', (tester) async {
    final context = await _buildDependencies(
      consentState: const ConsentState(
        initialized: true,
        canRequestAds: true,
        serveNonPersonalizedAds: false,
        privacyOptionsRequired: false,
      ),
    );

    await tester.pumpWidget(SaverQuestApp(dependencies: context.dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.text('계속하기'));
    await tester.pumpAndSettle();

    expect(find.text('가계부 홈'), findsOneWidget);
  });

  testWidgets(
    'recovers from bootstrap failure without leaving onboarding stuck',
    (tester) async {
      final context = await _buildDependencies();
      context.consentController.throwOnFirstRefresh = true;

      await tester.pumpWidget(
        SaverQuestApp(dependencies: context.dependencies),
      );
      await tester.pumpAndSettle();

      expect(find.text('준비 중...'), findsNothing);

      await tester.tap(find.text('계속하기'));
      await tester.pumpAndSettle();

      expect(context.consentController.refreshCalls, 2);
      expect(find.text('가계부 홈'), findsOneWidget);
    },
  );
}
