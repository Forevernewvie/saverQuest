enum AdPlacement {
  homeBanner,
  reportBanner,
  settingsBanner,
  toolInterstitial,
  reportRewarded,
}

extension AdPlacementKey on AdPlacement {
  String get key {
    switch (this) {
      case AdPlacement.homeBanner:
        return 'home_banner';
      case AdPlacement.reportBanner:
        return 'report_banner';
      case AdPlacement.settingsBanner:
        return 'settings_banner';
      case AdPlacement.toolInterstitial:
        return 'tool_interstitial';
      case AdPlacement.reportRewarded:
        return 'report_rewarded';
    }
  }
}
