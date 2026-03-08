import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/features/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_test_app.dart';

void main() {
  testWidgets('renders mission and CTA', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('ko'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 절약'), findsOneWidget);
    expect(find.text('오늘의 추천'), findsOneWidget);
    expect(find.text('절약 금액 계산하기'), findsOneWidget);
  });

  testWidgets('renders english copy when locale is english', (tester) async {
    final dependencies = buildFakeDependencies();

    await tester.pumpWidget(
      WidgetTestApp(
        locale: const Locale('en'),
        home: HomePage(dependencies: dependencies),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Savings'), findsOneWidget);
    expect(find.text('Today\'s suggestion'), findsOneWidget);
    expect(find.text('Estimate your savings'), findsOneWidget);
  });
}
