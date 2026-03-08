/// Represents supported spending categories for localized presentation.
enum SpendingCategory { coffee, dining, subscriptions, snacks }

/// Supplies static data for the home dashboard.
class HomeDashboardContent {
  /// Creates an immutable home dashboard snapshot.
  const HomeDashboardContent({
    required this.weeklySavingsAmount,
    required this.streakDays,
    required this.missionCategory,
    required this.missionSavingsAmount,
    required this.goalProgressPercent,
  });

  final int weeklySavingsAmount;
  final int streakDays;
  final SpendingCategory missionCategory;
  final int missionSavingsAmount;
  final int goalProgressPercent;
}

/// Supplies static data for the weekly report.
class ReportDashboardContent {
  /// Creates an immutable report snapshot.
  const ReportDashboardContent({
    required this.weeklySavingsAmount,
    required this.topReducedCategory,
    required this.summaryCategories,
    required this.trendCategories,
    required this.focusCategories,
  });

  final int weeklySavingsAmount;
  final SpendingCategory topReducedCategory;
  final List<SpendingCategory> summaryCategories;
  final List<SpendingCategory> trendCategories;
  final List<SpendingCategory> focusCategories;
}

/// Supplies static data for the insights screen.
class InsightsDashboardContent {
  /// Creates an immutable insights snapshot.
  const InsightsDashboardContent({
    required this.positiveCategories,
    required this.nextFocusCategories,
  });

  final List<SpendingCategory> positiveCategories;
  final List<SpendingCategory> nextFocusCategories;
}

/// Supplies initial values for the calculator form.
class ToolInputDefaults {
  /// Creates a calculator default-value set.
  const ToolInputDefaults({
    required this.beforePrice,
    required this.afterPrice,
    required this.monthlyCount,
  });

  final int beforePrice;
  final int afterPrice;
  final int monthlyCount;
}

/// Defines the content source contract used by presentation widgets.
abstract class AppContentRepository {
  /// Returns the current home dashboard content.
  HomeDashboardContent getHomeContent();

  /// Returns the current report dashboard content.
  ReportDashboardContent getReportContent();

  /// Returns the current insights dashboard content.
  InsightsDashboardContent getInsightsContent();

  /// Returns the default values for the calculator form.
  ToolInputDefaults getToolInputDefaults();
}

/// Provides a deterministic content set until a backend source is introduced.
class StaticAppContentRepository implements AppContentRepository {
  /// Creates a repository backed by stable in-app defaults.
  const StaticAppContentRepository();

  static const HomeDashboardContent _homeContent = HomeDashboardContent(
    weeklySavingsAmount: 63200,
    streakDays: 7,
    missionCategory: SpendingCategory.coffee,
    missionSavingsAmount: 4500,
    goalProgressPercent: 68,
  );

  static const ReportDashboardContent _reportContent = ReportDashboardContent(
    weeklySavingsAmount: 63200,
    topReducedCategory: SpendingCategory.dining,
    summaryCategories: [
      SpendingCategory.dining,
      SpendingCategory.coffee,
      SpendingCategory.subscriptions,
    ],
    trendCategories: [SpendingCategory.dining, SpendingCategory.coffee],
    focusCategories: [SpendingCategory.subscriptions, SpendingCategory.snacks],
  );

  static const InsightsDashboardContent _insightsContent =
      InsightsDashboardContent(
        positiveCategories: [SpendingCategory.coffee, SpendingCategory.dining],
        nextFocusCategories: [
          SpendingCategory.subscriptions,
          SpendingCategory.snacks,
        ],
      );

  static const ToolInputDefaults _toolDefaults = ToolInputDefaults(
    beforePrice: 12000,
    afterPrice: 8500,
    monthlyCount: 14,
  );

  @override
  HomeDashboardContent getHomeContent() => _homeContent;

  @override
  ReportDashboardContent getReportContent() => _reportContent;

  @override
  InsightsDashboardContent getInsightsContent() => _insightsContent;

  @override
  ToolInputDefaults getToolInputDefaults() => _toolDefaults;
}
