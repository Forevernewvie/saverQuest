import 'package:flutter/material.dart';
import 'package:flutter_saverquest_mvp/core/ledger/ledger_models.dart';
import 'package:flutter_saverquest_mvp/core/localization/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats KRW and JPY without decimal fractions', () {
    final korean = AppLocalizations(const Locale('ko'));
    final english = AppLocalizations(const Locale('en'));

    expect(
      korean.formatCurrency(12000, currency: LedgerCurrency.krw),
      '12,000원',
    );
    expect(
      korean.formatCurrency(12000, currency: LedgerCurrency.jpy),
      '12,000엔',
    );
    expect(
      english.formatCurrency(12000, currency: LedgerCurrency.jpy),
      'JPY 12,000',
    );
  });

  test('formats USD and CNY with two fraction digits', () {
    final korean = AppLocalizations(const Locale('ko'));
    final english = AppLocalizations(const Locale('en'));

    expect(
      korean.formatCurrency(1250, currency: LedgerCurrency.usd),
      'US\$12.50',
    );
    expect(
      english.formatCurrency(1250, currency: LedgerCurrency.usd),
      'USD 12.50',
    );
    expect(
      korean.formatCurrency(880, currency: LedgerCurrency.cny),
      'CN¥8.80',
    );
  });

  test('formats signed currency with the selected app currency', () {
    final english = AppLocalizations(const Locale('en'));

    expect(
      english.formatSignedCurrency(
        type: LedgerEntryType.expense,
        amount: 990,
        currency: LedgerCurrency.usd,
      ),
      '-USD 9.90',
    );
  });
}
