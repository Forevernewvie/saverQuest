import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import '../logging/app_logger.dart';
import 'ad_guardrails.dart';
import 'ad_placement.dart';
import 'ad_result.dart';
import 'ad_service.dart';

class GoogleMobileAdService implements AdService {
  /// Creates an ad service with injectable analytics, logging, and guardrails.
  GoogleMobileAdService({
    required AnalyticsService analyticsService,
    required AppLogger logger,
    required AdGuardrails guardrails,
    List<String> testDeviceIds = const [],
  }) : _analyticsService = analyticsService,
       _logger = logger,
       _guardrails = guardrails,
       _testDeviceIds = testDeviceIds;

  static const String _globalPlacementKey = 'global';
  static const String _bannerType = 'banner';
  static const String _interstitialType = 'interstitial';
  static const String _rewardedType = 'rewarded';

  final AnalyticsService _analyticsService;
  final AppLogger _logger;
  final AdGuardrails _guardrails;
  final List<String> _testDeviceIds;

  final Map<AdPlacement, int> _sessionShownCount = {};
  final Map<AdPlacement, DateTime> _lastShownAt = {};
  DateTime _rewardedCounterDate = DateTime.now();
  int _rewardedShownToday = 0;

  bool get _isAdEnabledPlatform =>
      defaultTargetPlatform == TargetPlatform.android;

  /// Initializes the Google Mobile Ads SDK and logs safe fallback behavior.
  @override
  Future<void> initialize() async {
    if (!_isAdEnabledPlatform) {
      await _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {
          'placement': _globalPlacementKey,
          'reason': 'unsupported_platform',
        },
      );
      return;
    }

    try {
      await MobileAds.instance.updateRequestConfiguration(
        _buildRequestConfiguration(),
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
      _logger.info(
        'Google Mobile Ads initialized.',
        scope: 'ads',
        metadata: {'testDeviceCount': _testDeviceIds.length},
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Google Mobile Ads initialization failed.',
        scope: 'ads',
        error: error,
        stackTrace: stackTrace,
      );
      await _analyticsService.logEvent(
        AnalyticsEvents.adSkipped,
        parameters: {
          'placement': _globalPlacementKey,
          'reason': 'initialize_failed',
        },
      );
    }
  }

  /// Creates a banner ad when platform and guardrail checks permit it.
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
      _logBlockedPlacement(placement: placement, status: blockedStatus);
      return null;
    }

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: _buildAdRequest(nonPersonalizedAds: nonPersonalizedAds),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: _adParameters(
              placement: placement,
              adType: _bannerType,
            ),
          );
          onAdLoaded(ad);
        },
        onAdImpression: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adImpression,
            parameters: _adParameters(
              placement: placement,
              adType: _bannerType,
            ),
          );
        },
        onAdClicked: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adClick,
            parameters: _adParameters(
              placement: placement,
              adType: _bannerType,
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _analyticsService.logEvent(
            AnalyticsEvents.adLoadFailed,
            parameters: _adParameters(
              placement: placement,
              adType: _bannerType,
              extra: {'error': error.message},
            ),
          );
          onAdFailedToLoad(error);
        },
      ),
    );

    _analyticsService.logEvent(
      AnalyticsEvents.adRequest,
      parameters: _adParameters(placement: placement, adType: _bannerType),
    );

    return ad;
  }

  /// Loads and shows an interstitial ad when guardrails permit it.
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
      await _logBlockedPlacement(placement: placement, status: blockedStatus);
      return blockedStatus;
    }

    final completer = Completer<AdShowStatus>();

    await _analyticsService.logEvent(
      AnalyticsEvents.adRequest,
      parameters: _adParameters(
        placement: placement,
        adType: _interstitialType,
      ),
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: _buildAdRequest(nonPersonalizedAds: nonPersonalizedAds),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: _adParameters(
              placement: placement,
              adType: _interstitialType,
            ),
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
                parameters: _adParameters(
                  placement: placement,
                  adType: _interstitialType,
                ),
              );
            },
            onAdClicked: (ad) {
              _analyticsService.logEvent(
                AnalyticsEvents.adClick,
                parameters: _adParameters(
                  placement: placement,
                  adType: _interstitialType,
                ),
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
            parameters: _adParameters(
              placement: placement,
              adType: _interstitialType,
              extra: {'error': error.message},
            ),
          );
          if (!completer.isCompleted) {
            completer.complete(AdShowStatus.loadFailed);
          }
        },
      ),
    );

    return completer.future;
  }

  /// Loads and shows a rewarded ad when guardrails permit it.
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
      await _logBlockedPlacement(placement: placement, status: blockedStatus);
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
      parameters: _adParameters(placement: placement, adType: _rewardedType),
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: _buildAdRequest(nonPersonalizedAds: nonPersonalizedAds),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _analyticsService.logEvent(
            AnalyticsEvents.adLoaded,
            parameters: _adParameters(
              placement: placement,
              adType: _rewardedType,
            ),
          );

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _markShown(placement);
              _rewardedShownToday += 1;
              _analyticsService.logEvent(
                AnalyticsEvents.adImpression,
                parameters: _adParameters(
                  placement: placement,
                  adType: _rewardedType,
                ),
              );
            },
            onAdClicked: (ad) {
              _analyticsService.logEvent(
                AnalyticsEvents.adClick,
                parameters: _adParameters(
                  placement: placement,
                  adType: _rewardedType,
                ),
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
            parameters: _adParameters(
              placement: placement,
              adType: _rewardedType,
              extra: {'error': error.message},
            ),
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

  /// Applies route, cooldown, and cap guardrails to a placement request.
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

  /// Builds a normalized request payload for ad analytics events.
  Map<String, Object> _adParameters({
    required AdPlacement placement,
    required String adType,
    Map<String, Object> extra = const {},
  }) {
    return {'placement': placement.key, 'type': adType, ...extra};
  }

  /// Builds the shared ad request configuration used during SDK setup.
  RequestConfiguration _buildRequestConfiguration() {
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.pg,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      testDeviceIds: _testDeviceIds.isEmpty ? null : _testDeviceIds,
    );
  }

  /// Builds the shared ad request object for placement loads.
  AdRequest _buildAdRequest({required bool nonPersonalizedAds}) {
    return AdRequest(nonPersonalizedAds: nonPersonalizedAds);
  }

  /// Logs a blocked placement in a consistent analytics and logging format.
  Future<void> _logBlockedPlacement({
    required AdPlacement placement,
    required AdShowStatus status,
  }) async {
    _logger.info(
      'Ad request blocked by guardrails.',
      scope: 'ads',
      metadata: {'placement': placement.key, 'reason': status.name},
    );
    await _analyticsService.logEvent(
      AnalyticsEvents.adSkipped,
      parameters: {'placement': placement.key, 'reason': status.name},
    );
  }

  /// Records the latest show time and per-session count for a placement.
  void _markShown(AdPlacement placement) {
    _lastShownAt[placement] = DateTime.now();
    _sessionShownCount.update(
      placement,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  /// Resets the rewarded counter when the calendar day changes.
  void _rollDailyRewardCounterIfNeeded() {
    final now = DateTime.now();
    if (now.year != _rewardedCounterDate.year ||
        now.month != _rewardedCounterDate.month ||
        now.day != _rewardedCounterDate.day) {
      _rewardedCounterDate = now;
      _rewardedShownToday = 0;
    }
  }

  /// Releases ad resources when the service lifecycle ends.
  @override
  Future<void> dispose() async {}
}
