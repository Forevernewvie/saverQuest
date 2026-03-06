import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_saverquest_mvp/app/app.dart';

import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts on onboarding', (tester) async {
    await tester.pumpWidget(
      SaverQuestApp(dependencies: buildFakeDependencies()),
    );
    await tester.pumpAndSettle();

    expect(find.text('시작 전 동의 설정'), findsOneWidget);
  });
}
