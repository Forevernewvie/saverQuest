import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_placement.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_result.dart';
import 'package:flutter_saverquest_mvp/core/ads/ad_service.dart';
import 'package:flutter_saverquest_mvp/widgets/ad_banner_slot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/widget_test_app.dart';

class _ThrowingAdService implements AdService {
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
    throw StateError('banner build failed');
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
  }) async => AdShowStatus.blockedNoConsent;

  @override
  Future<RewardedAdResult> showRewarded({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async => const RewardedAdResult(
    status: AdShowStatus.blockedNoConsent,
    rewardEarned: false,
  );
}

void main() {
  testWidgets('falls back to placeholder when banner creation throws', (
    tester,
  ) async {
    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: AdBannerSlot(
            adService: _ThrowingAdService(),
            adUnitId: 'test-banner',
            placement: AdPlacement.homeBanner,
            routeName: '/home',
            canRequestAds: true,
            nonPersonalizedAds: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Partner area loading'), findsOneWidget);
    expect(tester.takeException(), isA<StateError>());
  });
}
