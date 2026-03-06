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
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant AdBannerSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canRequestAds != widget.canRequestAds) {
      _retryCount = 0;
      _disposeBanner();
      _loadBanner();
    }
  }

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

  void _scheduleRetry() {
    if (!mounted || _retryCount >= 2) {
      return;
    }

    _retryCount += 1;
    final delay = Duration(seconds: _retryCount * 2);
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, _loadBanner);
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canRequestAds) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null || !_isLoaded) {
      return Semantics(
        label: context.l10n.adBannerPlaceholder,
        child: Container(
          height: 52,
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
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
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
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
