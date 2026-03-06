import 'package:flutter/material.dart';

import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    this.eyebrow,
    required this.title,
    required this.body,
    this.trailing,
    this.pills = const [],
    this.primaryLabel,
    this.primarySemanticLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String? eyebrow;
  final String title;
  final String body;
  final Widget? trailing;
  final List<Widget> pills;
  final String? primaryLabel;
  final String? primarySemanticLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.surfaceAlt, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.m),
                trailing!,
              ],
            ],
          ),
          if (pills.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: pills,
            ),
          ],
          if (primaryLabel != null && onPrimary != null) ...[
            const SizedBox(height: AppSpacing.l),
            Semantics(
              label: primarySemanticLabel ?? primaryLabel,
              button: true,
              child: FilledButton(
                onPressed: onPrimary,
                child: Text(primaryLabel!),
              ),
            ),
          ],
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: AppSpacing.s),
            OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class AppMetricPill extends StatelessWidget {
  const AppMetricPill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeroIcon extends StatelessWidget {
  const AppHeroIcon({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.accent, size: 28),
    );
  }
}

class AppFeatureCard extends StatelessWidget {
  const AppFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.s),
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.m),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}

class AppQuickActionCard extends StatelessWidget {
  const AppQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.accent),
                const SizedBox(height: AppSpacing.s),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
