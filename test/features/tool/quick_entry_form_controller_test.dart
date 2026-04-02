import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/features/tool/quick_entry_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedNow = DateTime(2026, 3, 20, 9);

  test('income type narrows categories and normalizes invalid selection', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 350000,
    );

    controller.selectCategory(LedgerCategory.groceries);
    controller.selectType(LedgerEntryType.income);

    expect(
      controller.categoriesForSelectedType(),
      contains(LedgerCategory.salary),
    );
    expect(controller.selectedCategory, LedgerCategory.salary);
    controller.dispose();
  });

  test('buildEntry uses current draft fields', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 350000,
    );
    controller.amountController.text = '18000';
    controller.noteController.text = '버스';
    controller.selectCategory(LedgerCategory.transport);
    controller.selectDate(DateTime(2026, 3, 10));

    final entry = controller.buildEntry();

    expect(entry.type, LedgerEntryType.expense);
    expect(entry.category, LedgerCategory.transport);
    expect(entry.amount, 18000);
    expect(entry.note, '버스');
    expect(entry.occurredOn, DateTime(2026, 3, 10));
    controller.dispose();
  });

  test(
    'clearEntryDraft resets amount, note, and date while keeping budget',
    () {
      final controller = QuickEntryFormController(
        initialMonthlyBudgetAmount: 420000,
        now: () => fixedNow,
      );
      controller.amountController.text = '12000';
      controller.noteController.text = '점심';
      controller.selectDate(DateTime(2026, 3, 9));

      controller.clearEntryDraft();

      expect(controller.amountController.text, isEmpty);
      expect(controller.noteController.text, isEmpty);
      expect(controller.selectedDate, fixedNow);
      expect(controller.budgetController.text, '420000');
      controller.dispose();
    },
  );

  test('beginEditing loads an existing transaction and preserves its id', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 420000,
    );
    final entry = LedgerEntry(
      id: 'expense-1',
      type: LedgerEntryType.expense,
      category: LedgerCategory.shopping,
      amount: 38000,
      note: '생활용품',
      occurredOn: DateTime(2026, 3, 12),
    );

    controller.beginEditing(entry);
    final rebuilt = controller.buildEntry();

    expect(controller.isEditing, isTrue);
    expect(controller.editingEntryId, 'expense-1');
    expect(rebuilt.id, 'expense-1');
    expect(rebuilt.note, '생활용품');
    controller.dispose();
  });

  test('buildEntry trims numeric input before parsing', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 420000,
      entryIdFactory: () => 'generated-entry',
    );
    controller.amountController.text = ' 18000 ';

    final entry = controller.buildEntry();

    expect(entry.id, 'generated-entry');
    expect(entry.amount, 18000);
    controller.dispose();
  });

  test('buildEntry parses decimal minor-unit currencies safely', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 50000,
      initialCurrency: LedgerCurrency.usd,
    );
    controller.amountController.text = '12.50';

    final entry = controller.buildEntry();

    expect(entry.amount, 1250);
    expect(controller.budgetController.text, '500.00');
    controller.dispose();
  });

  test('starts with the injected current date for deterministic drafts', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 420000,
      now: () => fixedNow,
    );

    expect(controller.selectedDate, fixedNow);
    controller.dispose();
  });

  test('parseBudgetAmount throws a format error for invalid text', () {
    final controller = QuickEntryFormController(
      initialMonthlyBudgetAmount: 420000,
    );
    controller.budgetController.text = 'budget';

    expect(controller.parseBudgetAmount, throwsFormatException);
    controller.dispose();
  });
}
