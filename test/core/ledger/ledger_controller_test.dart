import 'package:flutter_saverquest_mvp/core/ledger/ledger_controller.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test(
    'addEntry persists a new transaction and updates summary totals',
    () async {
      final logger = FakeLogger();
      final repository = InMemoryLedgerRepository(
        snapshot: const LedgerSnapshot(
          entries: [],
          monthlyBudgetAmount: 300000,
        ),
      );
      final controller = LedgerController(
        repository: repository,
        logger: logger,
      );
      await controller.initialize();

      await controller.addEntry(
        LedgerEntry(
          id: 'expense-1',
          type: LedgerEntryType.expense,
          category: LedgerCategory.transport,
          amount: 18000,
          note: 'bus',
          occurredOn: DateTime.now(),
        ),
      );

      final summary = controller.dashboardSummary();

      expect(controller.entries.length, 1);
      expect(summary.monthlyExpenseAmount, 18000);
      expect(summary.remainingBudgetAmount, 282000);
    },
  );

  test(
    'updateMonthlyBudget changes the stored monthly budget amount',
    () async {
      final logger = FakeLogger();
      final repository = InMemoryLedgerRepository(
        snapshot: const LedgerSnapshot(
          entries: [],
          monthlyBudgetAmount: 300000,
        ),
      );
      final controller = LedgerController(
        repository: repository,
        logger: logger,
      );
      await controller.initialize();

      await controller.updateMonthlyBudget(450000);

      expect(controller.monthlyBudgetAmount, 450000);
      expect(controller.dashboardSummary().monthlyBudgetAmount, 450000);
    },
  );

  test('updateEntry replaces an existing transaction by id', () async {
    final logger = FakeLogger();
    final repository = InMemoryLedgerRepository(
      snapshot: LedgerSnapshot(
        entries: [
          LedgerEntry(
            id: 'expense-1',
            type: LedgerEntryType.expense,
            category: LedgerCategory.transport,
            amount: 18000,
            note: 'bus',
            occurredOn: DateTime(2026, 3, 10),
          ),
        ],
        monthlyBudgetAmount: 300000,
      ),
    );
    final controller = LedgerController(repository: repository, logger: logger);
    await controller.initialize();

    await controller.updateEntry(
      LedgerEntry(
        id: 'expense-1',
        type: LedgerEntryType.expense,
        category: LedgerCategory.transport,
        amount: 21000,
        note: 'taxi',
        occurredOn: DateTime(2026, 3, 10),
      ),
    );

    expect(controller.entries.single.amount, 21000);
    expect(controller.entries.single.note, 'taxi');
  });

  test('deleteEntry removes the target transaction', () async {
    final logger = FakeLogger();
    final repository = InMemoryLedgerRepository(
      snapshot: LedgerSnapshot(
        entries: [
          LedgerEntry(
            id: 'expense-1',
            type: LedgerEntryType.expense,
            category: LedgerCategory.transport,
            amount: 18000,
            note: 'bus',
            occurredOn: DateTime(2026, 3, 10),
          ),
          LedgerEntry(
            id: 'expense-2',
            type: LedgerEntryType.expense,
            category: LedgerCategory.coffee,
            amount: 4500,
            note: 'coffee',
            occurredOn: DateTime(2026, 3, 11),
          ),
        ],
        monthlyBudgetAmount: 300000,
      ),
    );
    final controller = LedgerController(repository: repository, logger: logger);
    await controller.initialize();

    await controller.deleteEntry('expense-1');

    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.id, 'expense-2');
  });
}
