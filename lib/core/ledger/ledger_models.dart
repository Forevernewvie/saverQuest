/// Defines the supported transaction directions in the personal ledger.
enum LedgerEntryType { expense, income }

/// Defines the single app-wide currency used for all ledger calculations.
enum LedgerCurrency {
  krw,
  jpy,
  cny,
  usd;

  bool get usesMinorUnits =>
      this == LedgerCurrency.cny || this == LedgerCurrency.usd;

  int get fractionDigits => usesMinorUnits ? 2 : 0;

  String get code => name.toUpperCase();
}

/// Defines the supported categories used for transaction tagging and insights.
enum LedgerCategory {
  groceries,
  dining,
  transport,
  coffee,
  shopping,
  housing,
  subscriptions,
  health,
  entertainment,
  salary,
  freelance,
  savings,
}

/// Represents a single transaction recorded by the user.
class LedgerEntry {
  /// Creates an immutable ledger entry.
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
    required this.occurredOn,
  });

  final String id;
  final LedgerEntryType type;
  final LedgerCategory category;
  final int amount;
  final String note;
  final DateTime occurredOn;

  /// Returns a copy of this entry with updated fields.
  LedgerEntry copyWith({
    String? id,
    LedgerEntryType? type,
    LedgerCategory? category,
    int? amount,
    String? note,
    DateTime? occurredOn,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      occurredOn: occurredOn ?? this.occurredOn,
    );
  }

  /// Serializes this entry into a persistable JSON map.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'note': note,
      'occurredOn': occurredOn.toIso8601String(),
    };
  }

  /// Restores a ledger entry from a previously serialized JSON map.
  static LedgerEntry fromJson(Map<String, Object?> json) {
    return LedgerEntry(
      id: json['id']! as String,
      type: LedgerEntryType.values.byName(json['type']! as String),
      category: LedgerCategory.values.byName(json['category']! as String),
      amount: json['amount']! as int,
      note: json['note']! as String,
      occurredOn: DateTime.parse(json['occurredOn']! as String),
    );
  }
}

/// Stores the persisted ledger state that is loaded on app startup.
class LedgerSnapshot {
  /// Creates an immutable snapshot of the user's local ledger state.
  const LedgerSnapshot({
    required this.entries,
    required this.monthlyBudgetAmount,
    this.currency = LedgerCurrency.krw,
  });

  final List<LedgerEntry> entries;
  final int monthlyBudgetAmount;
  final LedgerCurrency currency;

  /// Returns a copy of this snapshot with updated fields.
  LedgerSnapshot copyWith({
    List<LedgerEntry>? entries,
    int? monthlyBudgetAmount,
    LedgerCurrency? currency,
  }) {
    return LedgerSnapshot(
      entries: entries ?? this.entries,
      monthlyBudgetAmount: monthlyBudgetAmount ?? this.monthlyBudgetAmount,
      currency: currency ?? this.currency,
    );
  }

  /// Serializes the snapshot into a persistable JSON map.
  Map<String, Object?> toJson() {
    return {
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'monthlyBudgetAmount': monthlyBudgetAmount,
      'currency': currency.name,
    };
  }

  /// Restores a snapshot from a JSON map loaded from local storage.
  static LedgerSnapshot fromJson(Map<String, Object?> json) {
    final rawEntries = (json['entries']! as List<Object?>)
        .cast<Map<Object?, Object?>>();

    return LedgerSnapshot(
      entries: rawEntries
          .map(
            (entry) => LedgerEntry.fromJson(
              entry.map((key, value) => MapEntry(key! as String, value)),
            ),
          )
          .toList(),
      monthlyBudgetAmount: json['monthlyBudgetAmount']! as int,
      currency: json['currency'] == null
          ? LedgerCurrency.krw
          : LedgerCurrency.values.byName(json['currency']! as String),
    );
  }
}

/// Captures monthly dashboard totals for the home screen.
class LedgerDashboardSummary {
  /// Creates a dashboard summary derived from the current month entries.
  const LedgerDashboardSummary({
    required this.monthlyBudgetAmount,
    required this.monthlyExpenseAmount,
    required this.monthlyIncomeAmount,
    required this.remainingBudgetAmount,
    required this.currentMonthEntries,
    required this.recentEntries,
    required this.topExpenseCategory,
    required this.currency,
  });

  final int monthlyBudgetAmount;
  final int monthlyExpenseAmount;
  final int monthlyIncomeAmount;
  final int remainingBudgetAmount;
  final List<LedgerEntry> currentMonthEntries;
  final List<LedgerEntry> recentEntries;
  final LedgerCategory? topExpenseCategory;
  final LedgerCurrency currency;

  /// Returns the budget consumption ratio clamped to a user-facing range.
  double get budgetProgress {
    if (monthlyBudgetAmount <= 0) {
      return 0;
    }
    return (monthlyExpenseAmount / monthlyBudgetAmount).clamp(0.0, 1.0);
  }
}

/// Stores a category total for reports and insight generation.
class LedgerCategoryTotal {
  /// Creates an immutable category total aggregate.
  const LedgerCategoryTotal({
    required this.category,
    required this.amount,
    required this.entryCount,
  });

  final LedgerCategory category;
  final int amount;
  final int entryCount;
}

/// Stores one day-level spending total for the calendar report view.
class LedgerDailySpendTotal {
  /// Creates an immutable day aggregate.
  const LedgerDailySpendTotal({
    required this.date,
    required this.amount,
    required this.entryCount,
  });

  final DateTime date;
  final int amount;
  final int entryCount;
}

/// Captures report-ready aggregations for the current month.
class LedgerReportSummary {
  /// Creates a report summary for the report screen.
  const LedgerReportSummary({
    required this.monthlyBudgetAmount,
    required this.monthlyExpenseAmount,
    required this.monthlyIncomeAmount,
    required this.balanceAmount,
    this.currentMonthEntries = const [],
    required this.recentEntries,
    required this.expenseTotals,
    this.dailySpendTotals = const [],
    required this.currency,
  });

  final int monthlyBudgetAmount;
  final int monthlyExpenseAmount;
  final int monthlyIncomeAmount;
  final int balanceAmount;
  final List<LedgerEntry> currentMonthEntries;
  final List<LedgerEntry> recentEntries;
  final List<LedgerCategoryTotal> expenseTotals;
  final List<LedgerDailySpendTotal> dailySpendTotals;
  final LedgerCurrency currency;
}

/// Captures narrative insight inputs derived from the current month ledger.
class LedgerInsightSummary {
  /// Creates an insight summary for the insights screen.
  const LedgerInsightSummary({
    required this.monthlyExpenseAmount,
    required this.monthlyIncomeAmount,
    required this.remainingBudgetAmount,
    required this.topExpenseCategory,
    required this.secondaryExpenseCategory,
    required this.recentExpenseCount,
    required this.currency,
  });

  final int monthlyExpenseAmount;
  final int monthlyIncomeAmount;
  final int remainingBudgetAmount;
  final LedgerCategory? topExpenseCategory;
  final LedgerCategory? secondaryExpenseCategory;
  final int recentExpenseCount;
  final LedgerCurrency currency;
}
