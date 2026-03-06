import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  /// Logs the initial insights screen impression for analytics.
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('insights');
  }

  /// Builds the insights screen from repository-provided summary content.
  @override
  Widget build(BuildContext context) {
    final insightsContent = widget.dependencies.contentRepository
        .getInsightsContent();
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.insightsTitle,
      children: [
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.insightsTitle,
          body: l10n.insightsHeroBody,
          trailing: const AppHeroIcon(icon: Icons.auto_graph_outlined),
        ),
        AppSectionHeader(
          title: l10n.insightsNoAdTitle,
          subtitle: l10n.insightsNoAdBody,
        ),
        AppFeatureCard(
          icon: Icons.thumb_up_alt_outlined,
          title: l10n.insightsSegmentATitle,
          body: l10n.insightsSegmentABodyFor(
            insightsContent.positiveCategories,
          ),
        ),
        AppFeatureCard(
          icon: Icons.lightbulb_outline,
          title: l10n.insightsSegmentBTitle,
          body: l10n.insightsSegmentBBodyFor(
            insightsContent.nextFocusCategories,
          ),
        ),
        AppFeatureCard(
          icon: Icons.check_circle_outline,
          title: l10n.insightsResultTitle,
          body: l10n.insightsResultBody,
        ),
      ],
    );
  }
}
