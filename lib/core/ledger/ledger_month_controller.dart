import 'package:flutter/foundation.dart';

/// Owns the currently selected calendar month for ledger screens.
class LedgerMonthController extends ChangeNotifier {
  /// Creates a controller with the supplied initial month or the current month.
  LedgerMonthController({DateTime? initialMonth})
    : _selectedMonth = _normalize(initialMonth ?? DateTime.now());

  DateTime _selectedMonth;

  /// Returns the selected month normalized to the first day.
  DateTime get selectedMonth => _selectedMonth;

  /// Returns whether the selected month is the current calendar month.
  bool get isCurrentMonth {
    final now = _normalize(DateTime.now());
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  /// Moves the selected month one month back.
  void showPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
  }

  /// Jumps to the month containing the supplied date.
  void setMonth(DateTime value) {
    _selectedMonth = _normalize(value);
    notifyListeners();
  }

  /// Moves the selected month one month forward when it does not exceed now.
  void showNextMonth() {
    if (isCurrentMonth) {
      return;
    }
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
  }

  /// Jumps back to the current calendar month.
  void resetToCurrentMonth() {
    _selectedMonth = _normalize(DateTime.now());
    notifyListeners();
  }

  static DateTime _normalize(DateTime value) {
    return DateTime(value.year, value.month, 1);
  }
}
