import 'package:flutter_saverquest_mvp/app/app_dependencies.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_guardrails.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_placement.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_result.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_service.dart';
import 'package:flutter_saverquest_mvp/core/analytics/analytics_service.dart';
import 'package:flutter_saverquest_mvp/core/config/app_environment.dart';
import 'package:flutter_saverquest_mvp/core/config/remote_config_service.dart';
import 'package:flutter_saverquest_mvp/core/content/app_content_repository.dart';
import 'package:flutter_saverquest_mvp/core/consent/att_transparency_service.dart';
import 'package:flutter_saverquest_mvp/core/consent/consent_controller.dart';
import 'package:flutter_saverquest_mvp/core/crash/crash_reporter.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_locale_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_month_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_presentation_service.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_repository.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_view_data_factory.dart';
import 'package:flutter_saverquest_mvp/core/logging/app_logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FakeAdService implements AdService {
  @override
  BannerAd? buildBannerAd({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
    required void Function(Ad ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return null;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<AdShowStatus> showInterstitial({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async {
    return AdShowStatus.shown;
  }

  @override
  Future<RewardedAdResult> showRewarded({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async {
    return const RewardedAdResult(
      status: AdShowStatus.shown,
      rewardEarned: true,
    );
  }
}

class FakeConsentController extends ConsentController {
  FakeConsentController({
    required super.analyticsService,
    required super.logger,
  });

  @override
  Future<void> refreshConsent() async {}

  @override
  Future<void> gatherConsentIfRequired() async {}

  @override
  Future<void> showPrivacyOptionsForm() async {}
}

class FakeAttTransparencyService extends AttTransparencyService {
  FakeAttTransparencyService({required super.analyticsService});

  @override
  Future<void> requestIfNeeded() async {}
}

class FakeLocaleStorage implements LocaleStorage {
  FakeLocaleStorage({this.localeCode});

  String? localeCode;

  @override
  Future<String?> loadLocaleCode() async => localeCode;

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    this.localeCode = localeCode;
  }
}

class FakeLogger implements AppLogger {
  @override
  void debug(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void error(
    String message, {
    String scope = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void info(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}

  @override
  void warning(
    String message, {
    String scope = 'app',
    Map<String, Object?> metadata = const {},
  }) {}
}

class InMemoryLedgerRepository implements LedgerRepository {
  InMemoryLedgerRepository({required LedgerSnapshot snapshot})
    : _snapshot = snapshot;

  LedgerSnapshot _snapshot;

  @override
  Future<LedgerSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> saveSnapshot(LedgerSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

AppDependencies buildFakeDependencies() {
  return buildFakeDependenciesWithSnapshot(
    LedgerSnapshot(
      monthlyBudgetAmount: 420000,
      entries: [
        LedgerEntry(
          id: 'seed-1',
          type: LedgerEntryType.income,
          category: LedgerCategory.salary,
          amount: 2400000,
          note: 'Salary',
          occurredOn: DateTime.now().subtract(const Duration(days: 2)),
        ),
        LedgerEntry(
          id: 'seed-2',
          type: LedgerEntryType.expense,
          category: LedgerCategory.groceries,
          amount: 54000,
          note: 'Mart',
          occurredOn: DateTime.now().subtract(const Duration(days: 1)),
        ),
        LedgerEntry(
          id: 'seed-3',
          type: LedgerEntryType.expense,
          category: LedgerCategory.coffee,
          amount: 4500,
          note: 'Coffee',
          occurredOn: DateTime.now(),
        ),
        LedgerEntry(
          id: 'seed-4',
          type: LedgerEntryType.expense,
          category: LedgerCategory.transport,
          amount: 18000,
          note: 'Transit',
          occurredOn: DateTime.now(),
        ),
      ],
    ),
  );
}

/// Builds test dependencies with a caller-provided ledger snapshot.
AppDependencies buildFakeDependenciesWithSnapshot(LedgerSnapshot snapshot) {
  final logger = FakeLogger();
  final analytics = AnalyticsService(logger: logger);
  final localeController = AppLocaleController(storage: FakeLocaleStorage());
  final ledgerController = LedgerController(
    repository: InMemoryLedgerRepository(snapshot: snapshot),
    initialSnapshot: snapshot,
    logger: logger,
  );
  return AppDependencies(
    environment: AppEnvironment.dev,
    adGuardrails: AdGuardrails(
      interstitialInterval: 3,
      interstitialCooldownSec: 45,
      rewardedDailyCap: 2,
    ),
    adService: FakeAdService(),
    analyticsService: analytics,
    remoteConfigService: RemoteConfigService(logger: logger),
    consentController: FakeConsentController(
      analyticsService: analytics,
      logger: logger,
    ),
    attTransparencyService: FakeAttTransparencyService(
      analyticsService: analytics,
    ),
    localeController: localeController,
    crashReporter: CrashReporter(logger: logger),
    contentRepository: const StaticAppContentRepository(),
    ledgerController: ledgerController,
    ledgerMonthController: LedgerMonthController(initialMonth: DateTime.now()),
    ledgerPresentationService: const LedgerPresentationService(),
    ledgerViewDataFactory: const LedgerViewDataFactory(),
    logger: logger,
  );
}
