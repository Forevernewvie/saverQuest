import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig;

  final FirebaseRemoteConfig? _remoteConfig;

  static const int _defaultInterstitialInterval = 3;
  static const int _defaultInterstitialCooldownSec = 45;
  static const int _defaultRewardedDailyCap = 2;

  int _interstitialInterval = _defaultInterstitialInterval;
  int _interstitialCooldownSec = _defaultInterstitialCooldownSec;
  int _rewardedDailyCap = _defaultRewardedDailyCap;

  int get interstitialInterval => _interstitialInterval;
  int get interstitialCooldownSec => _interstitialCooldownSec;
  int get rewardedDailyCap => _rewardedDailyCap;

  Future<void> initialize() async {
    if (_remoteConfig == null) {
      developer.log('[remote-config] unavailable. using defaults.');
      return;
    }

    try {
      await _remoteConfig.setDefaults(const {
        'interstitial_interval': _defaultInterstitialInterval,
        'interstitial_cooldown_sec': _defaultInterstitialCooldownSec,
        'rewarded_daily_cap': _defaultRewardedDailyCap,
      });

      await _remoteConfig.fetchAndActivate();

      _interstitialInterval = _remoteConfig.getInt('interstitial_interval');
      _interstitialCooldownSec = _remoteConfig.getInt(
        'interstitial_cooldown_sec',
      );
      _rewardedDailyCap = _remoteConfig.getInt('rewarded_daily_cap');

      developer.log(
        '[remote-config] loaded: interstitialInterval=$_interstitialInterval, cooldown=$_interstitialCooldownSec, rewardedDailyCap=$_rewardedDailyCap',
      );
    } catch (error) {
      developer.log('[remote-config] failed. using defaults. $error');
    }
  }
}
