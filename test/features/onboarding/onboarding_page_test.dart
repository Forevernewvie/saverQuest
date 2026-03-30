import 'dart:async';

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
    this.onRefreshConsent,
    this.onGatherConsentIfRequired,
  }) : _state = state;

  final ConsentState _state;
  final Future<void> Function()? onRefreshConsent;
  final Future<void> Function()? onGatherConsentIfRequired;
  int refreshCalls = 0;
  int gatherCalls = 0;

  @override
  ConsentState get state => _state;

  @override
  Future<void> refreshConsent() async {
    refreshCalls += 1;
    await onRefreshConsent?.call();
  }

  @override
  Future<void> gatherConsentIfRequired() async {
    gatherCalls += 1;
    await onGatherConsentIfRequired?.call();
  }
}

class _TestAttTransparencyService extends AttTransparencyService {
  _TestAttTransparencyService({
    required super.analyticsService,
    this.onRequestIfNeeded,
  });

  final Future<void> Function()? onRequestIfNeeded;
  int requestCalls = 0;

  @override
  Future<void> requestIfNeeded() async {
    requestCalls += 1;
    await onRequestIfNeeded?.call();
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

Future<
  ({
    AppDependencies dependencies,
    _TestConsentController consentController,
    _TestAttTransparencyService attService,
  })
>
_buildDependenciesWithHandlers({
  ConsentState? consentState,
  Future<void> Function()? onRefreshConsent,
  Future<void> Function()? onGatherConsentIfRequired,
  Future<void> Function()? onRequestIfNeeded,
}) async {
  final logger = FakeLogger();
  final analytics = AnalyticsService(logger: logger);
  final localeController = AppLocaleController(storage: FakeLocaleStorage());
  await localeController.setLocale(const Locale('ko'));

  final consentController = _TestConsentController(
    analyticsService: analytics,
    logger: logger,
    state: consentState ?? ConsentState.initial(),
    onRefreshConsent: onRefreshConsent,
    onGatherConsentIfRequired: onGatherConsentIfRequired,
  );
  final attService = _TestAttTransparencyService(
    analyticsService: analytics,
    onRequestIfNeeded: onRequestIfNeeded,
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
    expect(find.text('SaverQuest 시작하기'), findsNothing);
    expect(find.text('필요한 설정만 확인하고 시작할게요'), findsOneWidget);
    expect(find.text('먼저 알아두세요'), findsNothing);
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

  testWidgets('restores onboarding actions when consent bootstrap throws', (
    tester,
  ) async {
    final error = StateError('consent refresh failed');
    final refreshCompleter = Completer<void>();
    final context = await _buildDependenciesWithHandlers(
      onRefreshConsent: () => refreshCompleter.future,
    );

    await tester.pumpWidget(SaverQuestApp(dependencies: context.dependencies));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, '계속하기'), findsNothing);
    expect(find.text('준비 중...'), findsOneWidget);

    refreshCompleter.completeError(error);
    await tester.pump();

    expect(find.widgetWithText(FilledButton, '계속하기'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '나중에 설정에서 변경'), findsOneWidget);
    expect(find.text('준비 중...'), findsNothing);
  });
}
