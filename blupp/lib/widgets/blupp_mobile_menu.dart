import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import 'blupp_avatar.dart';
import 'blupp_search_dialog.dart';
import 'blupp_faq_and_contact.dart';

class BluppMobileMenu extends StatelessWidget {
  final FinanceState state;
  final int currentTabIndex;
  final Function(int) onNavigateTab;

  const BluppMobileMenu({
    super.key,
    required this.state,
    required this.currentTabIndex,
    required this.onNavigateTab,
  });

  static void show(
    BuildContext context, {
    required FinanceState state,
    required int currentTabIndex,
    required Function(int) onNavigateTab,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BluppMobileMenu(
        state: state,
        currentTabIndex: currentTabIndex,
        onNavigateTab: onNavigateTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
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
          const SizedBox(height: 18),

          // User Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              children: [
                BluppAvatar(state: state, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.userName.isNotEmpty ? state.userName : 'Blupp User',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.userEmail.isNotEmpty ? state.userEmail : 'Smart Wealth Member',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // 1-tap Dark Mode Toggle
                IconButton(
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppTheme.surfaceBorder),
                    ),
                  ),
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? const Color(0xFFFBBF24) : AppTheme.primaryTeal,
                    size: 18,
                  ),
                  onPressed: () {
                    state.toggleThemeMode();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Global Search Trigger
          InkWell(
            onTap: () {
              Navigator.pop(context);
              BluppSearchDialog.show(context, state: state, onNavigateTab: onNavigateTab);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: AppTheme.primaryTeal),
                  const SizedBox(width: 10),
                  Text(
                    'Search accounts, logs, budgets...',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Text(
                      '⌘K',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Navigation Menu List
          _buildNavTile(
            context,
            index: 0,
            icon: Icons.home_rounded,
            title: 'Home & Net Worth',
          ),
          _buildNavTile(
            context,
            index: 1,
            icon: Icons.receipt_long_rounded,
            title: 'Expenses & Transactions',
          ),
          _buildNavTile(
            context,
            index: 2,
            icon: Icons.insights_rounded,
            title: 'Analytics & Cash Flow',
          ),
          _buildNavTile(
            context,
            index: 3,
            icon: Icons.auto_awesome_rounded,
            title: 'FOMO AI Advisor',
          ),
          _buildNavTile(
            context,
            index: 4,
            icon: Icons.calendar_month_rounded,
            title: 'Scheduled Bills & Calendar',
          ),
          _buildNavTile(
            context,
            index: 5,
            icon: Icons.settings_outlined,
            title: 'Profile & Settings',
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
          const SizedBox(height: 10),

          // Secondary Quick Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    BluppContactSheet.show(context);
                  },
                  icon: const Icon(Icons.help_outline_rounded, size: 16),
                  label: const Text('Help & Support', style: TextStyle(fontSize: 12.5)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    BluppLegalDialogs.showPrivacyPolicy(context);
                  },
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: const Text('Privacy Policy', style: TextStyle(fontSize: 12.5)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Center(
            child: Text(
              'Blupp AI v1.0.0 • © ${DateTime.now().year} Blupp AI Inc.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = currentTabIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.pop(context);
            onNavigateTab(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryTeal,
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
