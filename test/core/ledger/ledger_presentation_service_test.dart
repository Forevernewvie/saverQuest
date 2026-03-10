import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_presentation_service.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subtitleForEntry composes type, date, and note for korean locale', () {
    const service = LedgerPresentationService();
    final l10n = AppLocalizations(const Locale('ko'));
    final entry = LedgerEntry(
      id: 'expense-1',
      type: LedgerEntryType.expense,
      category: LedgerCategory.groceries,
      amount: 12000,
      note: '퇴근길 마트',
      occurredOn: DateTime(2026, 3, 10),
    );

    final subtitle = service.subtitleForEntry(l10n: l10n, entry: entry);

    expect(subtitle, '지출 · 3월 10일 · 퇴근길 마트');
  });

  test('iconForCategory returns the expected stable icon', () {
    const service = LedgerPresentationService();

    expect(
      service.iconForCategory(LedgerCategory.transport),
      Icons.directions_bus_outlined,
    );
  });

  test('subtitleForEntry truncates long notes for compact transaction rows', () {
    const service = LedgerPresentationService();
    final l10n = AppLocalizations(const Locale('en'));
    final entry = LedgerEntry(
      id: 'expense-2',
      type: LedgerEntryType.expense,
      category: LedgerCategory.shopping,
      amount: 54000,
      note:
          'Bought a very long weekly household essentials bundle for the entire month',
      occurredOn: DateTime(2026, 3, 10),
    );

    final subtitle = service.subtitleForEntry(l10n: l10n, entry: entry);

    expect(subtitle, contains('Expense'));
    expect(subtitle, contains('Mar 10'));
    expect(subtitle, contains('Bought a very long weekly h…'));
  });
}
