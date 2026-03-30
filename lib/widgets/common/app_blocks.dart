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
        fillColor: AppColors.surfaceMuted,
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

/// Arranges one or two child panes based on the current responsive breakpoint.
class AppResponsiveTwoPane extends StatelessWidget {
  const AppResponsiveTwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.spacing = AppSpacing.m,
    this.margin = EdgeInsets.zero,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;
  final EdgeInsetsGeometry margin;

  /// Builds stacked panes on compact layouts and side-by-side panes on wide layouts.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoPane = AdaptiveLayout.useTwoPaneLayout(
            context,
            constraints.maxWidth,
          );

          if (!useTwoPane) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                primary,
                SizedBox(height: spacing),
                secondary,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: primaryFlex, child: primary),
              SizedBox(width: spacing),
              Expanded(flex: secondaryFlex, child: secondary),
            ],
          );
        },
      ),
    );
  }
}

/// Renders a compact month-navigation control for ledger dashboards.
class AppMonthSwitcher extends StatelessWidget {
  const AppMonthSwitcher({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
    required this.nextEnabled,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final bool nextEnabled;

  /// Builds the shared month switcher used by report-style screens.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: _surfaceDecoration(
        fillColor: AppColors.backgroundAlt,
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: l10n.monthSwitcherPreviousSemantic,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: onReset,
                  child: Text(l10n.monthSwitcherCurrentAction),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: nextEnabled ? onNext : null,
            tooltip: l10n.monthSwitcherNextSemantic,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

/// Renders a wrap of selectable filter chips for report exploration.
class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.onSelected,
  });

  final List<({String label, bool selected, Object? value})> options;
  final ValueChanged<Object?> onSelected;

  /// Builds the reusable chip row for category-style filters.
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(option.label),
              selected: option.selected,
              onSelected: (_) => onSelected(option.value),
            ),
          )
          .toList(),
    );
  }
}

/// Carries the display data for one category row inside a compact chart.
class AppCategoryBarChartRowData {
  /// Creates an immutable chart row model.
  const AppCategoryBarChartRowData({
    required this.icon,
    required this.label,
    required this.amount,
    required this.progress,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final String amount;
  final double progress;
  final bool highlighted;
}

/// Renders a compact horizontal category chart for finance reports.
class AppCategoryBarChartCard extends StatelessWidget {
  const AppCategoryBarChartCard({super.key, required this.rows});

  final List<AppCategoryBarChartRowData> rows;

  /// Builds the reusable category distribution chart surface.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _surfaceDecoration(
        fillColor: AppColors.surface,
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: Row(
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
                      child: Icon(
                        row.icon,
                        color: row.highlighted
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.label,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: row.highlighted
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Text(
                                row.amount,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: row.progress.clamp(0, 1),
                              backgroundColor: AppColors.surfaceMuted,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                row.highlighted
                                    ? AppColors.accent
                                    : AppColors.border,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
      _BudgetMetricColumn(
        key: const ValueKey('budget-metric-remaining'),
        label: remainingLabel,
        value: remainingValue,
      ),
      _BudgetMetricColumn(
        key: const ValueKey('budget-metric-spent'),
        label: spentLabel,
        value: spentValue,
      ),
      _BudgetMetricColumn(
        key: const ValueKey('budget-metric-limit'),
        label: limitLabel,
        value: limitValue,
      ),
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
                          child: SizedBox(
                            width: double.infinity,
                            child: metric,
                          ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useStackedTrailing =
                        trailingValue != null &&
                        AdaptiveLayout.useStackedLayout(
                          context,
                          constraints.maxWidth,
                        );

                    return Column(
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
                            if (trailingValue != null &&
                                !useStackedTrailing) ...[
                              const SizedBox(width: AppSpacing.s),
                              Flexible(
                                child: Text(
                                  trailingValue!,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (trailingValue != null && useStackedTrailing) ...[
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            trailingValue!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders an empty-state surface with one primary message and supporting text.
class AppEmptyStateCard extends StatelessWidget {
  const AppEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Builds a calm empty-state card for screens without user records yet.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _surfaceDecoration(
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Column(
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
          const SizedBox(height: AppSpacing.m),
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.m),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders a transaction row with category, note, date, and signed amount.
class AppTransactionTile extends StatelessWidget {
  const AppTransactionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.trailingAction,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.s),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final Widget? trailingAction;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  /// Builds a compact transaction tile for recent activity sections.
  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final shouldStackTrailing =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppUiTokens.featureIconContainerSize,
                    height: AppUiTokens.featureIconContainerSize,
                    decoration: _surfaceDecoration(
                      fillColor: AppColors.surfaceMuted,
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
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!shouldStackTrailing) ...[
                    const SizedBox(width: AppSpacing.m),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 72,
                        maxWidth: 124,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trailing,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (trailingAction != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            trailingAction!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (shouldStackTrailing) ...[
                const SizedBox(height: AppSpacing.s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trailing,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (trailingAction != null) ...[
                      const SizedBox(width: AppSpacing.s),
                      trailingAction!,
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );

    return Container(
      key: key,
      margin: margin,
      decoration: _surfaceDecoration(
        fillColor: AppColors.surfaceAlt,
        borderRadius: AppUiTokens.surfaceCornerRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppUiTokens.surfaceCornerRadius),
          child: content,
        ),
      ),
    );
  }
}

/// Builds a non-scrollable transaction list using builder semantics for stability.
class AppTransactionList extends StatelessWidget {
  const AppTransactionList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Builds a shrink-wrapped transaction list for embedding inside screen sections.
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Renders a bottom sheet with key transaction details and follow-up actions.
class AppTransactionDetailSheet extends StatelessWidget {
  const AppTransactionDetailSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.typeValue,
    required this.categoryValue,
    required this.dateValue,
    required this.noteValue,
    required this.hint,
    this.onEdit,
    this.onDelete,
  });

  final IconData icon;
  final String title;
  final String amount;
  final String typeValue;
  final String categoryValue;
  final String dateValue;
  final String noteValue;
  final String hint;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Builds the reusable bottom sheet used to inspect one transaction entry.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.l,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(
                    AppUiTokens.borderPillRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppUiTokens.heroIconContainerSize,
                  height: AppUiTokens.heroIconContainerSize,
                  decoration: _surfaceDecoration(
                    fillColor: AppColors.surfaceAlt,
                    borderRadius: AppUiTokens.surfaceCornerRadius,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hint,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _AppDetailInfoRow(
              label: AppLocalizations.of(context).toolDetailTypeLabel,
              value: typeValue,
            ),
            _AppDetailInfoRow(
              label: AppLocalizations.of(context).toolDetailCategoryLabel,
              value: categoryValue,
            ),
            _AppDetailInfoRow(
              label: AppLocalizations.of(context).toolDetailDateLabel,
              value: dateValue,
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: _surfaceDecoration(
                fillColor: AppColors.surfaceAlt,
                borderRadius: AppUiTokens.surfaceCornerRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).toolDetailNoteLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    noteValue,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: AppSpacing.l),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useRow = AdaptiveLayout.useTwoPaneLayout(
                    context,
                    constraints.maxWidth,
                  );
                  if (useRow) {
                    return Row(
                      children: [
                        if (onEdit != null)
                          Expanded(
                            child: FilledButton(
                              onPressed: onEdit,
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).toolEditEntryAction,
                              ),
                            ),
                          ),
                        if (onEdit != null && onDelete != null)
                          const SizedBox(width: AppSpacing.s),
                        if (onDelete != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onDelete,
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).toolDeleteEntryAction,
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      if (onEdit != null)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onEdit,
                            child: Text(
                              AppLocalizations.of(context).toolEditEntryAction,
                            ),
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(height: AppSpacing.s),
                      if (onDelete != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onDelete,
                            child: Text(
                              AppLocalizations.of(
                                context,
                              ).toolDeleteEntryAction,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders a compact label-value row inside the transaction detail sheet.
class _AppDetailInfoRow extends StatelessWidget {
  const _AppDetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  /// Builds one metadata row with a muted label and primary value.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
  const _BudgetMetricColumn({
    super.key,
    required this.label,
    required this.value,
  });

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
