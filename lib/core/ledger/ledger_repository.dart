import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ledger_models.dart';

/// Defines the persistence contract for local ledger data.
abstract class LedgerRepository {
  /// Loads the current ledger snapshot from persistent storage.
  Future<LedgerSnapshot> loadSnapshot();

  /// Persists the current ledger snapshot to storage.
  Future<void> saveSnapshot(LedgerSnapshot snapshot);
}

/// Persists the ledger state in SharedPreferences as JSON.
class SharedPreferencesLedgerRepository implements LedgerRepository {
  /// Creates a repository backed by SharedPreferences.
  SharedPreferencesLedgerRepository({required SharedPreferences preferences})
    : _preferences = preferences;

  static const String _snapshotKey = 'ledger_snapshot_v1';
  static const int _defaultMonthlyBudgetAmount = 350000;

  final SharedPreferences _preferences;

  /// Loads a previously saved snapshot or returns a safe empty default.
  @override
  Future<LedgerSnapshot> loadSnapshot() async {
    final rawSnapshot = _preferences.getString(_snapshotKey);
    if (rawSnapshot == null || rawSnapshot.isEmpty) {
      return const LedgerSnapshot(
        entries: [],
        monthlyBudgetAmount: _defaultMonthlyBudgetAmount,
      );
    }

    final decoded = jsonDecode(rawSnapshot) as Map<String, Object?>;
    return LedgerSnapshot.fromJson(decoded);
  }

  /// Saves the provided ledger snapshot as a JSON string.
  @override
  Future<void> saveSnapshot(LedgerSnapshot snapshot) async {
    await _preferences.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }
}
