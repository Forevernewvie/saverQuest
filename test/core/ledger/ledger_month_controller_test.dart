import 'package:flutter_saverquest_mvp/core/ledger/ledger_month_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedNow = DateTime(2026, 3, 15);

  test(
    'showPreviousMonth and showNextMonth move the selected month safely',
    () {
      final controller = LedgerMonthController(
        initialMonth: DateTime(2026, 3, 1),
        now: () => fixedNow,
      );

      controller.showPreviousMonth();
      expect(controller.selectedMonth, DateTime(2026, 2, 1));

      controller.showNextMonth();
      expect(controller.selectedMonth, DateTime(2026, 3, 1));
    },
  );

  test('setMonth normalizes the supplied date to the first day', () {
    final controller = LedgerMonthController(
      initialMonth: DateTime(2026, 1, 1),
      now: () => fixedNow,
    );

    controller.setMonth(DateTime(2026, 7, 22));

    expect(controller.selectedMonth, DateTime(2026, 7, 1));
  });

  test('isCurrentMonth and resetToCurrentMonth use the injected clock', () {
    final controller = LedgerMonthController(
      initialMonth: DateTime(2026, 1, 1),
      now: () => fixedNow,
    );

    expect(controller.isCurrentMonth, isFalse);

    controller.resetToCurrentMonth();

    expect(controller.selectedMonth, DateTime(2026, 3, 1));
    expect(controller.isCurrentMonth, isTrue);
  });
}
