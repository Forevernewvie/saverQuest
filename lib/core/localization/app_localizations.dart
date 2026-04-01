import 'package:flutter/widgets.dart';

import '../ads/ad_result.dart';
import '../content/app_content_repository.dart';
import '../ledger/ledger_models.dart';

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
  String get adBannerPlaceholder => _t('파트너 영역 로딩 중', 'Partner area loading');
  String get adDisabledRequiresConsent =>
      _t('광고 비활성 (동의 필요)', 'Ads disabled (consent required)');
  String get adBannerSemanticLabel => _t('광고 배너', 'Ad banner');

  String get homeTitle => _t('이번 달', 'This month');
  String get homeHeroTitle =>
      _t('남은 예산을 먼저 확인하세요', 'Check your remaining budget first');
  String get homeHeroBody => _t(
    '지출이 생기면 기록하고, 남은 예산을 여기서 확인하세요.',
    'Record spending, then check the remaining budget here.',
  );
  String get homeStatSavingsLabel => _t('이번 달 지출', 'Spent this month');
  String get homeStatRemainingLabel => _t('남은 예산', 'Remaining budget');
  String get homeStatStreakLabel => _t('이번 달 수입', 'Income this month');
  String get homeTodaySectionTitle =>
      _t('이번 달 예산 현황', 'Monthly budget overview');
  String get homeBudgetOverviewTitle => _t('예산 진행률', 'Budget progress');
  String get homeBudgetOverviewBody => _t(
    '예산과 현재 사용 금액을 바로 비교해 보세요.',
    'Compare the budget with current spend at a glance.',
  );
  String get homeBudgetSpentLabel => _t('사용 금액', 'Spent');
  String get homeBudgetLimitLabel => _t('예산 한도', 'Budget limit');
  String get homeMissionTitle => _t('가장 큰 지출 항목', 'Largest spending category');
  String get homePrimaryAction => _t('거래 기록하기', 'Add transaction');
  String get homePrimaryActionSemantic =>
      _t('거래 기록하기 버튼', 'Add transaction button');
  String get monthSwitcherPreviousSemantic =>
      _t('이전 달 보기', 'Show previous month');
  String get monthSwitcherNextSemantic => _t('다음 달 보기', 'Show next month');
  String get monthSwitcherCurrentAction => _t('이번 달', 'Current month');
  String get homeRecentEntriesTitle => _t('최근 기록', 'Recent activity');
  String get homeRecentEntriesSubtitle =>
      _t('최근 기록한 거래를 빠르게 확인합니다.', 'Review the latest transactions quickly.');
  String get homeEmptyRecordsTitle => _t('아직 기록이 없습니다', 'No records yet');
  String get homeEmptyRecordsBody => _t(
    '첫 지출이나 수입을 기록하면 이번 달 흐름이 여기서 바로 보입니다.',
    'Once you record your first expense or income, this month’s flow will appear here.',
  );
  String get navHome => _t('홈', 'Home');
  String get navTool => _t('기록', 'Entry');
  String get navReport => _t('리포트', 'Report');
  String get navInsights => _t('인사이트', 'Insights');

  String get insightsTitle => _t('절약 인사이트', 'Spending insights');
  String get insightsNoAdTitle => _t('이번 달 해석', 'This month at a glance');
  String get insightsNoAdBody => _t(
    '이번 달 기록을 바탕으로 패턴과 다음 행동을 정리합니다.',
    'Review the pattern and next action from this month’s records.',
  );
  String get insightsSegmentATitle => _t('가장 큰 지출 축', 'Largest expense driver');
  String get insightsSegmentBTitle =>
      _t('다음으로 볼 항목', 'Next category to review');
  String get insightsResultTitle => _t('예산 상태', 'Budget status');

  String get onboardingTitle => _t('SaverQuest 시작하기', 'Start SaverQuest');
  String get onboardingIntroTitle =>
      _t('이번 달 예산부터 시작하세요', 'Start with this month’s budget');
  String get onboardingIntroBody => _t(
    '예산을 먼저 보고, 거래를 기록하면 됩니다. 필요한 설정이 있을 때만 잠깐 확인합니다.',
    'See the budget first, then record transactions. We only pause if a required setting needs attention.',
  );
  String get onboardingTrustSectionTitle => _t('먼저 알아두세요', 'What to expect');
  String get onboardingSettingsHint => _t(
    '세부 설정은 앱 안의 설정에서 언제든 변경할 수 있어요.',
    'You can change these settings anytime in Settings.',
  );
  String get onboardingNoAdTitle =>
      _t('집중 구간에서는 광고를 쉬어요', 'Ads stay off during focus moments');
  String get onboardingNoAdBody => _t(
    '온보딩/민감정보 입력 구간에는 광고를 노출하지 않습니다.',
    'Ads are hidden during onboarding and sensitive flows.',
  );
  String get onboardingConsentTitle =>
      _t('필요한 설정만 분명하게 안내해요', 'Only required choices are shown clearly');
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
  String get onboardingAgreeStart => _t('예산 보기', 'Open budget');
  String get onboardingLaterSemantic =>
      _t('나중에 설정에서 변경 버튼', 'Change later in Settings button');
  String get onboardingLater => _t('나중에 하기', 'Not now');

  String get toolTitle => _t('거래 기록', 'Record transaction');
  String get toolHeroTitle =>
      _t('오늘 쓴 돈을 먼저 기록하세요', 'Record today’s spending first');
  String get toolHeroBody => _t(
    '거래를 먼저 입력하고 예산은 필요할 때만 아래에서 바꾸세요.',
    'Start with the entry. Change the budget below only when needed.',
  );
  String get toolInputSectionTitle => _t('1. 거래 입력', '1. Add a record');
  String get toolInputSectionBody => _t(
    '금액, 카테고리, 날짜만 입력하면 바로 저장할 수 있습니다.',
    'Enter amount, category, and date to save right away.',
  );
  String get toolEntryTypeLabel => _t('거래 유형', 'Entry type');
  String get toolExpenseType => _t('지출', 'Expense');
  String get toolIncomeType => _t('수입', 'Income');
  String get toolCategoryLabel => _t('카테고리', 'Category');
  String get toolAmountLabel => _t('금액(원)', 'Amount (KRW)');
  String get toolAmountHint => _t('예: 12500', 'Example: 12500');
  String get toolNoteLabel => _t('메모', 'Note');
  String get toolNoteHint => _t('예: 퇴근길 장보기', 'Example: after-work groceries');
  String get toolDateLabel => _t('날짜', 'Date');
  String get toolDateAction => _t('날짜 선택', 'Choose date');
  String get toolSubmit => _t('거래 저장', 'Save entry');
  String get toolSubmitSuccess => _t('거래를 저장했습니다.', 'Transaction saved.');
  String get toolUpdateSubmit => _t('수정 내용 저장', 'Save changes');
  String get toolUpdateSuccess => _t('거래를 수정했습니다.', 'Transaction updated.');
  String get toolEditEntryAction => _t('수정', 'Edit');
  String get toolDeleteEntryAction => _t('삭제', 'Delete');
  String get toolDeleteDialogTitle =>
      _t('이 거래를 삭제할까요?', 'Delete this transaction?');
  String get toolDeleteDialogBody =>
      _t('삭제한 거래는 다시 복구할 수 없습니다.', 'Deleted transactions cannot be restored.');
  String get toolDeleteConfirm => _t('삭제하기', 'Delete');
  String get toolDeleteCancel => _t('취소', 'Cancel');
  String get toolDeleteSuccess => _t('거래를 삭제했습니다.', 'Transaction deleted.');
  String get toolDetailTitle => _t('거래 상세', 'Transaction details');
  String get toolDetailTypeLabel => _t('거래 유형', 'Entry type');
  String get toolDetailCategoryLabel => _t('카테고리', 'Category');
  String get toolDetailDateLabel => _t('기록 날짜', 'Recorded on');
  String get toolDetailNoteLabel => _t('메모', 'Note');
  String get toolDetailEmptyNote => _t('메모가 없습니다.', 'No note added.');
  String get toolDetailSheetHint => _t(
    '항목을 검토한 뒤 수정하거나 삭제할 수 있습니다.',
    'Review this entry and edit or delete it if needed.',
  );
  String get toolEditingBannerTitle =>
      _t('거래를 수정하는 중입니다', 'Editing an existing transaction');
  String get toolEditingBannerBody => _t(
    '내용을 바꾼 뒤 저장하면 기존 거래가 업데이트됩니다.',
    'Save after making changes to update the existing transaction.',
  );
  String get toolEditingCancel => _t('수정 취소', 'Cancel edit');
  String get toolRecentRecordsTitle => _t('방금 기록한 항목', 'Latest entries');
  String get toolRecentRecordsBody =>
      _t('방금 저장한 거래를 아래에서 확인하세요.', 'See the most recent saved entries below.');
  String get toolBudgetSectionTitle => _t('2. 예산 조정', '2. Adjust budget');
  String get toolBudgetSectionBody => _t(
    '예산을 바꿔야 할 때만 수정하면 홈과 인사이트에 바로 반영됩니다.',
    'Only change this when the monthly budget needs updating.',
  );
  String get toolBudgetAmountLabel => _t('월 예산 금액', 'Monthly budget amount');
  String get toolBudgetAmountHint => _t('예: 450000', 'Example: 450000');
  String get toolBudgetSave => _t('예산 저장', 'Save budget');
  String get toolBudgetSaved => _t('월 예산을 저장했습니다.', 'Monthly budget saved.');
  String get toolAmountValidation => _t(
    '금액은 1원 이상 숫자로 입력해야 합니다.',
    'Enter a numeric amount greater than zero.',
  );
  String get toolBudgetValidation => _t(
    '예산은 1원 이상 숫자로 입력해야 합니다.',
    'Enter a numeric budget greater than zero.',
  );
  String get toolDateToday => _t('오늘', 'Today');
  String get toolEmptyRecentTitle =>
      _t('아직 저장한 거래가 없습니다', 'No recent entries yet');
  String get toolEmptyRecentBody => _t(
    '지출이나 수입을 한 건 저장하면 여기서 바로 확인할 수 있습니다.',
    'Save your first expense or income to see it here.',
  );

  String get reportTitle => _t('이번 달 요약', 'This month summary');
  String get reportHeroTitle =>
      _t('이번 달 기록을 숫자로 정리했어요', 'This month in numbers');
  String get reportHeroBody => _t(
    '지출·수입과 카테고리 흐름을 한 번에 봅니다.',
    'See totals and category flow in one place.',
  );
  String get reportStatSavingsLabel => _t('지출 합계', 'Expenses');
  String get reportStatTopCategoryLabel => _t('수입 합계', 'Income');
  String get reportStatDetailLabel => _t('월간 잔액', 'Balance');
  String get reportSummaryTitle => _t('카테고리별 지출', 'Spending by category');
  String get reportChartTitle => _t('지출 비중', 'Spending distribution');
  String get reportChartSubtitle => _t(
    '이번 달 지출 카테고리를 비중 순서로 살펴보세요.',
    'Review this month’s expense categories in descending order.',
  );
  String get reportFilterTitle => _t('카테고리 필터', 'Category filter');
  String get reportFilterSubtitle => _t(
    '원하는 카테고리만 골라 최근 거래를 좁혀보세요.',
    'Narrow recent transactions by category when needed.',
  );
  String get reportFilterAllLabel => _t('전체', 'All');
  String get reportFilteredEmptyTitle =>
      _t('선택한 카테고리의 최근 거래가 없습니다', 'No recent transactions in this category');
  String get reportFilteredEmptyBody => _t(
    '전체 보기로 돌아가면 다른 최근 거래를 확인할 수 있습니다.',
    'Return to All to review the other recent transactions.',
  );
  String get reportRecentEntriesTitle => _t('최근 거래', 'Recent transactions');
  String get reportBudgetStatusTitle => _t('예산 상태', 'Budget status');
  String get reportEmptyTitle =>
      _t('이번 달 기록이 없습니다', 'No transactions this month');
  String get reportEmptyBody => _t(
    '지출이나 수입을 기록하면 카테고리별 합계와 최근 거래가 이 화면에 표시됩니다.',
    'Once you add expenses or income, category totals and recent transactions will appear here.',
  );
  String reportEntryCountLabel(int count) =>
      _t('지출 $count건', '$count expense entries');

  String get settingsTitle => _t('개인정보 및 앱 설정', 'Privacy & app settings');
  String get settingsHeroBody => _t(
    '개인정보 설정, 광고 안내, 언어 선택을 이곳에서 차분하게 관리할 수 있어요.',
    'Manage privacy choices, ad guidance, and language preferences here.',
  );
  String get settingsManageTitle => _t('설정 변경', 'Adjust settings');
  String get settingsConsentStateTitle => _t('개인정보 설정', 'Privacy settings');
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
  String get settingsPrivacyPolicyTitle => _t('개인정보 처리방침', 'Privacy policy');
  String get settingsPrivacyPolicySubtitle => _t(
    '앱에서 처리하는 정보와 외부 서비스를 확인합니다.',
    'Review what the app processes and which third-party services are used.',
  );
  String get settingsLanguageTitle => _t('앱 언어', 'App Language');
  String get settingsLanguageSubtitle =>
      _t('한국어와 영어 중 하나를 선택합니다.', 'Choose Korean or English.');

  String get privacyPolicyPageTitle => _t('개인정보 처리방침', 'Privacy Policy');
  String get privacyPolicyHeroTitle =>
      _t('앱에서 어떤 정보를 어떻게 다루는지 안내합니다', 'How the app handles information');
  String get privacyPolicyHeroBody => _t(
    'SaverQuest는 앱 운영, 안정성 개선, 광고 제공에 필요한 범위에서만 정보를 처리합니다. 자세한 내용은 아래 항목에서 확인할 수 있습니다.',
    'SaverQuest processes information only where needed for app operation, stability, and advertising. The sections below explain the details.',
  );
  String get privacyPolicySectionTitle => _t('주요 정책 항목', 'Key policy sections');
  String get privacyPolicySectionSubtitle => _t(
    'GitHub Pages 공개 URL을 기준으로 안내합니다. 배포 전 문의처와 운영 정보는 실제 값으로 다시 확인해야 합니다.',
    'This policy is presented with the GitHub Pages public URL. Review the contact details and operator information before release.',
  );
  String get privacyPolicyOverviewTitle => _t('개요', 'Overview');
  String get privacyPolicyOverviewBody => _t(
    'SaverQuest는 절약 계산, 주간 리포트, 소비 인사이트 기능을 제공하는 모바일 앱입니다. 서비스 운영과 품질 개선을 위해 필요한 최소 범위의 정보를 처리할 수 있습니다.',
    'SaverQuest is a mobile app for savings calculations, weekly reports, and spending insights. It may process a minimal set of information needed for service operation and quality improvement.',
  );
  String get privacyPolicyCollectedDataTitle =>
      _t('처리할 수 있는 정보', 'Data that may be processed');
  String get privacyPolicyCollectedDataBody => _t(
    '앱 사용 기록, 화면 조회, 오류 및 크래시 정보, 앱 버전과 운영체제 정보, 언어 설정, 광고 요청 및 응답 상태를 처리할 수 있습니다.',
    'The app may process usage events, screen views, crash and error data, app and operating-system versions, language preferences, and ad request or response status.',
  );
  String get privacyPolicyPurposeTitle =>
      _t('이용 목적', 'Why the information is used');
  String get privacyPolicyPurposeBody => _t(
    '서비스 제공, 앱 안정성 향상, 오류 분석, 광고 제공, 개인정보 및 언어 설정 유지에 사용됩니다.',
    'The information is used to provide the service, improve app stability, analyze errors, serve ads, and preserve privacy and language preferences.',
  );
  String get privacyPolicyThirdPartyTitle =>
      _t('외부 서비스', 'Third-party services');
  String get privacyPolicyThirdPartyBody => _t(
    '광고 제공을 위해 Google AdMob을, 사용 흐름 분석을 위해 Firebase Analytics를, 오류 진단을 위해 Firebase Crashlytics를 사용할 수 있습니다.',
    'The app may use Google AdMob for ads, Firebase Analytics for usage analysis, and Firebase Crashlytics for crash diagnostics.',
  );
  String get privacyPolicyChoicesTitle =>
      _t('선택권 및 동의 관리', 'Choices and consent controls');
  String get privacyPolicyChoicesBody => _t(
    '필요한 경우 광고 및 개인정보 선택 화면이 먼저 표시될 수 있습니다. 앱 설정의 개인정보 설정 변경에서 동의 상태를 다시 확인하거나 바꿀 수 있습니다.',
    'When required, the app may show a privacy or ad-choice prompt first. You can review or change those choices in Settings at any time.',
  );
  String get privacyPolicyRetentionTitle =>
      _t('보관 기간 및 보안', 'Retention and security');
  String get privacyPolicyRetentionBody => _t(
    '서비스 운영과 법적 의무에 필요한 범위에서만 정보를 보관합니다. 합리적인 보안 조치를 적용하지만, 인터넷 전송과 전자 저장 방식의 특성상 절대적인 보안을 보장할 수는 없습니다.',
    'Information is kept only as needed for service operation and legal obligations. Reasonable safeguards are applied, but absolute security cannot be guaranteed for internet transmission or electronic storage.',
  );
  String get privacyPolicyContactTitle =>
      _t('문의 및 운영 정보', 'Contact and operator details');
  String get privacyPolicyContactBody => _t(
    '문의 이메일은 privacy@saverquest.app, 운영 주체는 SaverQuest Team으로 기재되어 있습니다. 실제 배포 전에는 운영 정보에 맞게 검토해야 합니다.',
    'The current contact email is privacy@saverquest.app and the operator name is SaverQuest Team. Review these values before production release.',
  );
  String get privacyPolicyPublicUrlTitle =>
      _t('공개 URL 안내', 'Public URL guidance');
  String get privacyPolicyPublicUrlBody => _t(
    '현재 공개 URL은 https://forevernewvie.github.io/saverQuest/privacy/ 입니다. GitHub Pages를 활성화하면 스토어 제출용 HTTPS 정책 링크로 사용할 수 있습니다.',
    'The current public URL is https://forevernewvie.github.io/saverQuest/privacy/. Once GitHub Pages is enabled, it can be used as the HTTPS privacy-policy link for store submission.',
  );

  String get insightsHeroBody => _t(
    '먼저 줄이거나 조정할 항목을 바로 보여줍니다.',
    'See what to cut back on or adjust first.',
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

  /// Formats a compact month-day label for transaction rows.
  String formatShortDate(DateTime date) {
    return _isKorean
        ? '${date.month}월 ${date.day}일'
        : '${_englishMonth(date.month)} ${date.day}';
  }

  /// Formats a month label used by dashboard navigation surfaces.
  String formatMonthYear(DateTime date) {
    return _isKorean
        ? '${date.year}년 ${date.month}월'
        : '${_englishMonth(date.month)} ${date.year}';
  }

  /// Returns the localized label for a ledger entry type.
  String ledgerEntryTypeLabel(LedgerEntryType type) {
    return switch (type) {
      LedgerEntryType.expense => _t('지출', 'Expense'),
      LedgerEntryType.income => _t('수입', 'Income'),
    };
  }

  /// Returns the localized label for a ledger category.
  String ledgerCategoryLabel(LedgerCategory category) {
    return switch (category) {
      LedgerCategory.groceries => _t('식비', 'Groceries'),
      LedgerCategory.dining => _t('외식', 'Dining'),
      LedgerCategory.transport => _t('교통', 'Transport'),
      LedgerCategory.coffee => _t('커피', 'Coffee'),
      LedgerCategory.shopping => _t('쇼핑', 'Shopping'),
      LedgerCategory.housing => _t('주거', 'Housing'),
      LedgerCategory.subscriptions => _t('구독', 'Subscriptions'),
      LedgerCategory.health => _t('건강', 'Health'),
      LedgerCategory.entertainment => _t('여가', 'Entertainment'),
      LedgerCategory.salary => _t('급여', 'Salary'),
      LedgerCategory.freelance => _t('부수입', 'Freelance'),
      LedgerCategory.savings => _t('저축', 'Savings'),
    };
  }

  /// Joins localized ledger category labels for compact summaries.
  String ledgerCategoryList(Iterable<LedgerCategory> categories) {
    return categories.map(ledgerCategoryLabel).join(', ');
  }

  /// Formats a signed amount for a transaction based on its entry type.
  String formatSignedCurrency({
    required LedgerEntryType type,
    required int amount,
  }) {
    final prefix = type == LedgerEntryType.expense ? '-' : '+';
    return '$prefix${formatCurrency(amount)}';
  }

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

  /// Returns the remaining-budget value from the supplied amount.
  String homeStatRemainingValue(int amount) => formatCurrency(amount);

  /// Returns the home hero streak value from the supplied day count.
  String homeStatStreakValue(int days) => formatDays(days);

  /// Returns the localized goal-progress value.
  String homeStatGoalValue(int progressPercent) => '$progressPercent%';

  /// Builds the home top-category body from the category and amount.
  String homeTopCategoryBody({
    required LedgerCategory? category,
    required int amount,
  }) {
    if (category == null) {
      return _t(
        '지금은 가장 큰 지출 항목을 계산할 기록이 부족합니다.',
        'There is not enough data yet to identify the largest spending category.',
      );
    }

    return _t(
      '${ledgerCategoryLabel(category)} 항목이 ${formatCurrency(amount)}으로 가장 큰 비중을 차지하고 있어요.',
      '${ledgerCategoryLabel(category)} is the largest expense so far at ${formatCurrency(amount)}.',
    );
  }

  /// Builds the report budget status body from remaining budget and balance.
  String reportBudgetStatusBody({
    required int remainingBudgetAmount,
    required int balanceAmount,
  }) {
    final remainingLabel = formatCurrency(remainingBudgetAmount.abs());
    final balanceLabel = formatCurrency(balanceAmount.abs());

    if (remainingBudgetAmount >= 0) {
      return _t(
        '예산에서 $remainingLabel이 남아 있습니다. 월간 잔액은 ${balanceAmount >= 0 ? '+' : '-'}$balanceLabel입니다.',
        'You still have $remainingLabel left in the budget. Your monthly balance is ${balanceAmount >= 0 ? '+' : '-'}$balanceLabel.',
      );
    }

    return _t(
      '예산을 $remainingLabel 초과했습니다. 월간 잔액은 ${balanceAmount >= 0 ? '+' : '-'}$balanceLabel입니다.',
      'You are $remainingLabel over budget. Your monthly balance is ${balanceAmount >= 0 ? '+' : '-'}$balanceLabel.',
    );
  }

  /// Builds the primary insight narrative from the highest expense category.
  String insightsPrimaryBodyFor({
    required LedgerCategory? topExpenseCategory,
    required int monthlyExpenseAmount,
  }) {
    if (topExpenseCategory == null) {
      return _t(
        '기록이 충분하지 않아 가장 큰 지출 축을 아직 판단할 수 없습니다.',
        'There is not enough data yet to identify the main expense driver.',
      );
    }

    return _t(
      '${ledgerCategoryLabel(topExpenseCategory)} 항목이 이번 달 ${formatCurrency(monthlyExpenseAmount)} 지출 흐름에서 가장 큰 영향을 주고 있어요.',
      '${ledgerCategoryLabel(topExpenseCategory)} is currently the biggest driver in your ${formatCurrency(monthlyExpenseAmount)} monthly spending.',
    );
  }

  /// Builds the secondary insight narrative from the next category to review.
  String insightsSecondaryBodyFor({
    required LedgerCategory? secondaryExpenseCategory,
    required int recentExpenseCount,
  }) {
    if (secondaryExpenseCategory == null) {
      return _t(
        '거래가 더 쌓이면 다음으로 점검할 카테고리를 더 정확하게 제안할 수 있어요.',
        'Record more transactions and the app will suggest the next category to review more accurately.',
      );
    }

    return _t(
      '최근 $recentExpenseCount건의 지출을 보면 ${ledgerCategoryLabel(secondaryExpenseCategory)} 항목도 함께 점검할 가치가 있어요.',
      'Across your last $recentExpenseCount expense records, ${ledgerCategoryLabel(secondaryExpenseCategory)} also looks worth reviewing.',
    );
  }

  /// Builds the budget insight narrative from the remaining budget state.
  String insightsBudgetBodyFor(int remainingBudgetAmount) {
    if (remainingBudgetAmount >= 0) {
      return _t(
        '이번 달 예산에서 ${formatCurrency(remainingBudgetAmount)}이 남아 있습니다. 지금 속도를 유지하면 월말까지 안정적으로 관리할 수 있어요.',
        '${formatCurrency(remainingBudgetAmount)} remains in this month’s budget. If you keep this pace, the month should stay stable.',
      );
    }

    return _t(
      '이번 달 예산을 ${formatCurrency(remainingBudgetAmount.abs())} 초과했습니다. 큰 지출 카테고리부터 먼저 조정하는 편이 좋습니다.',
      'You are ${formatCurrency(remainingBudgetAmount.abs())} over budget this month. Start by adjusting the largest expense category first.',
    );
  }

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
      '이번 달 목표의 $goalProgressPercent%를 채웠고, $streakLabel째 기록을 이어가고 있어요.',
      "You have completed $goalProgressPercent% of this month's goal and kept the routine for $streakLabel.",
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

  /// Returns an English month abbreviation used in compact date labels.
  String _englishMonth(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[month - 1];
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
