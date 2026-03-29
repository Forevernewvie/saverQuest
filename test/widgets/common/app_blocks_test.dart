import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/widgets/common/app_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets(
    'AppTransactionTile stacks trailing content based on local layout constraints',
    (tester) async {
      Future<double> measureActionTop(double width) async {
        await tester.pumpWidget(
          WidgetTestApp(
            mediaQueryData: const MediaQueryData(size: Size(600, 800)),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: AppTransactionTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Groceries',
                    subtitle: 'Mart · Today',
                    trailing: '₩54,000',
                    trailingAction: TextButton(
                      onPressed: () {},
                      child: const Text('Edit'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        return tester.getTopLeft(find.widgetWithText(TextButton, 'Edit')).dy;
      }

      final narrowActionTop = await measureActionTop(320);
      final wideActionTop = await measureActionTop(420);

      expect(narrowActionTop, greaterThan(wideActionTop + 8));
    },
  );

  testWidgets(
    'AppTransactionList inlines short lists to avoid shrinkWrap list work',
    (tester) async {
      await tester.pumpWidget(
        WidgetTestApp(
          home: Scaffold(
            body: AppTransactionList(
              itemCount: 3,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsNothing);
    },
  );
}
