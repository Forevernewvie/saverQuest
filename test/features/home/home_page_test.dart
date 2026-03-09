import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('renders budget snapshot and primary CTA', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('가계부 홈'), findsOneWidget);
    expect(find.text('이번 달 예산 현황'), findsOneWidget);
    expect(find.text('절약 금액 계산하기'), findsOneWidget);
    expect(find.text('남은 예산'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('빠른 실행'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('빠른 실행'), findsOneWidget);
  });

  testWidgets('renders english budget dashboard copy', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budget Home'), findsOneWidget);
    expect(find.text('Monthly budget overview'), findsOneWidget);
    expect(find.text('Estimate your savings'), findsOneWidget);
    expect(find.text('Remaining budget'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Quick actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
