import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class ConsentPlatform {
  void requestConsentInfoUpdate({
    required void Function() onConsentInfoUpdateSuccess,
    required void Function(FormError error) onConsentInfoUpdateFailure,
  });

  void loadAndShowConsentFormIfRequired(void Function(FormError? error) onDone);

  Future<void> showPrivacyOptionsForm(void Function(FormError? error) onDone);

  Future<bool> canRequestAds();

  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus();
}

class GoogleMobileAdsConsentPlatform implements ConsentPlatform {
  const GoogleMobileAdsConsentPlatform();

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus() {
    return ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
  }

  @override
  void loadAndShowConsentFormIfRequired(
    void Function(FormError? error) onDone,
  ) {
    ConsentForm.loadAndShowConsentFormIfRequired(onDone);
  }

  @override
  void requestConsentInfoUpdate({
    required void Function() onConsentInfoUpdateSuccess,
    required void Function(FormError error) onConsentInfoUpdateFailure,
  }) {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      onConsentInfoUpdateSuccess,
      onConsentInfoUpdateFailure,
    );
  }

  @override
  Future<void> showPrivacyOptionsForm(void Function(FormError? error) onDone) {
    return ConsentForm.showPrivacyOptionsForm(onDone);
  }
}
