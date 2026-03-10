import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import 'ledger_models.dart';
import 'ledger_repository.dart';
import 'ledger_summary_service.dart';

/// Coordinates local ledger mutations, persistence, and derived summaries.
class LedgerController extends ChangeNotifier {
  /// Creates a ledger controller with explicit dependencies and initial state.
  LedgerController({
    required LedgerRepository repository,
    required AppLogger logger,
    LedgerSummaryService summaryService = const LedgerSummaryService(),
    LedgerSnapshot initialSnapshot = const LedgerSnapshot(
      entries: [],
      monthlyBudgetAmount: 350000,
    ),
  }) : _repository = repository,
       _logger = logger,
       _summaryService = summaryService,
       _snapshot = initialSnapshot;

  final LedgerRepository _repository;
  final AppLogger _logger;
  final LedgerSummaryService _summaryService;

  LedgerSnapshot _snapshot;
  bool _initialized = false;

  /// Returns whether the controller has completed its first storage load.
  bool get initialized => _initialized;

  /// Returns an immutable view of all recorded entries.
  List<LedgerEntry> get entries => List.unmodifiable(_snapshot.entries);

  /// Returns the configured monthly budget amount.
  int get monthlyBudgetAmount => _snapshot.monthlyBudgetAmount;

  /// Loads the persisted ledger snapshot into memory.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      _snapshot = await _repository.loadSnapshot();
      _initialized = true;
      _logger.info(
        'Ledger snapshot initialized.',
        scope: 'ledger',
        metadata: {
          'entry_count': _snapshot.entries.length,
          'monthly_budget_amount': _snapshot.monthlyBudgetAmount,
        },
      );
      notifyListeners();
    } catch (error, stackTrace) {
      _initialized = true;
      _logger.error(
        'Failed to initialize ledger snapshot.',
        scope: 'ledger',
        error: error,
        stackTrace: stackTrace,
      );
      notifyListeners();
    }
  }

  /// Persists a newly recorded transaction and updates listeners.
  Future<void> addEntry(LedgerEntry entry) async {
    final nextEntries = [..._snapshot.entries, entry];
    await _persistSnapshot(_snapshot.copyWith(entries: nextEntries));
  }

  /// Persists an updated transaction and refreshes listeners.
  Future<void> updateEntry(LedgerEntry entry) async {
    final nextEntries = _snapshot.entries
        .map((existing) => existing.id == entry.id ? entry : existing)
        .toList();
    await _persistSnapshot(_snapshot.copyWith(entries: nextEntries));
  }

  /// Removes a transaction by id and refreshes listeners.
  Future<void> deleteEntry(String entryId) async {
    final nextEntries = _snapshot.entries
        .where((entry) => entry.id != entryId)
        .toList();
    await _persistSnapshot(_snapshot.copyWith(entries: nextEntries));
  }

  /// Persists a changed monthly budget and updates listeners.
  Future<void> updateMonthlyBudget(int amount) async {
    await _persistSnapshot(_snapshot.copyWith(monthlyBudgetAmount: amount));
  }

  /// Returns a home-dashboard summary for the current month.
  LedgerDashboardSummary dashboardSummary({DateTime? now}) {
    return _summaryService.buildDashboard(
      snapshot: _snapshot,
      now: now ?? DateTime.now(),
    );
  }

  /// Returns a report summary for the current month.
  LedgerReportSummary reportSummary({DateTime? now}) {
    return _summaryService.buildReport(
      snapshot: _snapshot,
      now: now ?? DateTime.now(),
    );
  }

  /// Returns an insight summary for the current month.
  LedgerInsightSummary insightSummary({DateTime? now}) {
    return _summaryService.buildInsights(
      snapshot: _snapshot,
      now: now ?? DateTime.now(),
    );
  }

  /// Persists the supplied snapshot and notifies listeners on success.
  Future<void> _persistSnapshot(LedgerSnapshot nextSnapshot) async {
    _snapshot = nextSnapshot;
    notifyListeners();

    try {
      await _repository.saveSnapshot(nextSnapshot);
      _logger.info(
        'Ledger snapshot saved.',
        scope: 'ledger',
        metadata: {
          'entry_count': nextSnapshot.entries.length,
          'monthly_budget_amount': nextSnapshot.monthlyBudgetAmount,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to persist ledger snapshot.',
        scope: 'ledger',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
