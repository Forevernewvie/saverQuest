import 'package:flutter/material.dart';

import '../../core/design/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class AsyncFeedback extends StatelessWidget {
  const AsyncFeedback.loading({super.key, this.label})
    : type = AsyncFeedbackType.loading,
      onRetry = null;

  const AsyncFeedback.error({
    super.key,
    required this.label,
    required this.onRetry,
  }) : type = AsyncFeedbackType.error;

  const AsyncFeedback.empty({super.key, this.label})
    : type = AsyncFeedbackType.empty,
      onRetry = null;

  final AsyncFeedbackType type;
  final String? label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AsyncFeedbackType.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncFeedbackType.error:
        return Column(
          children: [
            Text(label!, style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        );
      case AsyncFeedbackType.empty:
        return Text(
          label ?? context.l10n.noData,
          style: const TextStyle(color: AppColors.textSecondary),
        );
    }
  }
}

enum AsyncFeedbackType { loading, error, empty }
