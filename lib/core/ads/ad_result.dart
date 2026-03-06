enum AdShowStatus {
  shown,
  blockedNoConsent,
  blockedNoAdZone,
  blockedCooldown,
  blockedFrequencyCap,
  blockedUnsupportedPlatform,
  loadFailed,
}

class RewardedAdResult {
  const RewardedAdResult({required this.status, required this.rewardEarned});

  final AdShowStatus status;
  final bool rewardEarned;
}
