import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import 'ad_guardrails.dart';
import 'ad_placement.dart';
import 'ad_result.dart';
import 'ad_service.dart';

class GoogleMobileAdService implements AdService {
  GoogleMobileAdService({
    required AnalyticsService analyticsService,
    required AdGuardrails guardrails,
    List<String> testDeviceIds = const [],
  }) : _analyticsService = analyticsService,
       _guardrails = guardrails,
       _testDeviceIds = testDeviceIds;

  final AnalyticsService _analyticsService;
  final AdGuardrails _guardrails;
  final List<String> _testDeviceIds;

  final Map<AdPlacement, int> _sessionShownCount = {};
  final Map<AdPlacement, DateTime> _lastShownAt = {};
  DateTime _rewardedCounterDate = DateTime.now();
  int _rewardedShownToday = 0;

  bool get _isAdEnabledPlatform =>
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> initialize() async {
    if (!_isAdEnabledPlatform) {
      await _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {'placement': 'global', 'reason': 'unsupported_platform'},
      );
      return;
    }

    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.pg,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        testDeviceIds: _testDeviceIds.isEmpty ? null : _testDeviceIds,
      ),
    );
    await _analyticsService.logEvent(
      AnalyticsEvents.adRequestConfigApplied,
      parameters: {
        'max_ad_content_rating': MaxAdContentRating.pg,
        'has_test_device_ids': _testDeviceIds.isNotEmpty,
        'test_device_id_count': _testDeviceIds.length,
      },
    );
    await MobileAds.instance.initialize();
  }

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
    if (!_isAdEnabledPlatform) {
      return null;
    }

    final blockedStatus = _guard(
      placement: placement,
      routeName: routeName,
      canRequestAds: canRequestAds,
    );
    if (blockedStatus != null) {
      _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {'placement': placement.key, 'reason': blockedStatus.name},
      );
      return null;
    }

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: AdRequest(nonPersonalizedAds: nonPersonalizedAds),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: {'placement': placement.key, 'type': 'banner'},
          );
          onAdLoaded(ad);
        },
        onAdImpression: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adImpression,
            parameters: {'placement': placement.key, 'type': 'banner'},
          );
        },
        onAdClicked: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adClick,
            parameters: {'placement': placement.key, 'type': 'banner'},
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _analyticsService.logEvent(
            AnalyticsEvents.adLoadFailed,
            parameters: {
              'placement': placement.key,
              'type': 'banner',
              'error': error.message,
            },
          );
          onAdFailedToLoad(error);
        },
      ),
    );

    _analyticsService.logEvent(
      AnalyticsEvents.adRequest,
      parameters: {'placement': placement.key, 'type': 'banner'},
    );

    return ad;
  }

  @override
  Future<AdShowStatus> showInterstitial({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async {
    if (!_isAdEnabledPlatform) {
      return AdShowStatus.blockedUnsupportedPlatform;
    }

    final blockedStatus = _guard(
      placement: placement,
      routeName: routeName,
      canRequestAds: canRequestAds,
    );
    if (blockedStatus != null) {
      await _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {'placement': placement.key, 'reason': blockedStatus.name},
      );
      return blockedStatus;
    }

    final completer = Completer<AdShowStatus>();

    await _analyticsService.logEvent(
      AnalyticsEvents.adRequest,
      parameters: {'placement': placement.key, 'type': 'interstitial'},
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(nonPersonalizedAds: nonPersonalizedAds),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: {'placement': placement.key, 'type': 'interstitial'},
          );

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _markShown(placement);
              _analyticsService.logEvent(
                AnalyticsEvents.interstitialShown,
                parameters: {'placement': placement.key},
              );
              _analyticsService.logEvent(
                AnalyticsEvents.adImpression,
                parameters: {
                  'placement': placement.key,
                  'type': 'interstitial',
                },
              );
            },
            onAdClicked: (ad) {
              _analyticsService.logEvent(
                AnalyticsEvents.adClick,
                parameters: {
                  'placement': placement.key,
                  'type': 'interstitial',
                },
              );
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(AdShowStatus.shown);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(AdShowStatus.loadFailed);
              }
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoadFailed,
            parameters: {
              'placement': placement.key,
              'type': 'interstitial',
              'error': error.message,
            },
          );
          if (!completer.isCompleted) {
            completer.complete(AdShowStatus.loadFailed);
          }
        },
      ),
    );

    return completer.future;
  }

  @override
  Future<RewardedAdResult> showRewarded({
    required String adUnitId,
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
    required bool nonPersonalizedAds,
  }) async {
    if (!_isAdEnabledPlatform) {
      return const RewardedAdResult(
        status: AdShowStatus.blockedUnsupportedPlatform,
        rewardEarned: false,
      );
    }

    _rollDailyRewardCounterIfNeeded();

    final blockedStatus = _guard(
      placement: placement,
      routeName: routeName,
      canRequestAds: canRequestAds,
    );
    if (blockedStatus != null) {
      await _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {'placement': placement.key, 'reason': blockedStatus.name},
      );
      return RewardedAdResult(status: blockedStatus, rewardEarned: false);
    }

    final completer = Completer<RewardedAdResult>();
    var earnedReward = false;

    await _analyticsService.logEvent(
      AnalyticsEvents.rewardRequested,
      parameters: {'placement': placement.key},
    );

    await _analyticsService.logEvent(
      AnalyticsEvents.adRequest,
      parameters: {'placement': placement.key, 'type': 'rewarded'},
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(nonPersonalizedAds: nonPersonalizedAds),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: {'placement': placement.key, 'type': 'rewarded'},
          );

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _markShown(placement);
              _rewardedShownToday += 1;
              _analyticsService.logEvent(
                AnalyticsEvents.adImpression,
                parameters: {'placement': placement.key, 'type': 'rewarded'},
              );
            },
            onAdClicked: (ad) {
              _analyticsService.logEvent(
                AnalyticsEvents.adClick,
                parameters: {'placement': placement.key, 'type': 'rewarded'},
              );
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  RewardedAdResult(
                    status: earnedReward
                        ? AdShowStatus.shown
                        : AdShowStatus.loadFailed,
                    rewardEarned: earnedReward,
                  ),
                );
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(
                  const RewardedAdResult(
                    status: AdShowStatus.loadFailed,
                    rewardEarned: false,
                  ),
                );
              }
            },
          );

          ad.show(
            onUserEarnedReward: (_, reward) {
              earnedReward = true;
              _analyticsService.logEvent(
                AnalyticsEvents.rewardGranted,
                parameters: {
                  'placement': placement.key,
                  'amount': reward.amount.toInt(),
                  'type': reward.type,
                },
              );
            },
          );
        },
        onAdFailedToLoad: (error) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoadFailed,
            parameters: {
              'placement': placement.key,
              'type': 'rewarded',
              'error': error.message,
            },
          );
          if (!completer.isCompleted) {
            completer.complete(
              const RewardedAdResult(
                status: AdShowStatus.loadFailed,
                rewardEarned: false,
              ),
            );
          }
        },
      ),
    );

    return completer.future;
  }

  AdShowStatus? _guard({
    required AdPlacement placement,
    required String routeName,
    required bool canRequestAds,
  }) {
    if (!canRequestAds) {
      return AdShowStatus.blockedNoConsent;
    }

    if (_guardrails.isBlockedRoute(routeName)) {
      return AdShowStatus.blockedNoAdZone;
    }

    final lastShown = _lastShownAt[placement];
    if (lastShown != null) {
      final elapsed = DateTime.now().difference(lastShown);
      if (elapsed < _guardrails.cooldown(placement)) {
        return AdShowStatus.blockedCooldown;
      }
    }

    if (placement == AdPlacement.reportRewarded) {
      _rollDailyRewardCounterIfNeeded();
      if (_rewardedShownToday >= _guardrails.rewardedDailyCap) {
        return AdShowStatus.blockedFrequencyCap;
      }
      return null;
    }

    final shownCount = _sessionShownCount[placement] ?? 0;
    if (shownCount >= _guardrails.perSessionCap(placement)) {
      return AdShowStatus.blockedFrequencyCap;
    }

    return null;
  }

  void _markShown(AdPlacement placement) {
    _lastShownAt[placement] = DateTime.now();
    _sessionShownCount.update(
      placement,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  void _rollDailyRewardCounterIfNeeded() {
    final now = DateTime.now();
    if (now.year != _rewardedCounterDate.year ||
        now.month != _rewardedCounterDate.month ||
        now.day != _rewardedCounterDate.day) {
      _rewardedCounterDate = now;
      _rewardedShownToday = 0;
    }
  }

  @override
  Future<void> dispose() async {}
}
