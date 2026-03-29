import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/widgets/common/app_blocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_app.dart';

void main() {
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
}
