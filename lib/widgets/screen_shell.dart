import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_ui_tokens.dart';
import '../core/localization/app_localizations.dart';

/// Provides the shared page scaffold, ambient background, and width constraints.
class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.primaryNavigationRoute,
    this.showAppBar = true,
    this.centerContent = false,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final String? primaryNavigationRoute;
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
      bottomNavigationBar: primaryNavigationRoute == null
          ? null
          : _PrimaryNavigationBar(currentRoute: primaryNavigationRoute!),
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
                  : Center(child: ListView(children: [constrainedContent]));
            },
          ),
        ),
      ),
    );
  }
}

class _PrimaryNavigationBar extends StatelessWidget {
  const _PrimaryNavigationBar({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      (
        route: AppRoutes.home,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      (
        route: AppRoutes.tool,
        icon: const Icon(Icons.edit_note_outlined),
        selectedIcon: const Icon(Icons.edit_note),
        label: l10n.navTool,
      ),
      (
        route: AppRoutes.report,
        icon: const Icon(Icons.pie_chart_outline),
        selectedIcon: const Icon(Icons.pie_chart),
        label: l10n.navReport,
      ),
      (
        route: AppRoutes.insights,
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights),
        label: l10n.navInsights,
      ),
    ];

    final selectedIndex = destinations.indexWhere(
      (destination) => destination.route == currentRoute,
    );

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
            label: destination.label,
          ),
      ],
      onDestinationSelected: (index) {
        final nextRoute = destinations[index].route;
        if (nextRoute == currentRoute) {
          return;
        }
        Navigator.pushReplacementNamed(context, nextRoute);
      },
    );
  }
}
