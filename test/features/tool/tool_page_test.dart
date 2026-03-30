import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/features/tool/tool_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('opens transaction detail sheet from recent entries', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: ToolPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Latest entries'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coffee').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Review this entry and edit or delete it if needed.'),
      findsOneWidget,
    );
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Coffee'), findsWidgets);
  });

  testWidgets('editing from the transaction detail sheet loads the draft', (
    tester,
  ) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: ToolPage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Latest entries'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coffee').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Save changes'), findsWidgets);
    expect(find.text('Coffee'), findsWidgets);
  });
}
