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
    this.showAppBar = true,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool showAppBar;

  /// Builds the standard page shell used by feature screens.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: actions,
            )
          : null,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundAlt],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }
}
