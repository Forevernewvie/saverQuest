import 'package:flutter/material.dart';

import '../../core/design/adaptive_layout.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_ui_tokens.dart';
import '../../core/localization/app_localizations.dart';

/// Renders a section title with an optional supporting subtitle.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  /// Builds the standard section header typography block.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders a prominent hero card with CTAs and supporting metrics.
class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    this.eyebrow,
    required this.title,
    required this.body,
    this.trailing,
    this.pills = const [],
    this.primaryLabel,
    this.primarySemanticLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String? eyebrow;
  final String title;
  final String body;
  final Widget? trailing;
  final List<Widget> pills;
  final String? primaryLabel;
  final String? primarySemanticLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Builds the high-emphasis hero surface used at the top of major screens.
  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          body,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedHeader = AdaptiveLayout.useStackedLayout(
          context,
          constraints.maxWidth,
        );
        final pillsContent = useStackedHeader
            ? Column(
                children: pills
                    .map(
                      (pill) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: SizedBox(width: double.infinity, child: pill),
                      ),
                    )
                    .toList(),
              )
            : Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: pills,
              );

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.heroCornerRadius),
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (useStackedHeader) ...[
                if (trailing != null) ...[
                  Align(alignment: Alignment.centerRight, child: trailing!),
                  const SizedBox(height: AppSpacing.m),
                ],
                textContent,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: textContent),
                    if (trailing != null) ...[
                      const SizedBox(width: AppSpacing.m),
                      trailing!,
                    ],
                  ],
                ),
              if (pills.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.l),
                pillsContent,
              ],
              if (primaryLabel != null && onPrimary != null) ...[
                const SizedBox(height: AppSpacing.l),
                Semantics(
                  label: primarySemanticLabel ?? primaryLabel,
                  button: true,
                  child: FilledButton(
                    onPressed: onPrimary,
                    child: Text(primaryLabel!),
                  ),
                ),
              ],
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: AppSpacing.s),
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Renders a compact summary pill for metrics shown in hero sections.
class AppMetricPill extends StatelessWidget {
  const AppMetricPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  /// Builds a compact summary pill for metrics shown in hero sections.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: _surfaceDecoration(
        fillColor: const Color(0x1AFFFFFF),
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds the accent icon chip used inside hero cards.
class AppHeroIcon extends StatelessWidget {
  const AppHeroIcon({super.key, required this.icon});

  final IconData icon;

  /// Builds the accent icon chip used inside hero cards.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppUiTokens.heroIconContainerSize,
      height: AppUiTokens.heroIconContainerSize,
      decoration: _surfaceDecoration(
        fillColor: const Color(0x1AFFFFFF),
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Icon(
        icon,
        color: AppColors.accent,
        size: AppUiTokens.heroIconSize,
      ),
    );
  }
}

/// Renders a reusable feature card surface with optional interaction.
class AppFeatureCard extends StatelessWidget {
  const AppFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.s),
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  /// Builds the standard feature card used across dashboards and settings.
  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _surfaceDecoration(
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedTrailing =
              trailing != null &&
              AdaptiveLayout.useStackedLayout(context, constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppUiTokens.featureIconContainerSize,
                    height: AppUiTokens.featureIconContainerSize,
                    decoration: _surfaceDecoration(
                      fillColor: AppColors.surfaceAlt,
                      borderRadius: AppUiTokens.cardCornerRadius,
                      showBorder: false,
                    ),
                    child: Icon(icon, color: AppColors.accent),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          body,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null && !useStackedTrailing) ...[
                    const SizedBox(width: AppSpacing.m),
                    trailing!,
                  ],
                ],
              ),
              if (trailing != null && useStackedTrailing) ...[
                const SizedBox(height: AppSpacing.s),
                Align(alignment: Alignment.centerRight, child: trailing!),
              ],
            ],
          );
        },
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppUiTokens.surfaceCornerRadius),
        child: content,
      ),
    );
  }
}

/// Renders a budgeting overview card with progress and key monthly figures.
class AppBudgetOverviewCard extends StatelessWidget {
  const AppBudgetOverviewCard({
    super.key,
    required this.title,
    required this.body,
    required this.progressValue,
    required this.remainingLabel,
    required this.remainingValue,
    required this.spentLabel,
    required this.spentValue,
    required this.limitLabel,
    required this.limitValue,
  });

  final String title;
  final String body;
  final double progressValue;
  final String remainingLabel;
  final String remainingValue;
  final String spentLabel;
  final String spentValue;
  final String limitLabel;
  final String limitValue;

  /// Builds a budget overview card optimized for narrow mobile layouts.
  @override
  Widget build(BuildContext context) {
    final metricItems = [
      _BudgetMetricColumn(label: remainingLabel, value: remainingValue),
      _BudgetMetricColumn(label: spentLabel, value: spentValue),
      _BudgetMetricColumn(label: limitLabel, value: limitValue),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _surfaceDecoration(
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedMetrics = AdaptiveLayout.useStackedLayout(
            context,
            constraints.maxWidth,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                body,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppUiTokens.borderPillRadius,
                ),
                child: LinearProgressIndicator(
                  value: progressValue.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              if (useStackedMetrics)
                Column(
                  children: metricItems
                      .map(
                        (metric) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s),
                          child: metric,
                        ),
                      )
                      .toList(),
                )
              else
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < metricItems.length;
                      index++
                    ) ...[
                      Expanded(child: metricItems[index]),
                      if (index < metricItems.length - 1)
                        const SizedBox(width: AppSpacing.s),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders a compact action card for frequently used navigation targets.
class AppQuickActionCard extends StatelessWidget {
  const AppQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.body,
    required this.onTap,
    this.categoryLabel,
    this.trailingValue,
    this.expandToWidth = true,
  });

  final IconData icon;
  final String label;
  final String body;
  final VoidCallback onTap;
  final String? categoryLabel;
  final String? trailingValue;
  final bool expandToWidth;

  /// Builds the quick action surface with consistent sizing constraints.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: expandToWidth ? 0 : AppUiTokens.quickActionMinWidth,
        maxWidth: expandToWidth
            ? double.infinity
            : AppUiTokens.quickActionMaxWidth,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppUiTokens.surfaceCornerRadius),
          child: Semantics(
            button: true,
            label: label,
            child: Ink(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: _surfaceDecoration(
                fillColor: AppColors.surfaceAlt,
                borderRadius: AppUiTokens.surfaceCornerRadius,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppUiTokens.quickActionMinHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: AppUiTokens.heroIconContainerSize,
                          height: AppUiTokens.heroIconContainerSize,
                          decoration: _surfaceDecoration(
                            fillColor: AppColors.accentSoft,
                            borderRadius: AppUiTokens.cardCornerRadius,
                            showBorder: false,
                          ),
                          child: Icon(icon, color: AppColors.accent),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              if (categoryLabel != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  categoryLabel!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailingValue != null) ...[
                          const SizedBox(width: AppSpacing.s),
                          Text(
                            trailingValue!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      children: [
                        Text(
                          l10n.homeQuickActionOpenLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds the shared border-and-fill decoration used by reusable surfaces.
BoxDecoration _surfaceDecoration({
  Color fillColor = AppColors.surface,
  required double borderRadius,
  bool showBorder = true,
}) {
  return BoxDecoration(
    color: fillColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: showBorder ? Border.all(color: AppColors.border) : null,
  );
}

/// Renders a compact label-value stack inside budget overview cards.
class _BudgetMetricColumn extends StatelessWidget {
  const _BudgetMetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  /// Builds the compact metric surface for budget overview details.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: _surfaceDecoration(
        fillColor: AppColors.surfaceAlt,
        borderRadius: AppUiTokens.cardCornerRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
