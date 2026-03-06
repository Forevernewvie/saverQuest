import 'package:flutter/material.dart';

import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';

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
              top: -80,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
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
                  constraints: const BoxConstraints(maxWidth: 560),
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
