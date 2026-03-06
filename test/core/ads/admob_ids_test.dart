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

  test('interstitial and rewarded are optional until ids are provided', () {
    expect(AdMobIds.hasToolInterstitial, isFalse);
    expect(AdMobIds.hasReportRewarded, isFalse);
  });
}
