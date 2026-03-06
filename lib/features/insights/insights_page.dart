import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_panel.dart';
import '../../widgets/screen_shell.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('insights');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.insightsTitle,
      children: [
        AppPanel(title: l10n.insightsNoAdTitle, body: l10n.insightsNoAdBody),
        AppPanel(
          title: l10n.insightsSegmentATitle,
          body: l10n.insightsSegmentABody,
        ),
        AppPanel(
          title: l10n.insightsSegmentBTitle,
          body: l10n.insightsSegmentBBody,
        ),
        AppPanel(
          title: l10n.insightsResultTitle,
          body: l10n.insightsResultBody,
        ),
      ],
    );
  }
}
