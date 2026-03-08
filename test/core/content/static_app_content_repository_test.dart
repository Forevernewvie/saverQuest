import 'package:flutter_saverquest_mvp/core/content/app_content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns deterministic home and report content', () {
    const repository = StaticAppContentRepository();

    final home = repository.getHomeContent();
    final report = repository.getReportContent();

    expect(home.weeklySavingsAmount, 63200);
    expect(home.streakDays, 7);
    expect(home.missionCategory, SpendingCategory.coffee);
    expect(report.topReducedCategory, SpendingCategory.dining);
    expect(report.summaryCategories, hasLength(3));
  });

  test('returns calculator defaults that remain greater-than alternative', () {
    const repository = StaticAppContentRepository();

    final defaults = repository.getToolInputDefaults();

    expect(defaults.beforePrice, greaterThan(defaults.afterPrice));
    expect(defaults.monthlyCount, greaterThan(0));
  });
}
