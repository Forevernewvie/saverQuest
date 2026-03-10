import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/features/tool/quick_entry_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      );
      controller.amountController.text = '12000';
      controller.noteController.text = '점심';
      controller.selectDate(DateTime(2026, 3, 9));

      controller.clearEntryDraft();

      expect(controller.amountController.text, isEmpty);
      expect(controller.noteController.text, isEmpty);
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
}
