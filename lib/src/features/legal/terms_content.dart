// terms_content.dart — Show Up's Terms & Agreement text.
//
// Shown at sign-up (auth_screen.dart, must be checked to create an account)
// and from Settings > Terms & Agreement (settings_screen.dart, view-only).
//
// kTermsVersion is stored alongside the acceptance timestamp
// (profiles.terms_version / terms_accepted_at) whenever a user accepts —
// bump it when the text changes materially, so a future session can detect
// "the version this user agreed to is out of date."

class TermsSection {
  final String title;
  final String body;
  const TermsSection(this.title, this.body);
}

const String kTermsVersion = '1.0';
const String kTermsEffectiveDate = 'September 17, 2026';

const List<TermsSection> kTermsSections = [
  TermsSection(
    'Beta software',
    'Show Up is currently in beta. Its sole purpose is learning and '
        'improving the underlying model and application — it is not a '
        'finished, production-grade product. Features may change, break, '
        'or be removed without notice, and data loss, downtime, or '
        'inaccurate results (including nutrition and habit calculations) '
        'can occur. Do not rely on Show Up for medical, nutritional, or '
        'health decisions; consult a qualified professional instead.',
  ),
  TermsSection(
    '1. Acceptance of terms',
    'By creating an account or using Show Up, you agree to be bound by '
        'these Terms & Agreement ("Terms"). If you do not agree, do not '
        'create an account or use the app.',
  ),
  TermsSection(
    '2. Description of service',
    'Show Up is a personal habit-tracking and nutrition-logging '
        'application. Content you enter — habits, meals, water intake, '
        'goals, and related data — is stored to provide the service back '
        'to you and, consistent with the app\'s beta purpose, to help '
        'evaluate and improve its behavior.',
  ),
  TermsSection(
    '3. Your account',
    'You are responsible for maintaining the confidentiality of your '
        'login credentials and for all activity under your account. You '
        'must provide accurate information when creating an account and '
        'promptly correct it if it changes.',
  ),
  TermsSection(
    '4. Acceptable use',
    'You agree not to misuse the service — including attempting to '
        'access another user\'s data, disrupt the service, or use it for '
        'any unlawful purpose. Access may be suspended or terminated for '
        'violations of these Terms.',
  ),
  TermsSection(
    '5. Your data & privacy',
    'Your data is used to operate the app for you and, given its beta '
        'purpose, to identify issues and improve functionality. Your '
        'personal data is not sold. You may request deletion of your '
        'account and all associated data at any time from Settings > '
        'Account > Delete Account, which permanently removes your habits, '
        'meals, goals, and profile information.',
  ),
  TermsSection(
    '6. No warranty',
    'The service is provided "as is" and "as available," without '
        'warranties of any kind, express or implied, including but not '
        'limited to fitness for a particular purpose, accuracy, or '
        'uninterrupted availability — consistent with its status as beta '
        'software under active development.',
  ),
  TermsSection(
    '7. Limitation of liability',
    'To the fullest extent permitted by law, Show Up and its developer '
        'are not liable for any indirect, incidental, or consequential '
        'damages, or for any loss of data, arising from use of the '
        'service.',
  ),
  TermsSection(
    '8. Changes to these terms',
    'These Terms may be updated as the app evolves. Material changes '
        'will be reflected here with an updated effective date; continued '
        'use of the app after a change constitutes acceptance of the '
        'revised Terms.',
  ),
  TermsSection(
    '9. Termination',
    'You may stop using Show Up and delete your account at any time. '
        'Accounts that violate these Terms may be suspended or '
        'terminated.',
  ),
  TermsSection(
    '10. Contact',
    'Questions about these Terms can be directed to the developer of '
        'this app.',
  ),
];
