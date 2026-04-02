import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/ads/ad_placement.dart';
import '../../core/ads/admob_ids.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/ledger/ledger_models.dart';
import '../../core/ledger/ledger_view_data.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/ad_banner_slot.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/common/ledger_entry_detail_sheet.dart';
import '../../widgets/screen_shell.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  LedgerCategory? _selectedCategory;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  /// Opens the shared transaction detail sheet from the report recent-activity list.
  Future<void> _showEntryDetails(LedgerEntry entry) async {
    final l10n = context.l10n;
    final rowViewData = widget.dependencies.ledgerViewDataFactory
        .buildTransactionRow(
          l10n: l10n,
          entry: entry,
          currency: widget.dependencies.ledgerController.currency,
        );

    await showLedgerEntryDetailSheet(
      context: context,
      entry: entry,
      rowViewData: rowViewData,
      onEdit: () => Navigator.pushNamed(context, AppRoutes.tool),
    );
  }

  Future<void> _showSelectedDaySheet(
    BuildContext context,
    DateTime date,
    List<LedgerEntry> entries,
  ) async {
    final l10n = context.l10n;
    final currency = widget.dependencies.ledgerController.currency;
    final expenseEntries = entries
        .where((entry) => entry.type == LedgerEntryType.expense)
        .toList();
    final expenseTotal = expenseEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.amount,
    );
    final categoryTotals = <LedgerCategory, int>{};
    for (final entry in expenseEntries) {
      categoryTotals.update(
        entry.category,
        (amount) => amount + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }
    LedgerCategory? topCategory;
    int topCategoryAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > topCategoryAmount) {
        topCategory = category;
        topCategoryAmount = amount;
      }
    });
    final rows = entries
        .map(
          (entry) => widget.dependencies.ledgerViewDataFactory.buildTransactionRow(
            l10n: l10n,
            entry: entry,
            currency: currency,
          ),
        )
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: l10n.formatShortDate(date),
                  subtitle: l10n.reportSelectedDaySubtitle(date),
                ),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    AppMetricPill(
                      label: l10n.reportSelectedDaySpentLabel,
                      value: l10n.formatCurrency(
                        expenseTotal,
                        currency: currency,
                      ),
                    ),
                    AppMetricPill(
                      label: l10n.reportSelectedDayCountLabel,
                      value: l10n.reportSelectedDayCountValue(entries.length),
                    ),
                    AppMetricPill(
                      label: l10n.reportSelectedDayTopCategoryLabel,
                      value: topCategory == null
                          ? l10n.noData
                          : l10n.ledgerCategoryLabel(topCategory!),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                if (rows.isEmpty)
                  AppEmptyStateCard(
                    icon: Icons.calendar_month_outlined,
                    title: l10n.reportSelectedDayEmptyTitle,
                    body: l10n.reportSelectedDayEmptyBody,
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: AppTransactionList(
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          final entry = entries[index];
                          return AppTransactionTile(
                            key: ValueKey('selected-day-${entry.id}'),
                            icon: row.icon,
                            title: row.title,
                            subtitle: row.subtitle,
                            trailing: row.trailing,
                            onTap: () => _showEntryDetails(entry),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the top analytics block using one or two columns based on width.
  Widget _buildAnalyticsOverview(
    BuildContext context,
    AppLocalizations l10n,
    LedgerReportViewData viewData,
  ) {
    final budgetCard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.reportBudgetStatusTitle),
        AppFeatureCard(
          icon: Icons.track_changes_outlined,
          title: l10n.reportBudgetStatusTitle,
          body: viewData.budgetStatusBody,
        ),
      ],
    );
    final chartSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.reportChartTitle,
          subtitle: l10n.reportChartSubtitle,
        ),
        if (viewData.chartRows.isNotEmpty)
          AppCategoryBarChartCard(
            rows: viewData.chartRows
                .map(
                  (row) => AppCategoryBarChartRowData(
                    icon: row.icon,
                    label: row.label,
                    amount: row.amountLabel,
                    progress: row.progress,
                    highlighted: row.isHighlighted,
                  ),
                )
                .toList(),
          )
        else
          AppEmptyStateCard(
            icon: Icons.pie_chart_outline,
            title: l10n.reportEmptyTitle,
            body: l10n.reportEmptyBody,
          ),
      ],
    );

    return AppResponsiveTwoPane(
      primary: budgetCard,
      secondary: chartSection,
      spacing: AppSpacing.m,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
    );
  }

  Widget _buildCalendarLegend(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [
          _CalendarLegendChip(
            color: AppColors.reportAccentSoft,
            borderColor: AppColors.border,
            label: l10n.reportCalendarLegendSpent,
          ),
          _CalendarLegendChip(
            color: AppColors.surface,
            borderColor: AppColors.reportAccent,
            label: l10n.reportCalendarLegendSelected,
          ),
          _CalendarLegendChip(
            color: AppColors.surface,
            borderColor: AppColors.accent,
            label: l10n.reportCalendarLegendToday,
          ),
        ],
      ),
    );
  }

  /// Logs the initial report screen impression for analytics.
  @override
  void initState() {
    super.initState();
    widget.dependencies.analyticsService.logScreen('report');
  }

  /// Builds report category cards or an empty-state card when no data exists.
  List<Widget> _buildCategoryTotals(
    BuildContext context,
    List<ReportCategoryCardViewData> categoryTotals,
  ) {
    final l10n = context.l10n;
    if (categoryTotals.isEmpty) {
      return [
        AppEmptyStateCard(
          icon: Icons.pie_chart_outline,
          title: l10n.reportEmptyTitle,
          body: l10n.reportEmptyBody,
          actionLabel: l10n.homePrimaryAction,
          onAction: () => Navigator.pushNamed(context, AppRoutes.tool),
        ),
      ];
    }

    return categoryTotals
        .map(
          (total) => AppFeatureCard(
            icon: total.icon,
            title: total.title,
            body: total.body,
            trailing: Text(
              total.trailing,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
        .toList();
  }

  /// Builds recent transaction rows or an empty-state card when there is no data.
  Widget _buildRecentEntries(
    BuildContext context,
    List<LedgerEntry> recentEntries, {
    required bool hasCategoryFilter,
    required bool hasDateFilter,
    required bool hasSearchFilter,
  }) {
    final l10n = context.l10n;
    if (recentEntries.isEmpty) {
      if (hasSearchFilter) {
        return AppEmptyStateCard(
          icon: Icons.search_off_outlined,
          title: l10n.reportSearchEmptyTitle,
          body: l10n.reportSearchEmptyBody,
        );
      }
      if (hasDateFilter) {
        return AppEmptyStateCard(
          icon: Icons.calendar_month_outlined,
          title: l10n.reportSelectedDayEmptyTitle,
          body: l10n.reportSelectedDayEmptyBody,
        );
      }
      if (hasCategoryFilter) {
        return AppEmptyStateCard(
          icon: Icons.filter_list_off_outlined,
          title: l10n.reportFilteredEmptyTitle,
          body: l10n.reportFilteredEmptyBody,
          actionLabel: l10n.reportFilterAllLabel,
          onAction: () {
            setState(() => _selectedCategory = null);
          },
        );
      }

      return AppEmptyStateCard(
        icon: Icons.receipt_long_outlined,
        title: l10n.reportEmptyTitle,
        body: l10n.reportEmptyBody,
        actionLabel: l10n.homePrimaryAction,
        onAction: () => Navigator.pushNamed(context, AppRoutes.tool),
      );
    }

    return AppTransactionList(
      itemCount: recentEntries.length,
      itemBuilder: (context, index) {
        final entry = recentEntries[index];
        final row = widget.dependencies.ledgerViewDataFactory
            .buildTransactionRow(
              l10n: l10n,
              entry: entry,
              currency: widget.dependencies.ledgerController.currency,
            );

        return AppTransactionTile(
          key: ValueKey(entry.id),
          icon: row.icon,
          title: row.title,
          subtitle: row.subtitle,
          trailing: row.trailing,
          onTap: () => _showEntryDetails(entry),
        );
      },
    );
  }

  bool _matchesSearch(
    AppLocalizations l10n,
    LedgerEntry entry,
    String query,
  ) {
    if (query.isEmpty) {
      return true;
    }
    final normalizedQuery = query.toLowerCase();
    final note = entry.note.trim().toLowerCase();
    final category = l10n.ledgerCategoryLabel(entry.category).toLowerCase();
    final type = l10n.ledgerEntryTypeLabel(entry.type).toLowerCase();
    return note.contains(normalizedQuery) ||
        category.contains(normalizedQuery) ||
        type.contains(normalizedQuery);
  }

  /// Builds the report screen from the live ledger state.
  @override
  Widget build(BuildContext context) {
    final consentState = widget.dependencies.consentController.state;
    final ledgerController = widget.dependencies.ledgerController;
    final monthController = widget.dependencies.ledgerMonthController;

    return AnimatedBuilder(
      animation: Listenable.merge([ledgerController, monthController]),
      builder: (context, _) {
        final l10n = context.l10n;
        final selectedMonth = monthController.selectedMonth;
        final searchQuery = _searchController.text.trim();
        final summary = ledgerController.reportSummary(now: selectedMonth);
        final effectiveCategory =
            summary.expenseTotals.any(
              (total) => total.category == _selectedCategory,
            )
            ? _selectedCategory
            : null;
        final effectiveSelectedDate =
            _selectedDate != null &&
                _selectedDate!.year == selectedMonth.year &&
                _selectedDate!.month == selectedMonth.month
            ? _selectedDate
            : null;
        final viewData = widget.dependencies.ledgerViewDataFactory
            .buildReportViewData(
              l10n: l10n,
              summary: summary,
              selectedMonth: selectedMonth,
              selectedDate: effectiveSelectedDate,
              selectedCategory: effectiveCategory,
            );
        final recentEntrySource = effectiveSelectedDate == null
            ? summary.recentEntries
            : summary.currentMonthEntries;
        final visibleRecentEntries = recentEntrySource.where((entry) {
          final matchesCategory =
              effectiveCategory == null || entry.category == effectiveCategory;
          final matchesDay =
              effectiveSelectedDate == null ||
              _isSameDay(entry.occurredOn, effectiveSelectedDate);
          final matchesSearch = _matchesSearch(l10n, entry, searchQuery);
          return matchesCategory && matchesDay && matchesSearch;
        }).toList();
        final monthEntries = summary.currentMonthEntries;

        return ScreenShell(
          title: l10n.reportTitle,
          primaryNavigationRoute: AppRoutes.report,
          showAppBar: false,
          children: [
            AppHeroCard(
              eyebrow: l10n.navReport,
              title: l10n.reportHeroTitle,
              body: l10n.reportHeroBody,
              accentColor: AppColors.reportAccent,
              accentSoftColor: AppColors.reportAccentSoft,
              trailing: const AppHeroIcon(
                icon: Icons.pie_chart_outline,
                color: AppColors.reportAccent,
                fillColor: AppColors.reportAccentSoft,
              ),
              pills: [
                AppMetricPill(
                  label: l10n.reportStatSavingsLabel,
                  value: viewData.monthlyExpenseValue,
                ),
                AppMetricPill(
                  label: l10n.reportStatTopCategoryLabel,
                  value: viewData.monthlyIncomeValue,
                ),
                AppMetricPill(
                  label: l10n.reportStatDetailLabel,
                  value: viewData.balanceValue,
                ),
              ],
            ),
            AppMonthSwitcher(
              label: l10n.formatMonthYear(selectedMonth),
              onPrevious: () {
                setState(() => _selectedDate = null);
                monthController.showPreviousMonth();
              },
              onNext: () {
                setState(() => _selectedDate = null);
                monthController.showNextMonth();
              },
              onReset: () {
                monthController.resetToCurrentMonth();
                setState(() => _selectedDate = null);
              },
              nextEnabled: !monthController.isCurrentMonth,
            ),
            AppSectionHeader(
              title: l10n.reportCalendarTitle,
              subtitle: l10n.reportCalendarSubtitle,
            ),
            AppMonthlySpendCalendarCard(
              weekdayLabels: [
                for (var index = 0; index < 7; index++)
                  l10n.weekdayLabel(index),
              ],
              days: viewData.calendarDays,
              onSelectDate: (date) async {
                if (date.year != selectedMonth.year || date.month != selectedMonth.month) {
                  return;
                }
                final dayEntries = monthEntries
                    .where((entry) => _isSameDay(entry.occurredOn, date))
                    .toList()
                  ..sort((left, right) => right.occurredOn.compareTo(left.occurredOn));
                setState(() {
                  final sameDay =
                      effectiveSelectedDate != null &&
                      _isSameDay(effectiveSelectedDate, date);
                  _selectedDate = sameDay ? null : date;
                });

                if (dayEntries.isNotEmpty) {
                  await _showSelectedDaySheet(context, date, dayEntries);
                }
              },
            ),
            _buildCalendarLegend(context, l10n),
            AppSectionHeader(title: l10n.reportCalendarStatsTitle),
            ...viewData.calendarStats.map(
              (stat) => AppFeatureCard(
                icon: stat.icon,
                title: stat.title,
                body: stat.body,
                trailing: Text(
                  stat.trailing,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _buildAnalyticsOverview(context, l10n, viewData),
            AppSectionHeader(
              title: l10n.reportFilterTitle,
              subtitle: l10n.reportFilterSubtitle,
            ),
            AppFilterChips(
              options: viewData.categoryFilters
                  .map(
                    (filter) => (
                      label: filter.label,
                      selected: filter.isSelected,
                      value: filter.category,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                setState(() {
                  _selectedCategory = value as LedgerCategory?;
                });
              },
            ),
            const SizedBox(height: AppSpacing.s),
            AppSectionHeader(
              title: l10n.reportSearchTitle,
              subtitle: l10n.reportSearchSubtitle,
            ),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.reportSearchHint,
                suffixIcon: searchQuery.isEmpty
                    ? const Icon(Icons.search_outlined)
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            AppSectionHeader(title: l10n.reportSummaryTitle),
            ..._buildCategoryTotals(context, viewData.categoryTotals),
            AppSectionHeader(
              title: l10n.reportRecentEntriesTitle,
              subtitle: viewData.selectedDaySubtitle,
            ),
            _buildRecentEntries(
              context,
              visibleRecentEntries,
              hasCategoryFilter: effectiveCategory != null,
              hasDateFilter: effectiveSelectedDate != null,
              hasSearchFilter: searchQuery.isNotEmpty,
            ),
            AdBannerSlot(
              adService: widget.dependencies.adService,
              adUnitId: AdMobIds.reportBanner,
              placement: AdPlacement.reportBanner,
              routeName: AppRoutes.report,
              canRequestAds: consentState.canRequestAds,
              nonPersonalizedAds: consentState.serveNonPersonalizedAds,
            ),
          ],
        );
      },
    );
  }
}

class _CalendarLegendChip extends StatelessWidget {
  const _CalendarLegendChip({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
