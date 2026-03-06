import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/ad_result.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/analytics/analytics_events.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import 'domain/savings_calculator.dart';
import '../../widgets/common/app_blocks.dart';
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
  bool _hasCalculated = false;
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
      _hasCalculated = true;
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
    final yearlySavings = _monthlySavings * 12;

    return ScreenShell(
      title: l10n.toolTitle,
      children: [
        AppHeroCard(
          eyebrow: l10n.navTool,
          title: l10n.toolHeroTitle,
          body: l10n.toolHeroBody,
          trailing: const AppHeroIcon(icon: Icons.calculate_outlined),
        ),
        AppSectionHeader(
          title: l10n.toolInputSectionTitle,
          subtitle: l10n.toolInputSectionBody,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              TextField(
                controller: _beforeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.toolCurrentPriceLabel,
                ),
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
                decoration: InputDecoration(
                  labelText: l10n.toolMonthlyCountLabel,
                ),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: _runCalculation,
          child: Text(l10n.toolCalculate),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.report),
          child: Text(l10n.toolGoToReport),
        ),
        const SizedBox(height: AppSpacing.l),
        AppSectionHeader(title: l10n.toolSimulationResultTitle),
        if (_validationError != null)
          AsyncFeedback.error(
            label: _validationError!,
            onRetry: () => setState(() => _validationError = null),
          )
        else
          _SavingsResultCard(
            hasCalculated: _hasCalculated,
            monthlyLabel: l10n.toolMonthlyResultLabel,
            yearlyLabel: l10n.toolYearlyResultLabel,
            monthlySavings: _monthlySavings,
            yearlySavings: yearlySavings,
            body: _hasCalculated
                ? l10n.toolSimulationResultBody(
                    monthlySavings: _monthlySavings,
                    latestStatus: l10n.adStatusLabel(_lastAdStatus),
                  )
                : l10n.toolEmptyResultBody,
          ),
      ],
    );
  }
}

class _SavingsResultCard extends StatelessWidget {
  const _SavingsResultCard({
    required this.hasCalculated,
    required this.monthlyLabel,
    required this.yearlyLabel,
    required this.monthlySavings,
    required this.yearlySavings,
    required this.body,
  });

  final bool hasCalculated;
  final String monthlyLabel;
  final String yearlyLabel;
  final int monthlySavings;
  final int yearlySavings;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCalculated)
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                AppMetricPill(
                  label: monthlyLabel,
                  value: '$monthlySavings원',
                ),
                AppMetricPill(
                  label: yearlyLabel,
                  value: '$yearlySavings원',
                ),
              ],
            ),
          if (hasCalculated) const SizedBox(height: AppSpacing.m),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
