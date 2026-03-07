import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ads/ad_placement.dart';
import '../core/ads/ad_service.dart';
import '../core/design/app_colors.dart';
import '../core/localization/app_localizations.dart';

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({
    super.key,
    required this.adService,
    required this.adUnitId,
    required this.placement,
    required this.routeName,
    required this.canRequestAds,
    required this.nonPersonalizedAds,
  });

  final AdService adService;
  final String adUnitId;
  final AdPlacement placement;
  final String routeName;
  final bool canRequestAds;
  final bool nonPersonalizedAds;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  static const int _maxRetryCount = 2;
  static const int _retryDelayMultiplierSec = 2;
  static const double _placeholderHeight = 52;
  static const double _placeholderTopMargin = 4;
  static const double _placeholderHorizontalPadding = 16;
  static const double _placeholderSegmentHeight = 10;
  static const double _placeholderSegmentSpacing = 8;
  static const double _bannerVerticalPadding = 8;
  static const double _bannerCornerRadius = 18;

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  /// Starts the initial banner load when the widget enters the tree.
  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  /// Reloads the banner when consent availability changes.
  @override
  void didUpdateWidget(covariant AdBannerSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canRequestAds != widget.canRequestAds) {
      _retryCount = 0;
      _disposeBanner();
      _loadBanner();
    }
  }

  /// Requests a banner ad from the injected ad service.
  void _loadBanner() {
    final ad = widget.adService.buildBannerAd(
      adUnitId: widget.adUnitId,
      placement: widget.placement,
      routeName: widget.routeName,
      canRequestAds: widget.canRequestAds,
      nonPersonalizedAds: widget.nonPersonalizedAds,
      onAdLoaded: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (_) {
        _scheduleRetry();
      },
    );

    if (ad == null) {
      setState(() {
        _isLoaded = false;
      });
      return;
    }

    _bannerAd = ad..load();
  }

  /// Schedules a bounded retry to avoid infinite banner load churn.
  void _scheduleRetry() {
    if (!mounted || _retryCount >= _maxRetryCount) {
      return;
    }

    _retryCount += 1;
    final delay = Duration(seconds: _retryCount * _retryDelayMultiplierSec);
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, _loadBanner);
  }

  /// Disposes any previously allocated banner instance.
  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  /// Cancels pending retries and disposes the banner on widget teardown.
  @override
  void dispose() {
    _retryTimer?.cancel();
    _disposeBanner();
    super.dispose();
  }

  /// Builds either a placeholder, nothing, or the live banner widget.
  @override
  Widget build(BuildContext context) {
    if (!widget.canRequestAds) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null || !_isLoaded) {
      return Semantics(
        label: context.l10n.adBannerPlaceholder,
        child: Container(
          height: _placeholderHeight,
          margin: const EdgeInsets.only(top: _placeholderTopMargin),
          padding: const EdgeInsets.symmetric(
            horizontal: _placeholderHorizontalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(_bannerCornerRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: _placeholderSegmentHeight,
                  margin: EdgeInsets.only(
                    right: index == 2 ? 0 : _placeholderSegmentSpacing,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: context.l10n.adBannerSemanticLabel,
      child: Container(
        margin: const EdgeInsets.only(top: _placeholderTopMargin),
        padding: const EdgeInsets.symmetric(vertical: _bannerVerticalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(_bannerCornerRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          width: _bannerAd!.size.width.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
