import 'package:flutter/material.dart';

import '../../core/ledger/ledger_models.dart';

/// Owns quick-entry form state so the screen can stay focused on layout.
class QuickEntryFormController extends ChangeNotifier {
  /// Creates a form controller with an initial monthly budget amount.
  QuickEntryFormController({required int initialMonthlyBudgetAmount})
    : _budgetController = TextEditingController(
        text: initialMonthlyBudgetAmount.toString(),
      ),
      _amountController = TextEditingController(),
      _noteController = TextEditingController();

  final TextEditingController _amountController;
  final TextEditingController _noteController;
  final TextEditingController _budgetController;

  LedgerEntryType _selectedType = LedgerEntryType.expense;
  LedgerCategory _selectedCategory = LedgerCategory.groceries;
  DateTime _selectedDate = DateTime.now();
  String? _editingEntryId;

  /// Exposes the transaction amount text controller.
  TextEditingController get amountController => _amountController;

  /// Exposes the optional note text controller.
  TextEditingController get noteController => _noteController;

  /// Exposes the monthly budget text controller.
  TextEditingController get budgetController => _budgetController;

  /// Returns the currently selected transaction type.
  LedgerEntryType get selectedType => _selectedType;

  /// Returns the currently selected category.
  LedgerCategory get selectedCategory => _selectedCategory;

  /// Returns the currently selected transaction date.
  DateTime get selectedDate => _selectedDate;

  /// Returns the id of the transaction being edited, if any.
  String? get editingEntryId => _editingEntryId;

  /// Returns whether the form is currently editing an existing transaction.
  bool get isEditing => _editingEntryId != null;

  /// Returns the categories available for the currently selected type.
  List<LedgerCategory> categoriesForSelectedType() {
    return _selectedType == LedgerEntryType.expense
        ? const [
            LedgerCategory.groceries,
            LedgerCategory.dining,
            LedgerCategory.transport,
            LedgerCategory.coffee,
            LedgerCategory.shopping,
            LedgerCategory.housing,
            LedgerCategory.subscriptions,
            LedgerCategory.health,
            LedgerCategory.entertainment,
          ]
        : const [
            LedgerCategory.salary,
            LedgerCategory.freelance,
            LedgerCategory.savings,
          ];
  }

  /// Updates the selected transaction type and normalizes category state.
  void selectType(LedgerEntryType type) {
    _selectedType = type;
    final categories = categoriesForSelectedType();
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }
    notifyListeners();
  }

  /// Updates the selected transaction category.
  void selectCategory(LedgerCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Updates the selected transaction date.
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Resets the entry draft after a successful save.
  void clearEntryDraft() {
    _amountController.clear();
    _noteController.clear();
    _selectedDate = DateTime.now();
    _editingEntryId = null;
    notifyListeners();
  }

  /// Updates the visible monthly budget field from persisted ledger state.
  void setBudgetAmount(int amount) {
    _budgetController.text = amount.toString();
    notifyListeners();
  }

  /// Loads an existing transaction into the form for editing.
  void beginEditing(LedgerEntry entry) {
    _editingEntryId = entry.id;
    _selectedType = entry.type;
    _selectedCategory = entry.category;
    _selectedDate = entry.occurredOn;
    _amountController.text = entry.amount.toString();
    _noteController.text = entry.note;
    notifyListeners();
  }

  /// Builds a validated ledger entry from the current draft values.
  LedgerEntry buildEntry() {
    return LedgerEntry(
      id: _editingEntryId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: _selectedType,
      category: _selectedCategory,
      amount: _parseRequiredPositiveInt(
        _amountController.text,
        fieldName: 'entry amount',
      ),
      note: _noteController.text.trim(),
      occurredOn: _selectedDate,
    );
  }

  /// Parses the monthly budget value from the current budget field.
  int parseBudgetAmount() {
    return _parseRequiredPositiveInt(
      _budgetController.text,
      fieldName: 'budget amount',
    );
  }

  static int _parseRequiredPositiveInt(
    String rawValue, {
    required String fieldName,
  }) {
    final value = int.tryParse(rawValue);
    if (value == null || value <= 0) {
      throw StateError('$fieldName must be a positive integer.');
    }
    return value;
  }

  /// Disposes text editing controllers owned by the form controller.
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
