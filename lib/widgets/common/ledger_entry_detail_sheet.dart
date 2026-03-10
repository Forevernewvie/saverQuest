import 'package:flutter/material.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_ui_tokens.dart';
import '../../core/ledger/ledger_models.dart';
import '../../core/ledger/ledger_view_data.dart';
import '../../core/localization/app_localizations.dart';
import 'app_blocks.dart';

/// Opens the shared transaction detail sheet used across ledger screens.
Future<void> showLedgerEntryDetailSheet({
  required BuildContext context,
  required LedgerEntry entry,
  required LedgerTransactionRowViewData rowViewData,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  final l10n = AppLocalizations.of(context);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppUiTokens.sheetCornerRadius),
      ),
    ),
    builder: (sheetContext) {
      return AppTransactionDetailSheet(
        icon: rowViewData.icon,
        title: l10n.toolDetailTitle,
        amount: rowViewData.trailing,
        typeValue: l10n.ledgerEntryTypeLabel(entry.type),
        categoryValue: l10n.ledgerCategoryLabel(entry.category),
        dateValue: l10n.formatShortDate(entry.occurredOn),
        noteValue: entry.note.isEmpty ? l10n.toolDetailEmptyNote : entry.note,
        hint: l10n.toolDetailSheetHint,
        onEdit: onEdit == null
            ? null
            : () {
                Navigator.pop(sheetContext);
                onEdit();
              },
        onDelete: onDelete == null
            ? null
            : () {
                Navigator.pop(sheetContext);
                onDelete();
              },
      );
    },
  );
}
