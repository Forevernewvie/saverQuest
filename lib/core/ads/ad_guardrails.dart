import 'ad_placement.dart';

class AdGuardrails {
  AdGuardrails({
    required this.interstitialInterval,
    required this.interstitialCooldownSec,
    required this.rewardedDailyCap,
  });

  final int interstitialInterval;
  final int interstitialCooldownSec;
  final int rewardedDailyCap;

  static const Set<String> noAdRoutes = {'/onboarding', '/insights'};

  bool isBlockedRoute(String routeName) => noAdRoutes.contains(routeName);

  Duration cooldown(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.toolInterstitial:
        return Duration(seconds: interstitialCooldownSec);
      case AdPlacement.reportRewarded:
        return const Duration(seconds: 30);
      case AdPlacement.homeBanner:
      case AdPlacement.reportBanner:
      case AdPlacement.settingsBanner:
        return Duration.zero;
    }
  }

  int perSessionCap(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.homeBanner:
      case AdPlacement.reportBanner:
      case AdPlacement.settingsBanner:
        return 999;
      case AdPlacement.toolInterstitial:
        return 8;
      case AdPlacement.reportRewarded:
        return rewardedDailyCap;
    }
  }
}
