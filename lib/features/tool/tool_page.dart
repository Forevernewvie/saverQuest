import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/ad_result.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import 'domain/savings_calculator.dart';
import '../../widgets/common/app_panel.dart';
import '../../widgets/common/async_feedback.dart';
import '../../widgets/screen_shell.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final TextEditingController _beforeController = TextEditingController(
    text: '12000',
  );
  final TextEditingController _afterController = TextEditingController(
    text: '8500',
  );
  final TextEditingController _countController = TextEditingController(
    text: '14',
  );

  int _calcTapCount = 0;
  int _monthlySavings = 0;
  String? _validationError;
  AdShowStatus? _lastAdStatus;
  final SavingsCalculator _calculator = const SavingsCalculator();

  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('tool');
  }

  @override
  void dispose() {
    _beforeController.dispose();
    _afterController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _runCalculation() async {
    final l10n = context.l10n;
    final before = int.tryParse(_beforeController.text);
    final after = int.tryParse(_afterController.text);
    final count = int.tryParse(_countController.text);

    if (before == null || after == null || count == null) {
      setState(() {
        _validationError = l10n.toolOnlyNumbersAllowed;
      });
      return;
    }

    final input = SavingsCalculationInput(
      beforePrice: before,
      afterPrice: after,
      monthlyCount: count,
    );
    final validationError = _calculator.validate(input);
    if (validationError != null) {
      setState(() {
        _validationError = switch (validationError) {
          SavingsValidationError.beforePriceMustBeGreater =>
            l10n.toolBeforePriceMustBeHigher,
          SavingsValidationError.monthlyCountMustBePositive =>
            l10n.toolMonthlyCountMustBePositive,
        };
      });
      return;
    }

    final savings = _calculator.calculate(input).monthlySavings;

    setState(() {
      _validationError = null;
      _calcTapCount += 1;
      _monthlySavings = savings;
    });

    await widget.dependencies.analyticsService.logEvent(
      AnalyticsEvents.calculatorRun,
      parameters: {'monthly_savings': savings, 'calc_tap_count': _calcTapCount},
    );

    final interval =
        widget.dependencies.remoteConfigService.interstitialInterval;
    if (_calcTapCount % interval == 0 && AdMobIds.hasToolInterstitial) {
      final consentState = widget.dependencies.consentController.state;
      final status = await widget.dependencies.adService.showInterstitial(
        adUnitId: AdMobIds.toolInterstitial,
        placement: AdPlacement.toolInterstitial,
        routeName: AppRoutes.tool,
        canRequestAds: consentState.canRequestAds,
        nonPersonalizedAds: consentState.serveNonPersonalizedAds,
      );

      if (!mounted) {
        return;
      }

      setState(() => _lastAdStatus = status);
      if (status != AdShowStatus.shown) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.toolAdSkippedOrFailed(l10n.adStatusLabel(status)),
            ),
          ),
        );
      }
    } else if (_calcTapCount % interval == 0) {
      setState(() => _lastAdStatus = AdShowStatus.loadFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.toolTitle,
      children: [
        AppPanel(
          title: l10n.toolInterstitialRulesTitle,
          body: l10n.toolInterstitialRulesBody(
            widget.dependencies.remoteConfigService.interstitialInterval,
          ),
        ),
        TextField(
          controller: _beforeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.toolCurrentPriceLabel),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _afterController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.toolAlternativePriceLabel,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _countController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.toolMonthlyCountLabel),
        ),
        const SizedBox(height: AppSpacing.m),
        FilledButton(
          onPressed: _runCalculation,
          child: Text(l10n.toolCalculate),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.report),
          child: Text(l10n.toolGoToReport),
        ),
        const SizedBox(height: AppSpacing.m),
        if (_validationError != null)
          AsyncFeedback.error(
            label: _validationError!,
            onRetry: () => setState(() => _validationError = null),
          )
        else
          AppPanel(
            title: l10n.toolSimulationResultTitle,
            body: l10n.toolSimulationResultBody(
              monthlySavings: _monthlySavings,
              latestStatus: l10n.adStatusLabel(_lastAdStatus),
            ),
          ),
      ],
    );
  }
}
