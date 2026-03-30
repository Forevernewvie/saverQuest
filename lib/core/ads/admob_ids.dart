class AdMobIds {
  static const String _googleTestPublisherId = 'ca-app-pub-3940256099942544';
  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const bool _useProdDefaults = _environment == 'prod';
  static const String _testBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _prodHomeBannerDefault =
      'ca-app-pub-9780094598585299/3566508474';
  static const String _prodReportBannerDefault =
      'ca-app-pub-9780094598585299/3566508474';
  static const String _prodSettingsBannerDefault =
      'ca-app-pub-9780094598585299/3566508474';
  static const String _prodToolInterstitialDefault = '';
  static const String _prodReportRewardedDefault = '';

  // Returns test ad units by default in non-production builds.
  static String get homeBanner => const String.fromEnvironment(
    'ADMOB_HOME_BANNER',
    defaultValue: _useProdDefaults ? _prodHomeBannerDefault : _testBannerUnitId,
  );

  static String get reportBanner => const String.fromEnvironment(
    'ADMOB_REPORT_BANNER',
    defaultValue: _useProdDefaults
        ? _prodReportBannerDefault
        : _testBannerUnitId,
  );

  static String get settingsBanner => const String.fromEnvironment(
    'ADMOB_SETTINGS_BANNER',
    defaultValue: _useProdDefaults
        ? _prodSettingsBannerDefault
        : _testBannerUnitId,
  );

  static String get toolInterstitial => const String.fromEnvironment(
    'ADMOB_TOOL_INTERSTITIAL',
    defaultValue: _useProdDefaults
        ? _prodToolInterstitialDefault
        : _testInterstitialUnitId,
  );

  static String get reportRewarded => const String.fromEnvironment(
    'ADMOB_REPORT_REWARDED',
    defaultValue: _useProdDefaults
        ? _prodReportRewardedDefault
        : _testRewardedUnitId,
  );

  static bool get hasToolInterstitial => toolInterstitial.trim().isNotEmpty;
  static bool get hasReportRewarded => reportRewarded.trim().isNotEmpty;

  static Map<String, String> allUnitIds() {
    return {
      'ADMOB_HOME_BANNER': homeBanner,
      'ADMOB_REPORT_BANNER': reportBanner,
      'ADMOB_SETTINGS_BANNER': settingsBanner,
      'ADMOB_TOOL_INTERSTITIAL': toolInterstitial,
      'ADMOB_REPORT_REWARDED': reportRewarded,
    };
  }

  static List<String> productionReadinessWarnings() {
    if (!_useProdDefaults) {
      return const [];
    }
    final warnings = <String>[];
    allUnitIds().forEach((defineKey, rawUnitId) {
      final unitId = rawUnitId.trim();
      if (unitId.isEmpty &&
          (defineKey == 'ADMOB_HOME_BANNER' ||
              defineKey == 'ADMOB_REPORT_BANNER' ||
              defineKey == 'ADMOB_SETTINGS_BANNER')) {
        warnings.add('$defineKey is empty.');
        return;
      }
      if (unitId.isEmpty) {
        return;
      }
      if (_isGoogleTestUnitId(unitId)) {
        warnings.add('$defineKey is still using Google test ad unit id.');
      }
    });
    return warnings;
  }

  static bool _isGoogleTestUnitId(String unitId) {
    return unitId.startsWith('$_googleTestPublisherId/');
  }
}
