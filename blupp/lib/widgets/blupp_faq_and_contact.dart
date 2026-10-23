import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'blupp_feedback.dart';

/// Expandable FAQ Accordion Widget
class BluppExpandableFaq extends StatefulWidget {
  const BluppExpandableFaq({super.key});

  @override
  State<BluppExpandableFaq> createState() => _BluppExpandableFaqState();
}

class _BluppExpandableFaqState extends State<BluppExpandableFaq> {
  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How does Blupp calculate my "Safe-to-Spend" balance?',
      'answer':
          'Safe-to-Spend dynamically scans your total liquid cash across all bank accounts and subtracts your pending bills, committed monthly envelope budgets, and reserve buffer. This ensures you never accidentally spend rent or savings money on discretionary purchases.',
    },
    {
      'question': 'Is my financial and banking data secure?',
      'answer':
          'Yes. Blupp uses client-side encryption and row-level security (RLS) powered by Supabase. Your raw bank credentials are never stored. iOS automation runs completely locally on your device via Apple Shortcuts.',
    },
    {
      'question': 'How does the Apple Shortcuts auto-sync work?',
      'answer':
          'Whenever you close a supported bank app (MAE, CIMB, TNG eWallet), an iOS Automation triggers a deep link that opens Blupp with your latest transaction ready for 1-tap categorization.',
    },
    {
      'question': 'Can I export my data or print financial reports?',
      'answer':
          'Yes! You can export your full transaction ledger as standard CSV format or print your monthly cash flow reports directly using browser print or PDF export from the Analytics screen.',
    },
    {
      'question': 'How does multi-currency conversion work?',
      'answer':
          'Blupp supports MYR, USD, SGD, EUR, GBP, and AUD. When you change your base currency in Settings, all account balances and budget limits are dynamically converted using live mid-market exchange rates.',
    },
  ];

  final Set<int> _expandedIndices = {0};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, size: 18, color: AppTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedIndices.contains(index);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded ? AppTheme.primaryTeal.withValues(alpha: 0.35) : AppTheme.surfaceBorder,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedIndices.remove(index);
                    } else {
                      _expandedIndices.add(index);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq['question']!,
                              style: TextStyle(
                                color: isExpanded ? AppTheme.primaryTeal : AppTheme.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: isExpanded ? AppTheme.primaryTeal : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        Divider(height: 1, color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        Text(
                          faq['answer']!,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Floating Contact & Support Sheet
class BluppContactSheet {
  static const String supportEmail = 'support@blupp.ai';
  static const String supportPhone = '+60123456789';
  static const String supportPhoneDisplay = '+60 12-345 6789';

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Blupp Support',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Our engineering & finance team is here to assist.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Clickable Email Card
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: 'Email Us Directly',
              value: supportEmail,
              onTap: () async {
                final uri = Uri.parse('mailto:$supportEmail?subject=Blupp%20Finance%20Support%20Inquiry');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    BluppToast.showSuccess(context, 'Copied $supportEmail to clipboard');
                  }
                }
              },
            ),
            const SizedBox(height: 10),

            // Clickable Phone Card
            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Customer Hotline',
              value: supportPhoneDisplay,
              onTap: () async {
                final uri = Uri.parse('tel:$supportPhone');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    BluppToast.showSuccess(context, 'Copied $supportPhone to clipboard');
                  }
                }
              },
            ),
            const SizedBox(height: 10),

            // Office Hours & Response Time
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Support Hours: Mon - Fri, 9:00 AM - 6:00 PM (GMT+8). Average response time: < 15 mins.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppTheme.primaryTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                BluppCopyButton(textToCopy: value, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Legal dialog viewers for footer links (Privacy Policy, Terms of Service, Security)
class BluppLegalDialogs {
  static void showPrivacyPolicy(BuildContext context) {
    _showLegalSheet(
      context,
      title: 'Privacy Policy',
      content: '''
Last Updated: October 2026

1. Information We Collect
Blupp collects account emails and transaction metadata that you explicitly log or sync via bank receipts. We do not sell your personal data.

2. Client-Side Security & Encryption
All sensitive data transfers are secured via TLS 1.3 encryption. Your financial summaries are tied strictly to your authenticated session.

3. Analytics & Cookies
We utilize privacy-first local caching to ensure zero latency when managing accounts offline. You may clear your local cache at any time.

4. Contact Us
If you have questions regarding data retention or deletion, please reach out to privacy@blupp.ai.
''',
    );
  }

  static void showTermsOfService(BuildContext context) {
    _showLegalSheet(
      context,
      title: 'Terms of Service',
      content: '''
Last Updated: October 2026

1. Purpose of Service
Blupp provides personal financial tracking, budgeting aids, and generative AI analysis. Blupp does not constitute licensed fiduciary advice.

2. User Responsibilities
You are responsible for keeping your credentials and API keys confidential.

3. Data Accuracy
While Blupp AI parses receipts with high fidelity, always review categorized amounts before finalizing tax or balance filings.

4. Governing Law
These terms are governed by applicable Malaysian and international cyber consumer protection frameworks.
''',
    );
  }

  static void showSecurityWhitepaper(BuildContext context) {
    _showLegalSheet(
      context,
      title: 'Security & Encryption Architecture',
      content: '''
Last Updated: October 2026

• Zero Knowledge Credentials: Blupp never asks for your bank password or OTP.
• Apple Shortcut Local Execution: Parsing of SMS and push notifications runs on-device.
• Row-Level Security (RLS): Supabase database policies isolate user records with cryptographic token authentication.
• Regular Penetration Testing: Routine security reviews ensure endpoints remain protected against unauthorized access.
''',
    );
  }

  static void _showLegalSheet(BuildContext context, {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppTheme.surfaceBorder),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
