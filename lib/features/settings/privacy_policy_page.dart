import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../widgets/common/app_blocks.dart';
import '../../widgets/screen_shell.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  /// Builds the in-app privacy policy page from localized policy sections.
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ScreenShell(
      title: l10n.privacyPolicyPageTitle,
      children: [
        AppHeroCard(
          eyebrow: l10n.appTitle,
          title: l10n.privacyPolicyHeroTitle,
          body: l10n.privacyPolicyHeroBody,
          trailing: const AppHeroIcon(icon: Icons.privacy_tip_outlined),
        ),
        AppSectionHeader(
          title: l10n.privacyPolicySectionTitle,
          subtitle: l10n.privacyPolicySectionSubtitle,
        ),
        _buildPolicySection(
          icon: Icons.info_outline,
          title: l10n.privacyPolicyOverviewTitle,
          body: l10n.privacyPolicyOverviewBody,
        ),
        _buildPolicySection(
          icon: Icons.inventory_2_outlined,
          title: l10n.privacyPolicyCollectedDataTitle,
          body: l10n.privacyPolicyCollectedDataBody,
        ),
        _buildPolicySection(
          icon: Icons.flag_outlined,
          title: l10n.privacyPolicyPurposeTitle,
          body: l10n.privacyPolicyPurposeBody,
        ),
        _buildPolicySection(
          icon: Icons.hub_outlined,
          title: l10n.privacyPolicyThirdPartyTitle,
          body: l10n.privacyPolicyThirdPartyBody,
        ),
        _buildPolicySection(
          icon: Icons.tune_outlined,
          title: l10n.privacyPolicyChoicesTitle,
          body: l10n.privacyPolicyChoicesBody,
        ),
        _buildPolicySection(
          icon: Icons.schedule_outlined,
          title: l10n.privacyPolicyRetentionTitle,
          body: l10n.privacyPolicyRetentionBody,
        ),
        _buildPolicySection(
          icon: Icons.contact_mail_outlined,
          title: l10n.privacyPolicyContactTitle,
          body: l10n.privacyPolicyContactBody,
        ),
        _buildPolicySection(
          icon: Icons.link_outlined,
          title: l10n.privacyPolicyPublicUrlTitle,
          body: l10n.privacyPolicyPublicUrlBody,
        ),
      ],
    );
  }

  /// Builds a single privacy-policy section using the shared feature-card surface.
  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return AppFeatureCard(icon: icon, title: title, body: body);
  }
}
