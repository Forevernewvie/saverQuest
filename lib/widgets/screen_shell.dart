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
    this.centerContent = false,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool centerContent;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final constrainedContent = ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppUiTokens.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.m,
                    AppSpacing.l,
                    AppSpacing.xl,
                  ),
                  child: centerContent
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                AppSpacing.m -
                                AppSpacing.xl,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: children,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                ),
              );

              return centerContent
                  ? Center(child: constrainedContent)
                  : Center(
                      child: ListView(
                        children: [constrainedContent],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
