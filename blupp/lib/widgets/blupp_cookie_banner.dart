import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class BluppCookieBanner extends StatefulWidget {
  const BluppCookieBanner({super.key});

  @override
  State<BluppCookieBanner> createState() => _BluppCookieBannerState();
}

class _BluppCookieBannerState extends State<BluppCookieBanner> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasConsented = prefs.getBool('blupp_cookie_consent_accepted') ?? false;
      if (!hasConsented && mounted) {
        // Small delay so it animates in smoothly after initial render
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isVisible = true);
        });
      }
    } catch (_) {}
  }

  Future<void> _handleConsent(bool acceptAll) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('blupp_cookie_consent_accepted', true);
      await prefs.setBool('blupp_cookie_analytics_enabled', acceptAll);
    } catch (_) {}
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final isDark = AppTheme.isDark;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 84, // Sits comfortably above floating bottom bar
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xF218181B) : const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cookie_outlined,
                          size: 16,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Privacy & Cookie Preferences',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _handleConsent(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Blupp uses local storage and privacy-safe sync to securely save your financial accounts, envelope budgets, and AI insights. No third-party tracking or ad profiling.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => _handleConsent(false),
                        child: const Text('Essential Only'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _handleConsent(true),
                        child: const Text('Accept All'),
                      ),
                    ],
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
