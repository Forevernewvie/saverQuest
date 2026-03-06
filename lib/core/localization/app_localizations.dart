import 'package:flutter/widgets.dart';

import '../ads/ad_result.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('ko'), Locale('en')];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  bool get _isKorean => locale.languageCode == 'ko';

  String get appTitle => 'SaverQuest';

  String get retry => _t('다시 시도', 'Try again');
  String get noData => _t('데이터가 없습니다.', 'No data available.');
  String get adBannerPlaceholder => _t('배너 광고 자리', 'Ad banner slot');
  String get adDisabledRequiresConsent =>
      _t('광고 비활성 (동의 필요)', 'Ads disabled (consent required)');
  String get adBannerSemanticLabel => _t('광고 배너', 'Ad banner');

  String get homeTitle => _t('오늘의 절약 홈', 'Today\'s Savings Home');
  String get homeMissionTitle => _t('오늘의 미션', 'Today\'s Mission');
  String get homeMissionBody => _t(
    '커피 소비 1회 줄이기 · 예상 절약 4,500원',
    'Skip one coffee purchase · save KRW 4,500',
  );
  String get homeProgressTitle => _t('주간 진행률', 'Weekly Progress');
  String get homeProgressBody =>
      _t('68% (목표 80%) · 연속 7일 달성 중', '68% (goal 80%) · 7-day streak');
  String get homePrimaryAction => _t('지출 10초 기록', 'Log expense in 10 seconds');
  String get homePrimaryActionSemantic =>
      _t('지출 10초 기록 버튼', 'Log expense quickly button');
  String get homeSecondaryAction => _t('이번주 기록 보기', 'View this week\'s report');
  String get navTool => _t('도구', 'Tools');
  String get navReport => _t('리포트', 'Report');
  String get navInsights => _t('인사이트', 'Insights');

  String get insightsTitle => _t('인사이트 실험실', 'Insights Lab');
  String get insightsNoAdTitle => _t('광고 없는 분석 구간', 'No-Ad Analytics Zone');
  String get insightsNoAdBody => _t(
    '실험 분석 집중 구간이라 광고를 노출하지 않습니다.',
    'Ads are hidden here to keep analysis focused.',
  );
  String get insightsSegmentATitle => _t('세그먼트 A (신규)', 'Segment A (New)');
  String get insightsSegmentABody =>
      _t('배너 중심 + 리워드 약한 CTA', 'Banner-first + soft rewarded CTA');
  String get insightsSegmentBTitle =>
      _t('세그먼트 B (복귀)', 'Segment B (Returning)');
  String get insightsSegmentBBody => _t(
    '미션 중심 + 결과 전환 Interstitial',
    'Mission-led + result-transition interstitial',
  );
  String get insightsResultTitle => _t('실험 결과', 'Experiment Result');
  String get insightsResultBody => _t(
    'B 그룹 리텐션 +11%, 다음 액션: B 전략 확대 적용',
    'Group B retention is +11%; next action: scale strategy B.',
  );

  String get onboardingTitle => _t('시작 전 동의 설정', 'Consent Setup');
  String get onboardingNoAdTitle => _t('광고 금지 구간', 'No-Ad Zone');
  String get onboardingNoAdBody => _t(
    '온보딩/민감정보 입력 구간에는 광고를 노출하지 않습니다.',
    'Ads are hidden during onboarding and sensitive flows.',
  );
  String get onboardingConsentTitle => _t('광고 동의 (UMP)', 'Ad Consent (UMP)');
  String get onboardingConsentBody => _t(
    '동의/거부/철회 상태는 즉시 반영됩니다.',
    'Consent, rejection, and withdrawal are reflected immediately.',
  );
  String get onboardingCurrentStatusTitle => _t('현재 상태', 'Current Status');
  String onboardingCurrentStatusBody({
    required bool initialized,
    required bool canRequestAds,
    required bool nonPersonalized,
  }) {
    return 'initialized=$initialized, canRequestAds=$canRequestAds, nonPersonalized=$nonPersonalized';
  }

  String errorMessage(String message) => _t('오류: $message', 'Error: $message');
  String get onboardingAgreeSemantic =>
      _t('동의하고 시작 버튼', 'Agree and start button');
  String get onboardingAgreeProcessing =>
      _t('동의 처리 중...', 'Processing consent...');
  String get onboardingAgreeStart => _t('동의하고 시작', 'Agree and start');
  String get onboardingLaterSemantic =>
      _t('동의 설정 상세는 나중에 버튼', 'Maybe later button');
  String get onboardingLater => _t('동의 설정 상세는 나중에', 'Maybe later');

  String get toolTitle => _t('절약 계산기 (심화)', 'Savings Calculator');
  String get toolInterstitialRulesTitle =>
      _t('전면 광고 노출 규칙', 'Interstitial Rules');
  String toolInterstitialRulesBody(int interval) => _t(
    '결과 버튼 탭 기준 $interval회당 1회 · 연속 노출 금지',
    'Show once every $interval result taps · no back-to-back exposure',
  );
  String get toolCurrentPriceLabel => _t('기존 금액(원)', 'Current price (KRW)');
  String get toolAlternativePriceLabel =>
      _t('대체 금액(원)', 'Alternative price (KRW)');
  String get toolMonthlyCountLabel => _t('월 횟수', 'Monthly count');
  String get toolCalculate => _t('절약 금액 계산', 'Calculate savings');
  String get toolGoToReport => _t('리포트로 이동', 'Go to report');
  String get toolSimulationResultTitle => _t('시뮬레이션 결과', 'Simulation Result');
  String toolSimulationResultBody({
    required int monthlySavings,
    required String latestStatus,
  }) {
    return _t(
      '예상 월 절약액: $monthlySavings원\n최근 광고 상태: $latestStatus',
      'Estimated monthly savings: KRW $monthlySavings\nLatest ad status: $latestStatus',
    );
  }

  String get toolOnlyNumbersAllowed =>
      _t('입력값은 숫자만 가능합니다.', 'Only numeric values are allowed.');
  String get toolBeforePriceMustBeHigher => _t(
    '기존 금액은 대체 금액보다 커야 합니다.',
    'The current price must be greater than the alternative price.',
  );
  String get toolMonthlyCountMustBePositive =>
      _t('월 횟수는 1 이상이어야 합니다.', 'Monthly count must be at least 1.');
  String toolAdSkippedOrFailed(String status) =>
      _t('광고 스킵/실패 상태: $status', 'Ad skipped or failed: $status');

  String get reportTitle => _t('주간 리포트 상세', 'Weekly Report');
  String get reportRewardUnitMissing => _t(
    '리워드 광고 단위 ID가 아직 설정되지 않았습니다.',
    'Rewarded ad unit ID is not configured yet.',
  );
  String reportRewardBlocked(String status) =>
      _t('리워드 미지급/차단 상태: $status', 'Reward not granted or blocked: $status');
  String get reportFreeSummaryTitle => _t('무료 요약', 'Free Summary');
  String get reportFreeSummaryBody => _t(
    '총 절약 63,200원 · 상위 절약 카테고리: 외식, 커피, 구독',
    'Total savings KRW 63,200 · top categories: dining, coffee, subscriptions',
  );
  String get reportUnlockedTitle =>
      _t('상세 리포트 (해제됨)', 'Detailed Report (Unlocked)');
  String get reportLockedTitle => _t('상세 리포트 (잠금)', 'Detailed Report (Locked)');
  String get reportUnlockedBody => _t(
    '광고 시청 보상으로 24시간 상세 분석이 열렸습니다.',
    'A rewarded ad unlocked detailed insights for 24 hours.',
  );
  String get reportLockedBody => _t(
    '보상형 광고 시청 완료 시 24시간 상세 분석이 열립니다.',
    'Watch a rewarded ad to unlock detailed insights for 24 hours.',
  );
  String get reportLoadingAd => _t('광고 로딩 중...', 'Loading ad...');
  String get reportWatchAd => _t('광고 보고 상세 열기', 'Watch ad and unlock');
  String get reportKeepSummary => _t('요약만 유지', 'Keep summary only');
  String get reportFlowTitle => _t('리워드 흐름', 'Reward Flow');
  String reportFlowBody(String status) => _t(
    '1) 광고 보기 선택 2) 시청 완료 3) 보상 지급 4) 상세 열람\n최근 상태: $status',
    '1) Choose ad 2) Finish watching 3) Grant reward 4) Open details\nLatest status: $status',
  );

  String get settingsTitle => _t('광고 설정/컴플라이언스', 'Ads & Compliance');
  String get settingsConsentStateTitle => _t('동의 상태', 'Consent State');
  String settingsConsentStateBody({
    required bool canRequestAds,
    required bool nonPersonalized,
    required bool privacyOptionsRequired,
  }) {
    return 'canRequestAds=$canRequestAds, nonPersonalized=$nonPersonalized, privacyOptionsRequired=$privacyOptionsRequired';
  }

  String get settingsFrequencyCapTitle => _t('빈도 캡', 'Frequency Cap');
  String settingsFrequencyCapBody({
    required int interstitialInterval,
    required int rewardedDailyCap,
  }) {
    return _t(
      'Banner 고정 · Interstitial $interstitialInterval행동당 1회 · Rewarded 1일 $rewardedDailyCap회',
      'Banner fixed · Interstitial once per $interstitialInterval actions · Rewarded $rewardedDailyCap times per day',
    );
  }

  String get settingsPolicyRiskTitle => _t('정책 리스크', 'Policy Risks');
  String get settingsPolicyRiskBody => _t(
    '오탭 유도 금지, 민감 구간 배너 금지, 동의 철회 즉시 반영',
    'No accidental taps, no banners in sensitive zones, reflect consent withdrawal immediately',
  );
  String get settingsSaving => _t('저장 중...', 'Saving...');
  String get settingsSaveGuardrails => _t('가드레일 저장', 'Save guardrails');
  String get settingsGuardrailsSaved =>
      _t('가드레일 설정을 저장했습니다.', 'Guardrail settings were saved.');
  String get settingsPrivacyOptionsNotRequired => _t(
    '현재 지역은 추가 개인정보 옵션 설정이 요구되지 않습니다.',
    'This region does not require additional privacy options.',
  );
  String settingsPrivacyOptionsFailed(String error) =>
      _t('개인정보 설정 변경 실패: $error', 'Failed to update privacy settings: $error');
  String get settingsPrivacyOptionsUpdated =>
      _t('개인정보 설정이 업데이트되었습니다.', 'Privacy settings were updated.');
  String get settingsPrivacyOptionsTitle =>
      _t('개인정보 설정 변경', 'Change privacy settings');
  String get settingsPrivacyOptionsSubtitleRequired => _t(
    '동의 철회/재설정을 즉시 반영합니다.',
    'Updates consent withdrawal and re-selection immediately.',
  );
  String get settingsPrivacyOptionsSubtitleNotRequired => _t(
    '현재 지역은 추가 옵션 제공 의무가 없습니다.',
    'This region does not require an additional options entry point.',
  );
  String get settingsLanguageTitle => _t('앱 언어', 'App Language');
  String get settingsLanguageSubtitle =>
      _t('한국어와 영어 중 하나를 선택합니다.', 'Choose Korean or English.');
  String get languageKorean => '한국어';
  String get languageEnglish => 'English';

  String adStatusLabel(AdShowStatus? status) {
    switch (status) {
      case AdShowStatus.shown:
        return _t('노출됨', 'shown');
      case AdShowStatus.blockedNoConsent:
        return _t('동의 없음', 'blocked: no consent');
      case AdShowStatus.blockedNoAdZone:
        return _t('광고 금지 구간', 'blocked: no-ad zone');
      case AdShowStatus.blockedCooldown:
        return _t('쿨다운 중', 'blocked: cooldown');
      case AdShowStatus.blockedFrequencyCap:
        return _t('빈도 캡 도달', 'blocked: frequency cap');
      case AdShowStatus.blockedUnsupportedPlatform:
        return _t('지원되지 않는 플랫폼', 'blocked: unsupported platform');
      case AdShowStatus.loadFailed:
        return _t('로드 실패', 'load failed');
      case null:
        return _t('없음', 'none');
    }
  }

  String _t(String korean, String english) {
    return _isKorean ? korean : english;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ko' || locale.languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
