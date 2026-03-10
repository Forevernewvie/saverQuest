import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'ledger_models.dart';

/// Provides stable presentation mappings for ledger-specific UI elements.
class LedgerPresentationService {
  static const int _entryNotePreviewMaxLength = 28;

  /// Creates a pure presentation helper with no mutable state.
  const LedgerPresentationService();

  /// Maps a ledger category to a stable Material icon.
  IconData iconForCategory(LedgerCategory category) {
    return switch (category) {
      LedgerCategory.groceries => Icons.shopping_basket_outlined,
      LedgerCategory.dining => Icons.restaurant_outlined,
      LedgerCategory.transport => Icons.directions_bus_outlined,
      LedgerCategory.coffee => Icons.local_cafe_outlined,
      LedgerCategory.shopping => Icons.shopping_bag_outlined,
      LedgerCategory.housing => Icons.home_outlined,
      LedgerCategory.subscriptions => Icons.subscriptions_outlined,
      LedgerCategory.health => Icons.favorite_border,
      LedgerCategory.entertainment => Icons.movie_outlined,
      LedgerCategory.salary => Icons.account_balance_wallet_outlined,
      LedgerCategory.freelance => Icons.work_outline,
      LedgerCategory.savings => Icons.savings_outlined,
    };
  }

  /// Builds the supporting line shown under a transaction title.
  String subtitleForEntry({
    required AppLocalizations l10n,
    required LedgerEntry entry,
  }) {
    final notePreview = _buildNotePreview(entry.note);
    final noteSuffix = notePreview.isEmpty ? '' : ' · $notePreview';
    return '${l10n.ledgerEntryTypeLabel(entry.type)} · ${l10n.formatShortDate(entry.occurredOn)}$noteSuffix';
  }

  /// Shortens long notes so compact transaction rows remain stable.
  String _buildNotePreview(String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.length <= _entryNotePreviewMaxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, _entryNotePreviewMaxLength - 1)}…';
  }
}
