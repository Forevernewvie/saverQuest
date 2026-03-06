class AdMobIds {
  static const String _googleTestPublisherId = 'ca-app-pub-3940256099942544';

  // Android production banner id (provided by owner).
  static const String homeBanner = String.fromEnvironment(
    'ADMOB_HOME_BANNER',
    defaultValue: 'ca-app-pub-9780094598585299/3566508474',
  );

  static const String reportBanner = String.fromEnvironment(
    'ADMOB_REPORT_BANNER',
    defaultValue: 'ca-app-pub-9780094598585299/3566508474',
  );

  static const String settingsBanner = String.fromEnvironment(
    'ADMOB_SETTINGS_BANNER',
    defaultValue: 'ca-app-pub-9780094598585299/3566508474',
  );

  static const String toolInterstitial = String.fromEnvironment(
    'ADMOB_TOOL_INTERSTITIAL',
    defaultValue: '',
  );

  static const String reportRewarded = String.fromEnvironment(
    'ADMOB_REPORT_REWARDED',
    defaultValue: '',
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
