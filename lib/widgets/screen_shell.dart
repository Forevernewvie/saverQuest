import 'package:flutter/material.dart';

import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_ui_tokens.dart';

/// Provides the shared page scaffold, ambient background, and width constraints.
class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  /// Builds the standard page shell used by feature screens.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundAlt],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: AppUiTokens.ambientGlowTopOffset,
              right: AppUiTokens.ambientGlowRightOffset,
              child: IgnorePointer(
                child: Container(
                  width: AppUiTokens.ambientGlowSize,
                  height: AppUiTokens.ambientGlowSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.accentSoft, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppUiTokens.maxContentWidth,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.m,
                      AppSpacing.l,
                      AppSpacing.xl,
                    ),
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
