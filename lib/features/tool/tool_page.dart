import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_dependencies.dart';
import '../../app/routes.dart';
import '../../core/design/adaptive_layout.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_ui_tokens.dart';
import '../../core/ledger/ledger_models.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/common/ledger_entry_detail_sheet.dart';
import '../../widgets/screen_shell.dart';
import 'quick_entry_form_controller.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final GlobalKey<FormState> _entryFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _budgetFormKey = GlobalKey<FormState>();

  late final QuickEntryFormController _formController;

  /// Initializes form controllers and records the screen impression.
  @override
  void initState() {
    super.initState();
    _formController = QuickEntryFormController(
      initialMonthlyBudgetAmount:
          widget.dependencies.ledgerController.monthlyBudgetAmount,
    );
    widget.dependencies.analyticsService.logScreen('tool');
  }

  /// Disposes text controllers to avoid retaining stale widget state.
  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  /// Opens a date picker and updates the selected transaction date.
  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _formController.selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (selectedDate == null || !mounted) {
      return;
    }

    _formController.selectDate(selectedDate);
  }

  /// Saves a new ledger entry after validating the entry form.
  Future<void> _saveEntry() async {
    final l10n = context.l10n;
    if (!_entryFormKey.currentState!.validate()) {
      return;
    }

    final entry = _formController.buildEntry();
    final wasEditing = _formController.isEditing;

    if (wasEditing) {
      await widget.dependencies.ledgerController.updateEntry(entry);
    } else {
      await widget.dependencies.ledgerController.addEntry(entry);
    }

    if (!mounted) {
      return;
    }

    widget.dependencies.ledgerMonthController.setMonth(entry.occurredOn);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasEditing ? l10n.toolUpdateSuccess : l10n.toolSubmitSuccess,
        ),
      ),
    );

    _formController.clearEntryDraft();
  }

  /// Saves the monthly budget after validating the budget form.
  Future<void> _saveBudget() async {
    final l10n = context.l10n;
    if (!_budgetFormKey.currentState!.validate()) {
      return;
    }

    await widget.dependencies.ledgerController.updateMonthlyBudget(
      _formController.parseBudgetAmount(),
    );

    if (!mounted) {
      return;
    }

    _formController.setBudgetAmount(
      widget.dependencies.ledgerController.monthlyBudgetAmount,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.toolBudgetSaved)));
  }

  /// Loads an existing transaction into the form for editing.
  void _startEditingEntry(LedgerEntry entry) {
    widget.dependencies.ledgerMonthController.setMonth(entry.occurredOn);
    _formController.beginEditing(entry);
  }

  /// Clears editing mode and returns the form to a fresh draft.
  void _cancelEditing() {
    _formController.clearEntryDraft();
  }

  /// Opens a transaction detail sheet with edit and delete follow-up actions.
  Future<void> _showEntryDetails(LedgerEntry entry) async {
    final l10n = context.l10n;
    final rowViewData = widget.dependencies.ledgerViewDataFactory
        .buildTransactionRow(l10n: l10n, entry: entry);

    await showLedgerEntryDetailSheet(
      context: context,
      entry: entry,
      rowViewData: rowViewData,
      onEdit: () => _startEditingEntry(entry),
      onDelete: () => _confirmDeleteEntry(entry),
    );
  }

  /// Confirms and deletes a transaction from the local ledger.
  Future<void> _confirmDeleteEntry(LedgerEntry entry) async {
    final l10n = context.l10n;
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.toolDeleteDialogTitle),
              content: Text(l10n.toolDeleteDialogBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.toolDeleteCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.toolDeleteConfirm),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    await widget.dependencies.ledgerController.deleteEntry(entry.id);

    if (!mounted) {
      return;
    }

    if (_formController.editingEntryId == entry.id) {
      _formController.clearEntryDraft();
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.toolDeleteSuccess)));
  }

  /// Builds the recent-entry section shown below the quick-entry form.
  Widget _buildRecentEntries(AppLocalizations l10n) {
    final recentEntries = widget.dependencies.ledgerController
        .dashboardSummary(
          now: widget.dependencies.ledgerMonthController.selectedMonth,
        )
        .recentEntries;
    final viewFactory = widget.dependencies.ledgerViewDataFactory;

    if (recentEntries.isEmpty) {
      return AppEmptyStateCard(
        icon: Icons.edit_note_outlined,
        title: l10n.toolEmptyRecentTitle,
        body: l10n.toolEmptyRecentBody,
      );
    }

    return AppTransactionList(
      itemCount: recentEntries.length,
      itemBuilder: (context, index) {
        final entry = recentEntries[index];
        final viewData = viewFactory.buildTransactionRow(
          l10n: l10n,
          entry: entry,
        );
        return AppTransactionTile(
          key: ValueKey(entry.id),
          icon: viewData.icon,
          title: viewData.title,
          subtitle: viewData.subtitle,
          trailing: viewData.trailing,
          onTap: () => _showEntryDetails(entry),
          trailingAction: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _startEditingEntry(entry);
                return;
              }
              if (value == 'delete') {
                _confirmDeleteEntry(entry);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(l10n.toolEditEntryAction),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.toolDeleteEntryAction),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the shared entry form card for recording or editing transactions.
  Widget _buildEntryFormCard(
    AppLocalizations l10n,
    List<LedgerCategory> categories,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.surfaceCornerRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _entryFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.toolInputSectionTitle,
              subtitle: l10n.toolInputSectionBody,
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<LedgerEntryType>(
              initialValue: _formController.selectedType,
              decoration: InputDecoration(labelText: l10n.toolEntryTypeLabel),
              items: LedgerEntryType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(l10n.ledgerEntryTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _formController.selectType(value);
              },
            ),
            const SizedBox(height: AppSpacing.s),
            DropdownButtonFormField<LedgerCategory>(
              initialValue: _formController.selectedCategory,
              decoration: InputDecoration(labelText: l10n.toolCategoryLabel),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(l10n.ledgerCategoryLabel(category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _formController.selectCategory(value);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            TextFormField(
              controller: _formController.amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.toolAmountLabel,
                hintText: l10n.toolAmountHint,
              ),
              validator: (value) {
                final amount = int.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return l10n.toolAmountValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _formController.noteController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.toolNoteLabel,
                hintText: l10n.toolNoteHint,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${l10n.toolDateLabel}: ${l10n.formatShortDate(_formController.selectedDate)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(l10n.toolDateAction),
                  ),
                  FilledButton(
                    onPressed: _saveEntry,
                    child: Text(
                      _formController.isEditing
                          ? l10n.toolUpdateSubmit
                          : l10n.toolSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the monthly budget form card shown alongside the entry form.
  Widget _buildBudgetFormCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.surfaceCornerRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _budgetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.toolBudgetSectionTitle,
              subtitle: l10n.toolBudgetSectionBody,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _formController.budgetController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.toolBudgetAmountLabel,
                hintText: l10n.toolBudgetAmountHint,
              ),
              validator: (value) {
                final amount = int.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return l10n.toolBudgetValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.s),
            FilledButton(
              onPressed: _saveBudget,
              child: Text(l10n.toolBudgetSave),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the quick-entry screen backed by the live ledger controller.
  @override
  Widget build(BuildContext context) {
    final ledgerController = widget.dependencies.ledgerController;
    final monthController = widget.dependencies.ledgerMonthController;
    final listenable = Listenable.merge([
      ledgerController,
      monthController,
      _formController,
    ]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final l10n = context.l10n;
        final categories = _formController.categoriesForSelectedType();
        final selectedMonth = monthController.selectedMonth;

        return ScreenShell(
          title: l10n.toolTitle,
          primaryNavigationRoute: AppRoutes.tool,
          showAppBar: false,
          children: [
            AppHeroCard(
              eyebrow: l10n.navTool,
              title: l10n.toolHeroTitle,
              body: l10n.toolHeroBody,
              trailing: const AppHeroIcon(icon: Icons.edit_note_outlined),
            ),
            if (_formController.isEditing)
              AppFeatureCard(
                icon: Icons.edit_note_outlined,
                title: l10n.toolEditingBannerTitle,
                body: l10n.toolEditingBannerBody,
                trailing: OutlinedButton(
                  onPressed: _cancelEditing,
                  child: Text(l10n.toolEditingCancel),
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoPane = AdaptiveLayout.useTwoPaneLayout(
                  context,
                  constraints.maxWidth,
                );

                if (useTwoPane) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildEntryFormCard(l10n, categories),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(flex: 2, child: _buildBudgetFormCard(l10n)),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Column(
                    children: [
                      _buildEntryFormCard(l10n, categories),
                      const SizedBox(height: AppSpacing.m),
                      _buildBudgetFormCard(l10n),
                    ],
                  ),
                );
              },
            ),
            AppMonthSwitcher(
              label: l10n.formatMonthYear(selectedMonth),
              onPrevious: monthController.showPreviousMonth,
              onNext: monthController.showNextMonth,
              onReset: monthController.resetToCurrentMonth,
              nextEnabled: !monthController.isCurrentMonth,
            ),
            AppSectionHeader(
              title: l10n.toolRecentRecordsTitle,
              subtitle: l10n.toolRecentRecordsBody,
            ),
            _buildRecentEntries(l10n),
          ],
        );
      },
    );
  }
}
