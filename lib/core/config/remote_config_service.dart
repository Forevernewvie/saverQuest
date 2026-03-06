import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../logging/app_logger.dart';

class RemoteConfigService {
  /// Creates a remote-config service with injectable logging and backend access.
  RemoteConfigService({
    required AppLogger logger,
    FirebaseRemoteConfig? remoteConfig,
  }) : _logger = logger,
       _remoteConfig = remoteConfig;

  final AppLogger _logger;
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

  /// Loads runtime ad guardrails while preserving safe defaults on failure.
  Future<void> initialize() async {
    if (_remoteConfig == null) {
      _logger.info(
        'Remote config unavailable. Using defaults.',
        scope: 'remote-config',
      );
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

      _logger.info(
        'Remote config values loaded.',
        scope: 'remote-config',
        metadata: {
          'interstitialInterval': _interstitialInterval,
          'interstitialCooldownSec': _interstitialCooldownSec,
          'rewardedDailyCap': _rewardedDailyCap,
        },
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Remote config failed. Falling back to defaults.',
        scope: 'remote-config',
      );
      _logger.error(
        'Remote config exception captured.',
        scope: 'remote-config',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
