import 'package:flutter/widgets.dart';

import 'app_ui_tokens.dart';

/// Centralizes responsive layout rules for narrow screens and larger text sizes.
class AdaptiveLayout {
  const AdaptiveLayout._();

  /// Returns the current effective text scale normalized around `1.0`.
  static double textScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1);
  }

  /// Returns whether surfaces should switch to stacked layouts.
  static bool useStackedLayout(BuildContext context, double availableWidth) {
    return availableWidth <= AppUiTokens.compactLayoutWidth ||
        textScale(context) >= AppUiTokens.largeTextScaleThreshold;
  }
}
