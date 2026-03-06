class ConsentState {
  const ConsentState({
    required this.initialized,
    required this.canRequestAds,
    required this.serveNonPersonalizedAds,
    required this.privacyOptionsRequired,
    this.errorMessage,
  });

  factory ConsentState.initial() => const ConsentState(
    initialized: false,
    canRequestAds: false,
    serveNonPersonalizedAds: true,
    privacyOptionsRequired: false,
  );

  final bool initialized;
  final bool canRequestAds;
  final bool serveNonPersonalizedAds;
  final bool privacyOptionsRequired;
  final String? errorMessage;

  ConsentState copyWith({
    bool? initialized,
    bool? canRequestAds,
    bool? serveNonPersonalizedAds,
    bool? privacyOptionsRequired,
    String? errorMessage,
  }) {
    return ConsentState(
      initialized: initialized ?? this.initialized,
      canRequestAds: canRequestAds ?? this.canRequestAds,
      serveNonPersonalizedAds:
          serveNonPersonalizedAds ?? this.serveNonPersonalizedAds,
      privacyOptionsRequired:
          privacyOptionsRequired ?? this.privacyOptionsRequired,
      errorMessage: errorMessage,
    );
  }
}
