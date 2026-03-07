import 'package:flutter/widgets.dart';

import '../ads/ad_result.dart';
import '../content/app_content_repository.dart';

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
  String get adBannerPlaceholder =>
      _t('파트너 영역 로딩 중', 'Partner area loading');
  String get adDisabledRequiresConsent =>
      _t('광고 비활성 (동의 필요)', 'Ads disabled (consent required)');
  String get adBannerSemanticLabel => _t('광고 배너', 'Ad banner');

  String get homeTitle => _t('오늘의 절약', 'Today\'s Savings');
  String get homeHeroTitle => _t(
    '오늘 아낄 수 있는 금액을 바로 확인해보세요',
    'See how much you could save today',
  );
  String get homeHeroBody => _t(
    '반복 지출 하나만 바꿔도 목표에 더 가까워질 수 있어요. 계산기와 리포트에서 바로 확인해보세요.',
    'A single change to a repeated expense can move you closer to your goal. Jump into the calculator or report to see it right away.',
  );
  String get homeStatSavingsLabel => _t('이번 주 절약', 'Saved this week');
  String get homeStatStreakLabel => _t('연속 기록', 'Current streak');
  String get homeTodaySectionTitle => _t(
    '오늘 이렇게 시작해보세요',
    'Start here today',
  );
  String get homeMissionTitle => _t('오늘의 추천', 'Today\'s suggestion');
  String get homeProgressTitle => _t('이번 주 흐름', 'This week\'s progress');
  String get homePrimaryAction => _t(
    '절약 금액 계산하기',
    'Estimate your savings',
  );
  String get homePrimaryActionSemantic =>
      _t('절약 금액 계산하기 버튼', 'Estimate your savings button');
  String get homeSecondaryAction => _t('주간 리포트 보기', 'View weekly report');
  String get homeQuickActionsTitle => _t(
    '지금 할 수 있는 것',
    'What you can do now',
  );
  String get homeQuickCalcBody => _t(
    '자주 쓰는 항목을 바꿨을 때 얼마나 아낄 수 있는지 계산해보세요.',
    'Estimate how much you can save by changing one repeated expense.',
  );
  String get homeQuickReportBody => _t(
    '이번 주 절약 흐름과 카테고리별 변화를 확인해보세요.',
    'Review this week’s savings trend and category changes.',
  );
  String get homeQuickInsightsBody => _t(
    '소비 습관에서 다음 절약 힌트를 찾아보세요.',
    'Find your next savings hint from spending patterns.',
  );
  String get navTool => _t('계산기', 'Calculator');
  String get navReport => _t('리포트', 'Report');
  String get navInsights => _t('인사이트', 'Insights');

  String get insightsTitle => _t('소비 인사이트', 'Spending Insights');
  String get insightsNoAdTitle => _t('집중해서 보기', 'Focus view');
  String get insightsNoAdBody => _t(
    '이번 주 소비 흐름을 광고 없이 편하게 살펴볼 수 있어요.',
    'Review this week’s spending patterns without distraction.',
  );
  String get insightsSegmentATitle => _t(
    '이번 주에 잘한 점',
    'What went well this week',
  );
  String get insightsSegmentBTitle => _t(
    '다음으로 시도해볼 점',
    'What to try next',
  );
  String get insightsResultTitle => _t('한줄 정리', 'Quick takeaway');
  String get insightsResultBody => _t(
    '지금 흐름이면 작은 반복 지출만 더 줄여도 목표에 더 빨리 도달할 수 있어요.',
    'At this pace, trimming a few repeated small expenses can get you to your goal faster.',
  );

  String get onboardingTitle => _t(
    'SaverQuest 시작하기',
    'Start SaverQuest',
  );
  String get onboardingIntroTitle => _t(
    '시작 전에 필요한 설정만 확인할게요',
    'We will check just a few essentials first',
  );
  String get onboardingIntroBody => _t(
    '필요한 개인정보 및 광고 설정이 있으면 안내 화면이 먼저 나타납니다. 설정은 언제든 앱 안에서 다시 바꿀 수 있어요.',
    'If privacy or ad choices are required, you will see a prompt first. You can change them anytime inside the app.',
  );
  String get onboardingTrustSectionTitle => _t(
    '먼저 알아두세요',
    'What to expect',
  );
  String get onboardingSettingsHint => _t(
    '세부 설정은 앱 안의 설정에서 언제든 변경할 수 있어요.',
    'You can change these settings anytime in Settings.',
  );
  String get onboardingNoAdTitle => _t(
    '집중 구간에서는 광고를 쉬어요',
    'Ads stay off during focus moments',
  );
  String get onboardingNoAdBody => _t(
    '온보딩/민감정보 입력 구간에는 광고를 노출하지 않습니다.',
    'Ads are hidden during onboarding and sensitive flows.',
  );
  String get onboardingConsentTitle => _t(
    '필요한 설정만 분명하게 안내해요',
    'Only required choices are shown clearly',
  );
  String get onboardingConsentBody => _t(
    '개인정보 또는 광고 관련 선택이 필요할 때만 안내하며, 변경 내용은 바로 반영됩니다.',
    'We only ask when privacy or ad choices are needed, and updates apply right away.',
  );
  String get onboardingCurrentStatusTitle => _t('현재 상태', 'Current Status');
  String onboardingCurrentStatusBody({
    required bool initialized,
    required bool canRequestAds,
    required bool nonPersonalized,
  }) {
    return 'initialized=$initialized, canRequestAds=$canRequestAds, nonPersonalized=$nonPersonalized';
  }

  String errorMessage(String message) => _t(
    '개인정보 설정을 불러오는 중 문제가 있었습니다. 앱은 계속 사용할 수 있고, 설정에서 다시 변경할 수 있습니다.',
    'There was a problem loading privacy settings. You can still continue and update them later in Settings.',
  );
  String get onboardingAgreeSemantic => _t('계속하기 버튼', 'Continue button');
  String get onboardingAgreeProcessing =>
      _t('준비 중...', 'Getting things ready...');
  String get onboardingAgreeStart => _t('계속하기', 'Continue');
  String get onboardingLaterSemantic =>
      _t('나중에 설정에서 변경 버튼', 'Change later in Settings button');
  String get onboardingLater =>
      _t('나중에 설정에서 변경', 'Change later in Settings');

  String get toolTitle => _t('절약 계산기', 'Savings Calculator');
  String get toolHeroTitle => _t(
    '반복 지출 하나만 바꿔도 얼마나 아낄 수 있을까요?',
    'How much could you save by changing one repeated expense?',
  );
  String get toolHeroBody => _t(
    '기존 금액, 대체 금액, 한 달 횟수를 입력하면 예상 절약 금액을 바로 확인할 수 있어요.',
    'Enter the current amount, alternative amount, and monthly frequency to estimate your savings right away.',
  );
  String get toolInputSectionTitle => _t(
    '계산할 항목 입력',
    'Enter your numbers',
  );
  String get toolInputSectionBody => _t(
    '자주 쓰는 지출 항목을 기준으로 입력해보세요.',
    'Use one of your repeated spending habits as the example.',
  );
  String get toolInterstitialRulesTitle =>
      _t('계산 안내', 'Calculation guide');
  String toolInterstitialRulesBody(int interval) => _t(
    '자주 쓰는 지출 항목을 바꿨을 때 한 달에 얼마나 아낄 수 있는지 바로 확인할 수 있어요.',
    'See how much you could save each month by changing one repeated expense.',
  );
  String get toolCurrentPriceLabel => _t('기존 금액(원)', 'Current price (KRW)');
  String get toolAlternativePriceLabel =>
      _t('대체 금액(원)', 'Alternative price (KRW)');
  String get toolMonthlyCountLabel => _t('월 횟수', 'Monthly count');
  String get toolCalculate => _t('절약 금액 계산', 'Calculate savings');
  String get toolGoToReport => _t('리포트로 이동', 'Go to report');
  String get toolSimulationResultTitle => _t(
    '계산 결과',
    'Calculation result',
  );
  String get toolMonthlyResultLabel => _t('한 달 기준', 'Per month');
  String get toolYearlyResultLabel => _t('1년 기준', 'Per year');
  String get toolEmptyResultBody => _t(
    '금액을 입력하고 계산하면 예상 절약 금액이 여기에 표시됩니다.',
    'Your estimated savings will appear here once you enter your numbers.',
  );
  String toolSimulationResultBody({
    required int monthlySavings,
    required String latestStatus,
  }) {
    final monthlyLabel = formatCurrency(monthlySavings);
    final yearlyLabel = formatCurrency(monthlySavings * 12);
    return _t(
      '한 달에 약 $monthlyLabel을 아낄 수 있어요.\n1년으로 보면 약 $yearlyLabel입니다.',
      'You could save about $monthlyLabel each month.\nThat is about $yearlyLabel over a year.',
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
      _t(
        '광고를 불러오지 못했지만 계산 결과는 그대로 확인할 수 있어요.',
        'The ad could not be loaded, but your result is still available.',
      );

  String get reportTitle => _t('주간 절약 리포트', 'Weekly Savings Report');
  String get reportHeroTitle => _t(
    '이번 주 절약 흐름을 한눈에 확인해보세요',
    'See your weekly savings trend at a glance',
  );
  String get reportHeroBody => _t(
    '요약부터 자세한 분석까지, 이번 주 소비 패턴을 차분하게 살펴볼 수 있어요.',
    'From a quick summary to deeper analysis, review this week’s spending pattern in one place.',
  );
  String get reportStatSavingsLabel => _t('이번 주 절약', 'Saved this week');
  String get reportStatTopCategoryLabel => _t('가장 크게 줄인 항목', 'Top reduced category');
  String get reportStatDetailLabel => _t('상세 보기 상태', 'Detailed view');
  String get reportDetailReadyValue => _t('열림', 'Open');
  String get reportDetailLockedValue => _t('요약만 보기', 'Summary only');
  String get reportDetailComingSoonValue => _t('준비 중', 'Coming soon');
  String get reportRewardUnitMissing => _t(
    '추가 리포트 기능을 준비 중입니다.',
    'Detailed report access is being prepared.',
  );
  String reportRewardBlocked(String status) =>
      _t(
        '지금은 추가 리포트를 열 수 없어요. 잠시 후 다시 시도해주세요.',
        'The detailed report is unavailable right now. Please try again shortly.',
      );
  String get reportFreeSummaryTitle => _t('이번 주 요약', 'This week at a glance');
  String get reportUnlockedTitle => _t('상세 분석', 'Detailed insights');
  String get reportLockedTitle => _t('더 자세히 보기', 'See more detail');
  String get reportUnlockedBody => _t(
    '더 자세한 절약 흐름과 카테고리 분석을 확인할 수 있어요.',
    'You can now view deeper savings trends and category analysis.',
  );
  String get reportUnlockedTrendTitle => _t(
    '카테고리 흐름',
    'Category trend',
  );
  String get reportUnlockedFocusTitle => _t(
    '다음 주 집중 포인트',
    'Next-week focus',
  );
  String get reportLockedBody => _t(
    '광고를 보고 더 자세한 절약 분석을 확인할 수 있어요.',
    'Watch an ad to open a more detailed savings view.',
  );
  String get reportPreviewTitle => _t(
    '상세 리포트 준비 중',
    'Detailed report is on the way',
  );
  String get reportPreviewBody => _t(
    '지금은 요약과 인사이트 중심으로 확인할 수 있어요. 상세 리포트는 다음 업데이트에서 더 자연스럽게 제공될 예정입니다.',
    'For now, the experience focuses on the summary and insights. A deeper report will arrive in a future update.',
  );
  String get reportPreviewAction => _t(
    '인사이트 먼저 보기',
    'Open insights instead',
  );
  String get reportLoadingAd => _t('광고 로딩 중...', 'Loading ad...');
  String get reportWatchAd => _t('광고 보고 자세히 보기', 'Watch ad and continue');
  String get reportKeepSummary => _t('지금은 요약만 보기', 'Keep the summary for now');
  String get reportFlowTitle => _t('이용 안내', 'How it works');
  String get reportNextSectionTitle => _t('다음 단계', 'Next step');
  String get reportNextSectionBody => _t(
    '계산기에서 자주 쓰는 지출을 먼저 정리하고, 인사이트 화면에서 다음 절약 힌트를 확인해보세요.',
    'Start with the calculator for one repeated expense, then use Insights to decide your next savings move.',
  );
  String reportFlowBody(String status) => _t(
    '광고를 본 뒤 바로 더 자세한 리포트를 확인할 수 있어요. 원하지 않으면 요약만 보고 넘어가도 됩니다.',
    'After watching the ad, you can open a more detailed report right away. You can also stay with the summary if you prefer.',
  );

  String get settingsTitle => _t('개인정보 및 앱 설정', 'Privacy & app settings');
  String get settingsHeroBody => _t(
    '개인정보 설정, 광고 안내, 언어 선택을 이곳에서 차분하게 관리할 수 있어요.',
    'Manage privacy choices, ad guidance, and language preferences here.',
  );
  String get settingsManageTitle => _t('설정 변경', 'Adjust settings');
  String get settingsConsentStateTitle => _t(
    '개인정보 설정',
    'Privacy settings',
  );
  String settingsConsentStateBody({
    required bool canRequestAds,
    required bool nonPersonalized,
    required bool privacyOptionsRequired,
  }) {
    if (canRequestAds) {
      return _t(
        '현재 개인정보 설정이 적용되어 있습니다. 필요하면 아래에서 언제든 변경할 수 있어요.',
        'Your current privacy choices are applied. You can update them below anytime.',
      );
    }

    if (nonPersonalized || privacyOptionsRequired) {
      return _t(
        '현재 맞춤형 광고 없이 앱을 이용 중입니다. 필요하면 아래에서 개인정보 설정을 다시 선택할 수 있어요.',
        'You are currently using the app without personalized ads. You can review your privacy choices below.',
      );
    }

    return _t(
      '개인정보 설정을 다시 확인해야 할 수 있습니다. 아래에서 언제든 변경할 수 있어요.',
      'You may need to review your privacy settings. You can update them below anytime.',
    );
  }

  String get settingsAdsInfoTitle => _t('광고 안내', 'About ads');
  String get settingsAdsInfoBody => _t(
    '광고는 일부 화면에서만 조심스럽게 표시되며, 계산이나 설정 흐름을 방해하지 않도록 제한됩니다.',
    'Ads appear carefully on selected screens only and stay limited so they do not interrupt calculation or settings flows.',
  );
  String get settingsSaving => _t('저장 중...', 'Saving...');
  String get settingsSaveGuardrails => _t('가드레일 저장', 'Save guardrails');
  String get settingsGuardrailsSaved =>
      _t('가드레일 설정을 저장했습니다.', 'Guardrail settings were saved.');
  String get settingsPrivacyOptionsNotRequired => _t(
    '현재는 추가로 바꿀 개인정보 옵션이 없습니다.',
    'There are no additional privacy options to change right now.',
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
    '현재는 이 화면에서 추가로 바꿀 항목이 없습니다.',
    'There is nothing extra to change from this screen right now.',
  );
  String get settingsLanguageTitle => _t('앱 언어', 'App Language');
  String get settingsLanguageSubtitle =>
      _t('한국어와 영어 중 하나를 선택합니다.', 'Choose Korean or English.');

  String get insightsHeroBody => _t(
    '이번 주 소비 흐름에서 바로 적용할 수 있는 절약 힌트를 정리했어요.',
    'Here are practical savings hints based on this week’s spending pattern.',
  );
  String get languageKorean => '한국어';
  String get languageEnglish => 'English';

  /// Formats a currency value for the active locale.
  String formatCurrency(int amount) {
    final formatted = _formatNumber(amount);
    return _isKorean ? '$formatted원' : 'KRW $formatted';
  }

  /// Formats a streak duration for the active locale.
  String formatDays(int days) => _isKorean ? '$days일' : '$days days';

  /// Returns the localized label for a supported spending category.
  String spendingCategoryLabel(SpendingCategory category) {
    return switch (category) {
      SpendingCategory.coffee => _t('커피', 'Coffee'),
      SpendingCategory.dining => _t('외식', 'Dining'),
      SpendingCategory.subscriptions => _t('구독', 'Subscriptions'),
      SpendingCategory.snacks => _t('간식', 'Snacks'),
    };
  }

  /// Joins localized category labels for summaries and guidance messages.
  String spendingCategoryList(Iterable<SpendingCategory> categories) {
    return categories.map(spendingCategoryLabel).join(', ');
  }

  /// Returns the home hero savings value from the supplied amount.
  String homeStatSavingsValue(int amount) => formatCurrency(amount);

  /// Returns the home hero streak value from the supplied day count.
  String homeStatStreakValue(int days) => formatDays(days);

  /// Builds the home mission body from a category and savings amount.
  String homeMissionBodyForCategory({
    required SpendingCategory category,
    required int savingsAmount,
  }) {
    final categoryLabel = spendingCategoryLabel(category);
    final amountLabel = formatCurrency(savingsAmount);
    return _t(
      '$categoryLabel 한 번만 줄여도 오늘 $amountLabel을 아낄 수 있어요.',
      'Cut one $categoryLabel purchase today and save $amountLabel.',
    );
  }

  /// Builds the weekly progress body from progress and streak metrics.
  String homeProgressBodyForProgress({
    required int goalProgressPercent,
    required int streakDays,
  }) {
    final streakLabel = formatDays(streakDays);
    return _t(
      '목표의 $goalProgressPercent%를 채웠고, $streakLabel째 꾸준히 이어가고 있어요.',
      'You have reached $goalProgressPercent% of your goal and kept a $streakLabel streak.',
    );
  }

  /// Returns the localized top-category value for the report hero.
  String reportTopCategoryValue(SpendingCategory category) =>
      spendingCategoryLabel(category);

  /// Builds the report summary body from amount and category data.
  String reportFreeSummaryBodyFor({
    required int totalSavings,
    required List<SpendingCategory> topCategories,
  }) {
    return _t(
      '총 절약 ${formatCurrency(totalSavings)} · 상위 절약 카테고리: ${spendingCategoryList(topCategories)}',
      'Total savings ${formatCurrency(totalSavings)} · top categories: ${spendingCategoryList(topCategories)}',
    );
  }

  /// Builds the report trend body from the best-performing categories.
  String reportUnlockedTrendBodyFor(List<SpendingCategory> trendCategories) {
    final categoryLabel = spendingCategoryList(trendCategories);
    return _t(
      '$categoryLabel 지출이 함께 줄면서 이번 주 절약 흐름이 가장 안정적으로 유지됐어요.',
      '$categoryLabel spending dropped together, creating the most stable savings trend this week.',
    );
  }

  /// Builds the report focus body from the next target categories.
  String reportUnlockedFocusBodyFor(List<SpendingCategory> focusCategories) {
    final categoryLabel = spendingCategoryList(focusCategories);
    return _t(
      '$categoryLabel 항목만 한 번 더 점검하면 절약 폭을 더 넓힐 수 있어요.',
      'A quick review of $categoryLabel can widen your savings next week.',
    );
  }

  /// Builds the positive insights body from recently improved categories.
  String insightsSegmentABodyFor(List<SpendingCategory> positiveCategories) {
    final categoryLabel = spendingCategoryList(positiveCategories);
    return _t(
      '$categoryLabel 지출이 줄어들면서 절약 흐름이 안정적으로 이어지고 있어요.',
      'Your savings rhythm is improving as $categoryLabel spending stays lower.',
    );
  }

  /// Builds the next-step insights body from upcoming target categories.
  String insightsSegmentBBodyFor(List<SpendingCategory> nextFocusCategories) {
    final categoryLabel = spendingCategoryList(nextFocusCategories);
    return _t(
      '$categoryLabel 지출을 함께 점검하면 다음 주 절약 폭을 더 키울 수 있어요.',
      'Review $categoryLabel next to increase savings further.',
    );
  }

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

  /// Formats an integer with grouping separators without extra dependencies.
  String _formatNumber(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index += 1) {
      final reversedIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return value < 0 ? '-$buffer' : buffer.toString();
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
