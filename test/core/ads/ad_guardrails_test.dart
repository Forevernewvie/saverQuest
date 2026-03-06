import 'package:flutter_saverquest_mvp/core/ads/ad_guardrails.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_placement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdGuardrails', () {
    final guardrails = AdGuardrails(
      interstitialInterval: 3,
      interstitialCooldownSec: 45,
      rewardedDailyCap: 2,
    );

    test('blocks onboarding and insights routes', () {
      expect(guardrails.isBlockedRoute('/onboarding'), isTrue);
      expect(guardrails.isBlockedRoute('/insights'), isTrue);
      expect(guardrails.isBlockedRoute('/home'), isFalse);
    });

    test('uses configured cooldown for interstitial', () {
      expect(
        guardrails.cooldown(AdPlacement.toolInterstitial),
        const Duration(seconds: 45),
      );
    });

    test('uses configured cap for rewarded', () {
      expect(guardrails.perSessionCap(AdPlacement.reportRewarded), 2);
    });
  });
}
