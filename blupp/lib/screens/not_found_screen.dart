import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_logo.dart';

class BluppNotFoundScreen extends StatelessWidget {
  final VoidCallback? onReturnHome;

  const BluppNotFoundScreen({super.key, this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BluppLogo(size: 48, iconOnly: true, isDark: AppTheme.isDark),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.expenseCoral),
                        const SizedBox(width: 6),
                        Text(
                          '404 — Route Not Found',
                          style: TextStyle(
                            color: AppTheme.expenseCoral,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lost in Cash Flow?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The page or transaction record you are looking for does not exist or has been relocated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (onReturnHome != null) {
                          onReturnHome!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text(
                        'Return to Dashboard',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '© ${DateTime.now().year} Blupp AI Inc. All rights reserved.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
