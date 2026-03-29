import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_saverquest_mvp/core/ads/admob_ids.dart';

void main() {
  test('allUnitIds exposes every expected placement id', () {
    final unitIds = AdMobIds.allUnitIds();

    expect(unitIds.length, 5);
    expect(unitIds.containsKey('ADMOB_HOME_BANNER'), isTrue);
    expect(unitIds.containsKey('ADMOB_REPORT_BANNER'), isTrue);
    expect(unitIds.containsKey('ADMOB_SETTINGS_BANNER'), isTrue);
    expect(unitIds.containsKey('ADMOB_TOOL_INTERSTITIAL'), isTrue);
    expect(unitIds.containsKey('ADMOB_REPORT_REWARDED'), isTrue);
  });

  test('production readiness has no warning for configured banner ids', () {
    final warnings = AdMobIds.productionReadinessWarnings();

    expect(warnings, isEmpty);
  });

  test('non-production defaults use Google test ad unit ids', () {
    expect(AdMobIds.homeBanner, startsWith('ca-app-pub-3940256099942544/'));
    expect(AdMobIds.reportBanner, startsWith('ca-app-pub-3940256099942544/'));
    expect(
      AdMobIds.settingsBanner,
      startsWith('ca-app-pub-3940256099942544/'),
    );
    expect(AdMobIds.hasToolInterstitial, isTrue);
    expect(AdMobIds.hasReportRewarded, isTrue);
  });
}
