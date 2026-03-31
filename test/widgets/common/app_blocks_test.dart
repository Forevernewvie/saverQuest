import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/widgets/common/app_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets(
    'AppBudgetOverviewCard stretches stacked metrics to the available width',
    (tester) async {
      await tester.pumpWidget(
        const WidgetTestApp(
          locale: Locale('en'),
          mediaQueryData: MediaQueryData(size: Size(640, 800)),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 280,
                child: AppBudgetOverviewCard(
                  title: 'Budget progress',
                  body: 'Compare your monthly budget with current spend.',
                  progressValue: 0.3,
                  remainingLabel: 'Remaining budget',
                  remainingValue: 'KRW 350,000',
                  spentLabel: 'Spent',
                  spentValue: 'KRW 0',
                  limitLabel: 'Budget limit',
                  limitValue: 'KRW 350,000',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final remainingRect = tester.getRect(
        find.byKey(const ValueKey('budget-metric-remaining')),
      );
      final spentRect = tester.getRect(
        find.byKey(const ValueKey('budget-metric-spent')),
      );
      final limitRect = tester.getRect(
        find.byKey(const ValueKey('budget-metric-limit')),
      );

      expect(spentRect.width, closeTo(remainingRect.width, 1));
      expect(limitRect.width, closeTo(remainingRect.width, 1));
      expect(remainingRect.width, greaterThan(180));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AppTransactionTile stacks trailing details when parent width is constrained',
    (tester) async {
      await tester.pumpWidget(
        const WidgetTestApp(
          locale: Locale('en'),
          mediaQueryData: MediaQueryData(size: Size(640, 800)),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 280,
                child: AppTransactionTile(
                  icon: Icons.coffee_outlined,
                  title: 'Coffee',
                  subtitle: 'Beans for the week',
                  trailing: '+₩123,456',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final subtitleBottom = tester
          .getBottomLeft(find.text('Beans for the week'))
          .dy;
      final trailingTop = tester.getTopLeft(find.text('+₩123,456')).dy;

      expect(trailingTop, greaterThan(subtitleBottom));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AppMonthSwitcher moves reset action below nav row on compact large-text layouts',
    (tester) async {
      await tester.pumpWidget(
        const WidgetTestApp(
          locale: Locale('en'),
          mediaQueryData: MediaQueryData(
            size: Size(320, 780),
            textScaler: TextScaler.linear(1.6),
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: AppMonthSwitcher(
                  label: 'March 2026',
                  onPrevious: _noop,
                  onNext: _noop,
                  onReset: _noop,
                  nextEnabled: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final leftRect = tester.getRect(find.byIcon(Icons.chevron_left));
      final rightRect = tester.getRect(find.byIcon(Icons.chevron_right));
      final resetRect = tester.getRect(
        find.widgetWithText(TextButton, 'Current month'),
      );

      expect(resetRect.top, greaterThan(leftRect.bottom));
      expect(resetRect.top, greaterThan(rightRect.bottom));
      expect(tester.takeException(), isNull);
    },
  );
}

void _noop() {}
