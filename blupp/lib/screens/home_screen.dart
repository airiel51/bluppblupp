import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';
import '../widgets/blupp_avatar.dart';
import '../widgets/ai_safe_to_spend_card.dart';
import '../widgets/ai_quick_log_sheet.dart';
import '../widgets/ai_receipt_scanner_sheet.dart';

class HomeScreen extends StatefulWidget {
  final FinanceState state;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAllAccounts = false;
  bool _showAiRadar = false;
  double _dailyLimit = 1000.0;
  final double _dailySpent = 719.0;
  double _monthlyLimit = 30000.0;
  final double _monthlySpent = 12480.0;

  FinanceState get state => widget.state;
  Function(int) get onNavigateTab => widget.onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryTeal,
          onRefresh: () => state.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar: Avatar & Notification Bell
                _buildHeader(context),
                const SizedBox(height: 18),

                // 1. Available Balance Hero Card (Royal Violet Gradient with 4 circular buttons)
                _buildAvailableBalanceHeroCard(context),
                const SizedBox(height: 22),

                // 2. Accounts Section (2x2 Grid with USD, JPY, BTC, USDT / Banks, expandable to full accounts list)
                _buildAccountsGridSection(context),
                const SizedBox(height: 24),

                // 3. Limits Section (Daily Limit 75% + Monthly Limit 45%)
                _buildLimitsSection(context),
                const SizedBox(height: 24),

                // 4. Recent Transactions (Olivia Spencer +$10.00, Airbnb Homestay -€49.00 / real txs)
                _buildRecentTransactionsSection(context),
                const SizedBox(height: 24),

                // 5. Blupp AI Assistant Radar & Scanner Dock
                _buildSmartAiSection(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  // Header matching Dribbble middle screen: Profile Avatar on left, Notification bell with alert dot on right
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            BluppAvatar(
              state: state,
              size: 40,
              showEditBadge: false,
              onTap: () => onNavigateTab(6),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  state.userName.isNotEmpty ? state.userName : "Airiel",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showNotificationSheet(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                Positioned(
                  top: 11,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentCoral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 1. AVAILABLE BALANCE HERO CARD (Royal Violet Gradient, 4 White Circular Buttons, Withhold Balance)
  Widget _buildAvailableBalanceHeroCard(BuildContext context) {
    final availableBalance = state.totalBankBalance > 0
        ? state.totalBankBalance
        : 1021.65;
    final withholdBalance = state.totalLoans > 0
        ? state.totalLoans
        : 322.92;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroVioletGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382BF0).withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available balance title & Currency badge pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Available balance",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () => _showCurrencyPickerSheet(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.baseCurrency.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Bold Balance Amount
          Row(
            children: [
              Expanded(
                child: Text(
                  state.isNetWorthHidden
                      ? "••••••••••"
                      : AppTheme.formatCurrency(availableBalance),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: state.isNetWorthHidden ? 3.0 : -1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: state.toggleNetWorthVisibility,
                icon: Icon(
                  state.isNetWorthHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 20,
                ),
                tooltip: state.isNetWorthHidden ? "Show balance" : "Hide balance",
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 4 Circular Action Buttons (+ Top-up, ↑ Send, ⇄ Exchange, 📊 Analytics)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleHeroAction(
                icon: Icons.add_rounded,
                tooltip: "Top-up / Add Money",
                onTap: () {
                  if (state.bankAccounts.isNotEmpty) {
                    _showAddMoneyDialog(context, state.bankAccounts.first);
                  } else {
                    _showAddBankDialog(context);
                  }
                },
              ),
              _buildCircleHeroAction(
                icon: Icons.arrow_upward_rounded,
                tooltip: "Send / Transfer",
                onTap: () => _showTransferMoneyDialog(context),
              ),
              _buildCircleHeroAction(
                icon: Icons.swap_horiz_rounded,
                tooltip: "Exchange Currency",
                onTap: () => _showCurrencyPickerSheet(context),
              ),
              _buildCircleHeroAction(
                icon: Icons.bar_chart_rounded,
                tooltip: "Analytics & Radar",
                onTap: () => onNavigateTab(3),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Withhold Balance Footer
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 0.9,
                ),
              ),
            ),
            child: InkWell(
              onTap: () => _showNetWorthFormulaSheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Withhold balance",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    state.isNetWorthHidden
                        ? "••••"
                        : AppTheme.formatCurrency(withholdBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Circular white action button inside hero card
  Widget _buildCircleHeroAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF161720),
            size: 23,
          ),
        ),
      ),
    );
  }

  // 2. ACCOUNTS SECTION (2x2 Grid with White active card + Dark cards, or full list)
  Widget _buildAccountsGridSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Accounts",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showAllAccounts = !_showAllAccounts;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  _showAllAccounts ? "Show grid" : "See all",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (!_showAllAccounts) ...[
          // Row 1: USD (Highlighted White card) & JPY (Dark card)
          Row(
            children: [
              // Card 1: Highlighted Active Card (White crisp style from Dribbble)
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (state.bankAccounts.isNotEmpty) {
                      _showManageBankSheet(context, state.bankAccounts.first);
                    } else {
                      _showAddBankDialog(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text("🇺🇸", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              "USD",
                              style: TextStyle(
                                color: Color(0xFF0F1015),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          state.isNetWorthHidden
                              ? "••••"
                              : (state.bankAccounts.isNotEmpty
                                  ? AppTheme.formatCurrency(state.bankAccounts.first.balance)
                                  : "\$1,200.81"),
                          style: const TextStyle(
                            color: Color(0xFF0F1015),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card 2: JPY Dark Card
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (state.bankAccounts.length > 1) {
                      _showManageBankSheet(context, state.bankAccounts[1]);
                    } else {
                      _showAddBankDialog(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("🇯🇵", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              "JPY",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                state.isNetWorthHidden
                                    ? "••••"
                                    : (state.bankAccounts.length > 1
                                        ? AppTheme.formatCurrency(state.bankAccounts[1].balance)
                                        : "¥9,444.71"),
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "\$64.2",
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: BTC (Crypto Card) & USDT (Liabilities / Stablecoin Card)
          Row(
            children: [
              // Card 3: BTC Dark Card
              Expanded(
                child: InkWell(
                  onTap: () => _showAddInvestmentDialog(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "₿",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "BTC",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                state.isNetWorthHidden
                                    ? "••••"
                                    : (state.investments.isNotEmpty
                                        ? AppTheme.formatCurrency(state.totalInvestmentsAndSavings)
                                        : "0.055721"),
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "\$72.12",
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card 4: USDT Dark Card
              Expanded(
                child: InkWell(
                  onTap: () => _showAddLoanDialog(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "₮",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "USDT",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                state.isNetWorthHidden
                                    ? "••••"
                                    : (state.loans.isNotEmpty
                                        ? AppTheme.formatCurrency(state.totalLoans)
                                        : "0.015"),
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "\$0.015",
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Expanded full list view for all Banks, Investments, and Liabilities
          _buildBankAccountsSection(context),
          const SizedBox(height: 24),
          _buildInvestmentsSection(context),
          const SizedBox(height: 24),
          _buildLoansSection(context),
        ],
      ],
    );
  }

  // 3. LIMITS SECTION (Daily Limit 75% + Monthly Limit 45%)
  Widget _buildLimitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Limits",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            InkWell(
              onTap: () => _showEditLimitsSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            // Daily limit card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily limit",
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "\$${_dailySpent.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: " / \$${_dailyLimit.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          "75%",
                          style: const TextStyle(
                            color: AppTheme.accentCoral,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Color(0xFF222430),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Monthly limit card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly limit",
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "\$${_monthlySpent.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: " / \$${_monthlyLimit.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          "45%",
                          style: const TextStyle(
                            color: AppTheme.accentAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.45,
                              backgroundColor: Color(0xFF222430),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentAmber),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. SMART AI RADAR & OCR QUICK SCANNER DOCK
  Widget _buildSmartAiSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.primaryTeal,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Blupp AI Copilot & Scanner",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showAiRadar = !_showAiRadar;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showAiRadar ? "Hide" : "Expand",
                        style: TextStyle(
                          color: AppTheme.primaryTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _showAiRadar
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAiFeatureDock(context),
          if (_showAiRadar) ...[
            const SizedBox(height: 14),
            AiSafeToSpendCard(state: state),
          ],
        ],
      ),
    );
  }

  // Notification Sheet matching bell button
  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Notifications",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Mark all read",
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildNotificationItem(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.primaryTeal,
              title: "Safe-to-Spend Radar Active",
              description: "Your daily spending buffer is healthy. Enjoy your financial runway.",
              time: "Just now",
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.credit_card_rounded,
              iconColor: const Color(0xFFF472B6),
              title: "Virtual Card Ready",
              description: "Your General Card USD is active for contactless and online checkouts.",
              time: "2h ago",
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.speed_rounded,
              iconColor: AppTheme.accentAmber,
              title: "Monthly Limit Update",
              description: "45% of your planned monthly budget consumed. On track for surplus.",
              time: "Yesterday",
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Currency Picker Sheet
  void _showCurrencyPickerSheet(BuildContext context) {
    final currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': 'United States Dollar', 'flag': '🇺🇸'},
      {'code': 'MYR', 'symbol': 'RM', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾'},
      {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar', 'flag': '🇸🇬'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro', 'flag': '🇪🇺'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound', 'flag': '🇬🇧'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
      {'code': 'BTC', 'symbol': '₿', 'name': 'Bitcoin', 'flag': '🪙'},
      {'code': 'USDT', 'symbol': '₮', 'name': 'Tether USD', 'flag': '🟢'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Currency",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Convert all stored values and display units automatically.",
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: currencies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (ctx, index) {
                  final c = currencies[index];
                  final isSelected = state.baseCurrency.toUpperCase() == c['code'];
                  return InkWell(
                    onTap: () {
                      state.setBaseCurrency(c['code']!);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(c['flag']!, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${c['code']} (${c['symbol']})",
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  c['name']!,
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Edit Limits Sheet
  void _showEditLimitsSheet(BuildContext context) {
    final dailyCtrl = TextEditingController(text: _dailyLimit.toStringAsFixed(0));
    final monthlyCtrl = TextEditingController(text: _monthlyLimit.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Adjust Spending Limits",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Keep your budget strictly disciplined with dynamic limit tracking.",
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Daily Spending Limit",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dailyCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: "${state.baseCurrency} ",
                prefixStyle: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Monthly Spending Limit",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: monthlyCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: "${state.baseCurrency} ",
                prefixStyle: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF161720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final d = double.tryParse(dailyCtrl.text) ?? _dailyLimit;
                  final m = double.tryParse(monthlyCtrl.text) ?? _monthlyLimit;
                  setState(() {
                    _dailyLimit = d;
                    _monthlyLimit = m;
                  });
                  state.setMonthlyBudget(m);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  "Save Limits",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI Feature Launch Dock
  Widget _buildAiFeatureDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          // Natural Language Quick-Logger
          Expanded(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AiQuickLogSheet(state: state),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      "AI Quick-Log",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Vision AI Receipt Scanner
          Expanded(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AiReceiptScannerSheet(state: state),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner_rounded, size: 15, color: Color(0xFF00E5FF)),
                    SizedBox(width: 6),
                    Text(
                      "Scan Receipt/QR",
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // 2. ALL BANK ACCOUNTS SECTION
  Widget _buildBankAccountsSection(BuildContext context) {
    final totalBank = state.totalBankBalance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bank Accounts",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Total in Banks: ${AppTheme.formatCurrency(totalBank)}",
                  style: TextStyle(color: AppTheme.primaryTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.primaryTeal),
              tooltip: "Add Bank Account",
              onPressed: () => _showAddBankDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (state.isRefreshing)
          BluppSkeleton.bankCardsList()
        else if (state.bankAccounts.isEmpty)
          BluppEmptyState(
            icon: Icons.account_balance_outlined,
            title: "No bank accounts linked",
            description: "Add your primary banks to monitor real-time net worth and automated liquidity balances.",
            actionLabel: "Add Bank Account",
            onAction: () => _showAddBankDialog(context),
          )
        else
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.bankAccounts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final bank = state.bankAccounts[index];
                return _buildBankCard(bank, context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBankCard(BankAccount bank, BuildContext context) {
    return InteractiveCard(
      onTap: () => _showManageBankSheet(context, bank),
      padding: const EdgeInsets.all(14),
      radius: 16,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bank.color.withValues(alpha: 0.38), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bank.color.withValues(alpha: 0.16),
            AppTheme.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: bank.color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: bank.color.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: bank.color.withValues(alpha: 0.45)),
                  ),
                  child: Icon(bank.icon, color: bank.color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bank.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => _showBankColorPicker(context, bank),
                  borderRadius: BorderRadius.circular(6),
                  child: Tooltip(
                    message: "Change Bank Color",
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: bank.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: bank.color,
                        size: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _confirmDeleteBank(context, bank),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.accountNumber,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: bank.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: bank.color.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppTheme.formatCurrency(bank.balance),
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => _showAddMoneyDialog(context, bank),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          "Add",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _showMinusBankMoneyDialog(context, bank),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_rounded, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          "Minus",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBankColorPicker(BuildContext context, BankAccount bank) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bank.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.palette_rounded, color: bank.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Choose Colour for ${bank.name}",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Pick a brand theme or your preferred accent color",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: BankAccount.colorPresets.map((preset) {
                      final c = preset['color'] as Color;
                      final isSelected = bank.color.toARGB32() == c.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          state.updateBankAccountColor(bank.id, c);
                          setSheetState(() {});
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Updated ${bank.name} color to ${preset['name']}"),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: c.withValues(alpha: 0.6),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 56,
                              child: Text(
                                preset['name'].toString().split(' ').first,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. INVESTMENTS & SAVINGS (ASNB, etc.)
  Widget _buildInvestmentsSection(BuildContext context) {
    final totalInvestments = state.totalInvestmentsAndSavings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Investments & Savings",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Portfolio Total: ${AppTheme.formatCurrency(totalInvestments)}",
                  style: TextStyle(color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.textSecondary),
              tooltip: "Add Investment or Savings",
              onPressed: () => _showAddInvestmentDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.investments.isEmpty)
          BluppEmptyState(
            icon: Icons.savings_outlined,
            title: "No investments or savings",
            description: "Track your ASNB, Tabung Haji, stocks, or emergency savings here.",
            actionLabel: "Add Asset",
            onAction: () => _showAddInvestmentDialog(context),
          )
        else
          Column(
            children: state.investments.map((inv) {
              return InteractiveCard(
                onTap: () => _showManageInvestmentSheet(context, inv),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: inv.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(inv.icon, color: inv.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.name,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inv.institution,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "+${inv.returnRateAnnual}% p.a.",
                              style: const TextStyle(
                                color: AppTheme.primaryTeal,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppTheme.formatCurrency(inv.balance),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus / Withdraw quick button
                            InkWell(
                              onTap: () => _showMinusInvestmentDialog(context, inv),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_rounded, size: 13, color: Colors.orangeAccent),
                                    SizedBox(width: 3),
                                    Text(
                                      "Minus",
                                      style: TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Delete quick button
                            InkWell(
                              onTap: () => _confirmDeleteInvestment(context, inv),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppTheme.expenseCoral.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.35)),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14,
                                  color: AppTheme.expenseCoral,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // 4. LOANS & LIABILITIES
  Widget _buildLoansSection(BuildContext context) {
    final totalLoans = state.totalLoans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Loans & Liabilities",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Deducted from Net Worth: -${AppTheme.formatCurrency(totalLoans)}",
                  style: TextStyle(color: AppTheme.expenseCoral,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.expenseCoral),
              tooltip: "Add Loan or Commitment",
              onPressed: () => _showAddLoanDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.loans.isEmpty)
          BluppEmptyState(
            icon: Icons.check_circle_outline,
            title: "Debt-free status",
            description: "You currently have no recorded loans or liabilities.",
            actionLabel: "Add Liability",
            onAction: () => _showAddLoanDialog(context),
          )
        else
          Column(
            children: state.loans.asMap().entries.map((entry) {
              final index = entry.key;
              final loan = entry.value;
              return InteractiveCard(
                onTap: () => _showManageLoanSheet(context, loan),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: loan.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(loan.icon, color: loan.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.name,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Due on ${loan.dueDayOfMonth}th",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: loan.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Monthly: ${AppTheme.formatCurrency(loan.monthlyInstallment)}",
                              style: TextStyle(
                                color: loan.color,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppTheme.formatCurrency(loan.remainingBalance),
                          style: TextStyle(
                            color: loan.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus / Pay Down quick button
                            InkWell(
                              onTap: () => _showMinusLoanDialog(context, loan),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.35)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_rounded, size: 13, color: AppTheme.primaryTeal),
                                    SizedBox(width: 3),
                                    Text(
                                      "Minus",
                                      style: TextStyle(
                                        color: AppTheme.primaryTeal,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Delete quick button
                            InkWell(
                              onTap: () => _confirmDeleteLoan(context, loan),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppTheme.expenseCoral.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.35)),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14,
                                  color: AppTheme.expenseCoral,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 60 * index)).slideY(begin: 0.08, end: 0);
            }).toList(),
          ),
      ],
    );
  }

  // Recent transactions preview matching Dribbble reference UI
  Widget _buildRecentTransactionsSection(BuildContext context) {
    final recent = state.transactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent transactions",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            GestureDetector(
              onTap: () => onNavigateTab(2),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "See all",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (recent.isNotEmpty)
          Column(
            children: recent.map((tx) {
              final category = state.getCategoryById(tx.categoryId);
              final isExpense = tx.type == TransactionType.expense;
              final isTransfer = tx.isTransfer || state.isTransferOrTopUp(tx);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon, color: category.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${category.name} · ${tx.date.day}/${tx.date.month}",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isTransfer
                              ? "⇄ ${AppTheme.formatCurrency(tx.amount)}"
                              : "${isExpense ? '-' : '+'}${AppTheme.formatCurrency(tx.amount)}",
                          style: TextStyle(
                            color: isTransfer
                                ? const Color(0xFF38BDF8)
                                : (isExpense ? AppTheme.textPrimary : const Color(0xFF4ADE80)),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (tx.bankAccountId.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            state.getBankById(tx.bankAccountId)?.name ?? "",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.expenseCoral),
                      onPressed: () => _confirmDeleteTransaction(context, tx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: "Delete transaction",
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        else
          // High-fidelity reference mock items matching Dribbble screenshot
          Column(
            children: [
              // 1. Olivia Spencer
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Olivia Spencer",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Recieved · 12:04",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      r"+$10.00",
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Airbnb Homestay
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A5F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5A5F).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Airbnb Homestay",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Payment · Yesterday",
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "-€49.00",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "\$880.00",
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _confirmDeleteTransaction(BuildContext context, TransactionItem tx) {
    final isExpense = tx.type == TransactionType.expense;
    final bank = state.getBankById(tx.bankAccountId);
    final bankName = bank?.name ?? 'Bank Account';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              isExpense ? "Delete Expense" : "Delete Income",
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete '${tx.title}'?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: ${AppTheme.formatCurrency(tx.amount)}\n${isExpense ? 'This will restore ${AppTheme.formatCurrency(tx.amount)} back to $bankName and increase your spending balance.' : 'This will deduct ${AppTheme.formatCurrency(tx.amount)} from $bankName.'}\nYour net worth and Supabase cloud records will update automatically.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteTransaction(tx.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.expenseCoral, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Deleted '${tx.title}' (${isExpense ? 'Expense' : 'Income'})",
                        style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Formula Breakdown Bottom Sheet
  void _showNetWorthFormulaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Net Worth Formula",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Total Net Worth is dynamically synchronized across your bank balances, investments, and liabilities:",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              _buildFormulaRow("All Banks Balance", "+ ${AppTheme.formatCurrency(state.totalBankBalance)}", AppTheme.textSecondary),
              _buildFormulaRow("Investments & ASNB", "+ ${AppTheme.formatCurrency(state.totalInvestmentsAndSavings)}", AppTheme.textSecondary),
              _buildFormulaRow("Loans & Liabilities", "- ${AppTheme.formatCurrency(state.totalLoans)}", AppTheme.expenseCoral),
              Divider(color: AppTheme.surfaceBorder, height: 24),
              _buildFormulaRow("TOTAL NET WORTH", AppTheme.formatCurrency(state.totalNetWorth), AppTheme.textPrimary, isBold: true),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormulaRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isBold ? 16 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog: Add Bank Account
  void _showAddBankDialog(BuildContext context) {
    final nameController = TextEditingController();
    final accController = TextEditingController();
    final balanceController = TextEditingController();
    String accountType = 'Savings';
    Color selectedColor = const Color(0xFF10B981);
    bool userManuallyPickedColor = false;
    String? nameError;
    String? balanceError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: selectedColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Link Bank Account",
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horizontal Boxed Type Selector
                    Text("Account Type", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    BluppBoxedSegment<String>(
                      selectedValue: accountType,
                      items: const [
                        BluppSegmentItem(value: 'Savings', label: 'Savings', icon: Icons.account_balance_outlined),
                        BluppSegmentItem(value: 'Current', label: 'Current', icon: Icons.credit_card_outlined),
                        BluppSegmentItem(value: 'Wallet', label: 'E-Wallet', icon: Icons.phone_android_outlined),
                      ],
                      onSelected: (val) {
                        setDialogState(() {
                          accountType = val;
                          if (!userManuallyPickedColor) {
                            if (val == 'Wallet') {
                              selectedColor = const Color(0xFF0284C7);
                            } else {
                              selectedColor = BankAccount.guessColor(nameController.text.trim());
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Bank Name Field with Hint
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Bank / Institution Name",
                        hintText: "e.g. Maybank, CIMB, Bank Islam, RHB",
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          if (nameError != null) nameError = null;
                          if (!userManuallyPickedColor && val.trim().isNotEmpty) {
                            selectedColor = BankAccount.guessColor(val);
                          }
                        });
                      },
                    ),
                    BluppFieldError(fieldName: "Bank Name", errorMessage: nameError),
                    const SizedBox(height: 12),

                    // Account Number with Hint
                    TextField(
                      controller: accController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Account Number (Masked or Partial)",
                        hintText: "e.g. •••• 1234 or 5140 1234 5678",
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Balance with Hint
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Current Balance (${state.baseCurrency})",
                        hintText: "e.g. 2,500.00",
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (_) {
                        if (balanceError != null) setDialogState(() => balanceError = null);
                      },
                    ),
                    BluppFieldError(fieldName: "Starting Balance", errorMessage: balanceError),
                    const SizedBox(height: 14),

                    // Card Colour Palette
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Card & Theme Colour", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BankAccount.colorPresets.map((preset) {
                        final c = preset['color'] as Color;
                        final isSelected = selectedColor.toARGB32() == c.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = c;
                              userManuallyPickedColor = true;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final acc = accController.text.trim();
                    final balanceText = balanceController.text.trim().replaceAll(',', '');
                    final balance = double.tryParse(balanceText);

                    bool hasError = false;
                    if (name.isEmpty) {
                      setDialogState(() => nameError = "Where: Bank Name • Why: Name is required to track this account");
                      hasError = true;
                    }
                    if (balance == null) {
                      setDialogState(() => balanceError = "Where: Starting Balance • Why: Enter a valid numeric amount (e.g. 1500.00)");
                      hasError = true;
                    }

                    if (!hasError) {
                      state.addBankAccount(
                        name,
                        acc.isEmpty ? '•••• 0000' : acc,
                        balance!,
                        selectedColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Minus / Withdraw Money from Bank Account
  void _showMinusBankMoneyDialog(BuildContext context, BankAccount bank) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Withdrawal from ${bank.name}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingBalance = (bank.balance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.35)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.remove_circle_outline_rounded, color: Colors.orangeAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Withdraw",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        Text(
                          "${bank.name} (${bank.accountNumber})",
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Balance", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(bank.balance), style: TextStyle(color: bank.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Minus", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(remainingBalance), style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          {"label": "+RM 500", "amt": 500.0},
                          {"label": "All", "amt": bank.balance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Deduct (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.money_off_rounded, color: Colors.orangeAccent),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusMoneyFromBank(
                        bank.id,
                        amount,
                        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                      );
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Withdrew ${AppTheme.formatCurrency(amount)} from ${bank.name}",
                                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Minus", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Add Money to Bank Account
  void _showAddMoneyDialog(BuildContext context, BankAccount bank) {
    final amountController = TextEditingController();
    final otherBanks = state.bankAccounts.where((b) => b.id != bank.id).toList();
    bool isTransferMode = false;
    String fromBankId = otherBanks.isNotEmpty ? otherBanks.first.id : '';
    final noteController = TextEditingController(text: 'Top up to ${bank.name}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void setQuickAmount(double amt) {
              setDialogState(() {
                amountController.text = amt.toStringAsFixed(0);
              });
            }

            final fromBank = otherBanks.isNotEmpty
                ? state.getBankById(fromBankId)
                : null;

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isTransferMode
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                      : AppTheme.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTransferMode ? Icons.swap_horiz_rounded : Icons.add_card_rounded,
                      color: isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTransferMode ? "Transfer To Bank" : "Add Money",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        Text(
                          bank.name,
                          style: TextStyle(
                            color: isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Target Bank Balance: ${AppTheme.formatCurrency(bank.balance)}",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // Top up Mode Selector (if other banks exist)
                    if (otherBanks.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    isTransferMode = false;
                                    noteController.text = 'Top up to ${bank.name}';
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isTransferMode ? AppTheme.primaryTeal : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Direct Deposit",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !isTransferMode ? Colors.black : AppTheme.textMuted,
                                      fontWeight: !isTransferMode ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    isTransferMode = true;
                                    noteController.text = 'Top up from ${fromBank?.name ?? "another bank"}';
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isTransferMode ? const Color(0xFF38BDF8) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "From Other Bank",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isTransferMode ? Colors.black : AppTheme.textMuted,
                                      fontWeight: isTransferMode ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // If Transfer Mode: Show Source Bank Dropdown and Helper Info
                    if (isTransferMode && fromBank != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF38BDF8)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Internal transfers do NOT count in your monthly living expenses.",
                                style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Transfer From:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: fromBankId,
                            isExpanded: true,
                            dropdownColor: AppTheme.surface,
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                            items: otherBanks.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text("${b.name} (${AppTheme.formatCurrency(b.balance)})"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  fromBankId = val;
                                  noteController.text = 'Top up from ${state.getBankById(val)?.name ?? "bank"}';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Quick Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [50.0, 100.0, 200.0, 500.0, 1000.0].map((amt) {
                        return InkWell(
                          onTap: () => setQuickAmount(amt),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Text(
                              "+RM ${amt.toInt()}",
                              style: TextStyle(
                                color: isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Amount (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payments_outlined, color: isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTransferMode ? const Color(0xFF38BDF8) : AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      if (isTransferMode && fromBank != null) {
                        if (fromBank.balance < amount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.expenseCoral,
                              content: Text("Insufficient funds in ${fromBank.name} (${AppTheme.formatCurrency(fromBank.balance)})"),
                            ),
                          );
                          return;
                        }
                        state.addMoneyToBank(
                          bank.id,
                          amount,
                          note: noteController.text.trim(),
                          fromBankId: fromBank.id,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surfaceLight,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Transferred ${AppTheme.formatCurrency(amount)} from ${fromBank.name} to ${bank.name} (Exempt from Expenses)",
                                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        state.addMoneyToBank(bank.id, amount, note: noteController.text.trim());
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surfaceLight,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Added ${AppTheme.formatCurrency(amount)} to ${bank.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    isTransferMode ? "Confirm Transfer" : "Confirm Deposit",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTransferMoneyDialog(BuildContext context, [BankAccount? defaultFromBank]) {
    if (state.bankAccounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceLight,
          content: Text(
            "You need at least 2 bank accounts to transfer between them.",
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      );
      return;
    }

    String fromBankId = defaultFromBank?.id ?? state.bankAccounts.first.id;
    String toBankId = state.bankAccounts.firstWhere((b) => b.id != fromBankId, orElse: () => state.bankAccounts.last).id;

    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Transfer between accounts');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final fromBank = state.getBankById(fromBankId);
            final toBank = state.getBankById(toBankId);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF38BDF8), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Transfer Between Banks",
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF38BDF8)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Internal bank transfers reallocate money and are NOT counted as living expenses.",
                              style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // From Bank
                    Text("From Source Bank:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: fromBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: state.bankAccounts.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text("${b.name} (${AppTheme.formatCurrency(b.balance)})"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                fromBankId = val;
                                if (toBankId == fromBankId) {
                                  toBankId = state.bankAccounts.firstWhere((b) => b.id != fromBankId).id;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // To Bank
                    Text("To Destination Bank:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: toBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: state.bankAccounts.where((b) => b.id != fromBankId).map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text("${b.name} (${AppTheme.formatCurrency(b.balance)})"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                toBankId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Transfer Amount (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF38BDF8)),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0 && fromBank != null && toBank != null) {
                      if (fromBank.balance < amount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.expenseCoral,
                            content: Text("Insufficient balance in ${fromBank.name} (${AppTheme.formatCurrency(fromBank.balance)})"),
                          ),
                        );
                        return;
                      }
                      state.transferBetweenBanks(
                        fromBankId: fromBank.id,
                        toBankId: toBank.id,
                        amount: amount,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Transferred ${AppTheme.formatCurrency(amount)} from ${fromBank.name} to ${toBank.name}",
                                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Transfer", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Confirm Delete Bank
  void _confirmDeleteBank(BuildContext context, BankAccount bank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Account", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${bank.name} (${bank.accountNumber})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Balance: ${AppTheme.formatCurrency(bank.balance)}\nThis will remove the account from your net worth and synchronize with Supabase.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteBankAccount(bank.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${bank.name} from bank accounts",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet: Manage Bank Account Details & Actions
  void _showManageBankSheet(BuildContext context, BankAccount bank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            final currentBank = state.getBankById(bank.id) ?? bank;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: currentBank.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: currentBank.color.withValues(alpha: 0.4)),
                        ),
                        child: Icon(currentBank.icon, color: currentBank.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentBank.name,
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              currentBank.accountNumber,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppTheme.formatCurrency(currentBank.balance),
                        style: TextStyle(color: currentBank.color, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action: Card Colour Theme
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: currentBank.color.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette_outlined, color: currentBank.color, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Card Colour Theme",
                                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: currentBank.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: BankAccount.colorPresets.map((preset) {
                            final c = preset['color'] as Color;
                            final isSelected = currentBank.color.toARGB32() == c.toARGB32();
                            return GestureDetector(
                              onTap: () {
                                state.updateBankAccountColor(currentBank.id, c);
                                setSheetState(() {});
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: c.withValues(alpha: 0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppTheme.surfaceBorder, height: 1),
                  const SizedBox(height: 16),

              // Action 1: Add Money
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddMoneyDialog(context, bank);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryTeal, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add Money to Balance",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Top up, deposit, or record transfer into this bank",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryTeal, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (state.bankAccounts.length >= 2) ...[
                // Action: Transfer Between Banks
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _showTransferMoneyDialog(context, bank);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, color: Color(0xFF38BDF8), size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transfer to Another Bank",
                                style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "Move money to or from another bank without adding to expenses",
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF38BDF8), size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action 2: Minus / Withdraw Money
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showMinusBankMoneyDialog(context, bank);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle_outline_rounded, color: Colors.orangeAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minus / Withdraw Money",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Withdraw cash or deduct balance from this bank",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orangeAccent, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 3: Delete Bank Account
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteBank(context, bank);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseCoral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delete Bank Account",
                              style: TextStyle(color: AppTheme.expenseCoral, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Permanently remove this account and sync with Supabase",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.expenseCoral, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  },
);
}

  // Dialog: Add Loan
  void _showAddLoanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final providerController = TextEditingController();
    final totalController = TextEditingController();
    final monthlyController = TextEditingController();
    String loanType = 'Vehicle';
    String? errorWhere;
    String? errorWhy;

    final typeOptions = [
      {'value': 'Vehicle', 'label': 'Vehicle', 'icon': Icons.directions_car_rounded},
      {'value': 'Housing', 'label': 'Housing', 'icon': Icons.home_rounded},
      {'value': 'Education', 'label': 'Education', 'icon': Icons.school_rounded},
      {'value': 'Personal/BNPL', 'label': 'Personal/BNPL', 'icon': Icons.credit_card_rounded},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.surfaceBorder),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.expenseCoral, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Add Liability",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorWhere != null && errorWhy != null) ...[
                      BluppFieldError(where: errorWhere!, why: errorWhy!),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      "Category",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    BluppBoxedSegment<String>(
                      selectedValue: loanType,
                      options: typeOptions,
                      onChanged: (val) => setDialogState(() => loanType = val),
                      activeColor: AppTheme.expenseCoral,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Loan / Debt Name",
                        hintText: "e.g. Car Loan, Shopee PayLater, PTPTN",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: providerController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Provider / Bank",
                        hintText: "e.g. Maybank, CIMB, Shopee, PTPTN",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: totalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Total Remaining Balance (RM)",
                        hintText: "e.g. 15,000.00",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: monthlyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Monthly Installment (RM)",
                        hintText: "e.g. 450.00",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expenseCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final provider = providerController.text.trim();
                    final total = double.tryParse(totalController.text.trim()) ?? 0.0;
                    final monthly = double.tryParse(monthlyController.text.trim()) ?? 0.0;

                    if (name.isEmpty) {
                      setDialogState(() {
                        errorWhere = "Loan / Debt Name";
                        errorWhy = "Please enter what this debt or commitment is for.";
                      });
                      return;
                    }
                    if (total <= 0) {
                      setDialogState(() {
                        errorWhere = "Remaining Balance";
                        errorWhy = "Please enter a valid balance amount greater than RM 0.00.";
                      });
                      return;
                    }
                    if (monthly <= 0) {
                      setDialogState(() {
                        errorWhere = "Monthly Installment";
                        errorWhy = "Please enter the required monthly payment amount.";
                      });
                      return;
                    }

                    IconData iconForType(String type) {
                      switch (type) {
                        case 'Vehicle':
                          return Icons.directions_car_rounded;
                        case 'Housing':
                          return Icons.home_rounded;
                        case 'Education':
                          return Icons.school_rounded;
                        case 'Personal/BNPL':
                        default:
                          return Icons.credit_card_rounded;
                      }
                    }

                    state.addLoan(
                      name,
                      provider.isEmpty ? 'Credit Provider' : provider,
                      total,
                      monthly,
                      15,
                      icon: iconForType(loanType),
                      color: AppTheme.expenseCoral,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save Liability", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // INVESTMENTS & SAVINGS MANAGEMENT (MINUS, ADD, DELETE, SHEET)
  // ===========================================================================

  // Bottom Sheet: Manage Investment Details & Actions
  void _showManageInvestmentSheet(BuildContext context, InvestmentItem inv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: inv.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(inv.icon, color: inv.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.name,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Text(
                              inv.institution,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "+${inv.returnRateAnnual}% p.a.",
                                style: TextStyle(color: AppTheme.primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppTheme.formatCurrency(inv.balance),
                    style: TextStyle(color: inv.color, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: AppTheme.surfaceBorder, height: 1),
              const SizedBox(height: 18),

              // Action 1: Minus / Withdraw Amount
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showMinusInvestmentDialog(context, inv);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle_outline_rounded, color: Colors.orangeAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minus / Withdraw Amount",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Withdraw funds, optionally transfer to a bank account",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orangeAccent, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Add Money / Deposit
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddInvestmentMoneyDialog(context, inv);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryTeal, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add Money to Balance",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Top up or deposit funds into this investment",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryTeal, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 3: Delete Investment
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteInvestment(context, inv);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseCoral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delete Investment / Savings",
                              style: TextStyle(color: AppTheme.expenseCoral, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Permanently remove from portfolio and sync with Supabase",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.expenseCoral, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Dialog: Minus / Withdraw from Investment
  void _showMinusInvestmentDialog(BuildContext context, InvestmentItem inv) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: "Withdrawal from ${inv.name}");
    String? selectedBankId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingBalance = (inv.balance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Withdraw",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          inv.name,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Balance", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(inv.balance), style: TextStyle(color: inv.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Minus", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(remainingBalance), style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          {"label": "+RM 500", "amt": 500.0},
                          {"label": "All", "amt": inv.balance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Withdraw (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.money_off_rounded, color: Colors.orangeAccent),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Transfer to Bank Dropdown
                    Text("Deposit Withdrawn Funds Into:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("None / Cash Withdrawal"),
                            ),
                            ...state.bankAccounts.map((bank) {
                              return DropdownMenuItem<String?>(
                                value: bank.id,
                                child: Text("${bank.name} (${AppTheme.formatCurrency(bank.balance)})"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedBankId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Note input
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusInvestmentBalance(
                        inv.id,
                        amount,
                        toBankId: selectedBankId,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Withdrew ${AppTheme.formatCurrency(amount)} from ${inv.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Minus", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Add Money / Deposit to Investment
  void _showAddInvestmentMoneyDialog(BuildContext context, InvestmentItem inv) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: "Deposit to ${inv.name}");
    String? selectedBankId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double newBalance = inv.balance + currentAmount;

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add_circle_outline, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Money / Deposit",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          inv.name,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Balance", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(inv.balance), style: TextStyle(color: inv.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Deposit", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(newBalance), style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [50.0, 100.0, 500.0, 1000.0].map((amt) {
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              amountController.text = amt.toStringAsFixed(0);
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              "+RM ${amt.toInt()}",
                              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Add (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payments_outlined, color: AppTheme.primaryTeal),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Deduct from Bank Dropdown
                    Text("Deduct Funds From (Optional):", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("None / External Funds"),
                            ),
                            ...state.bankAccounts.map((bank) {
                              return DropdownMenuItem<String?>(
                                value: bank.id,
                                child: Text("${bank.name} (${AppTheme.formatCurrency(bank.balance)})"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedBankId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Note input
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.addMoneyToInvestment(
                        inv.id,
                        amount,
                        fromBankId: selectedBankId,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Added ${AppTheme.formatCurrency(amount)} to ${inv.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Deposit", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Confirm Delete Investment
  void _confirmDeleteInvestment(BuildContext context, InvestmentItem inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Investment", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${inv.name} (${inv.institution})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Balance: ${AppTheme.formatCurrency(inv.balance)}\nThis will permanently remove this asset from your portfolio and synchronize with Supabase.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteInvestment(inv.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${inv.name} from investments",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Investment", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // Dialog: Add Investment or Savings
  void _showAddInvestmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final institutionController = TextEditingController();
    final balanceController = TextEditingController();
    final returnController = TextEditingController(text: "5.0");
    String assetType = 'Fixed/ASNB';
    String? errorWhere;
    String? errorWhy;

    final typeOptions = [
      {'value': 'Fixed/ASNB', 'label': 'Fixed/ASNB', 'icon': Icons.account_balance_rounded},
      {'value': 'Stocks/ETF', 'label': 'Stocks/ETF', 'icon': Icons.trending_up_rounded},
      {'value': 'Crypto', 'label': 'Crypto', 'icon': Icons.currency_bitcoin_rounded},
      {'value': 'High Yield', 'label': 'High Yield', 'icon': Icons.savings_rounded},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.surfaceBorder),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.savings_outlined, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Add Investment",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorWhere != null && errorWhy != null) ...[
                      BluppFieldError(where: errorWhere!, why: errorWhy!),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      "Asset Category",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    BluppBoxedSegment<String>(
                      selectedValue: assetType,
                      options: typeOptions,
                      onChanged: (val) => setDialogState(() => assetType = val),
                      activeColor: AppTheme.primaryTeal,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Investment / Asset Name",
                        hintText: "e.g. ASNB Amanah Saham, Tabung Haji, Versa",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: institutionController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Institution / Provider",
                        hintText: "e.g. Permodalan Nasional Berhad, Versa Asia",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Initial Balance (RM)",
                        hintText: "e.g. 5,000.00",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: returnController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Estimated Annual Return (% p.a.)",
                        hintText: "e.g. 5.25",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final institution = institutionController.text.trim();
                    final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
                    final returnRate = double.tryParse(returnController.text.trim()) ?? 5.0;

                    if (name.isEmpty) {
                      setDialogState(() {
                        errorWhere = "Investment Name";
                        errorWhy = "Please enter what this asset or portfolio is called.";
                      });
                      return;
                    }
                    if (balance <= 0) {
                      setDialogState(() {
                        errorWhere = "Initial Balance";
                        errorWhy = "Please enter a valid starting balance greater than RM 0.00.";
                      });
                      return;
                    }

                    IconData assetIcon = Icons.savings_outlined;
                    if (assetType == 'Stocks/ETF') assetIcon = Icons.trending_up_rounded;
                    if (assetType == 'Crypto') assetIcon = Icons.currency_bitcoin_rounded;
                    if (assetType == 'Fixed/ASNB') assetIcon = Icons.account_balance_rounded;

                    state.addInvestment(InvestmentItem(
                      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      institution: institution.isEmpty ? 'Financial Institution' : institution,
                      balance: balance,
                      returnRateAnnual: returnRate,
                      notes: 'Added to portfolio',
                      icon: assetIcon,
                      color: AppTheme.primaryTeal,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save Investment", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // LOANS & LIABILITIES MANAGEMENT (MINUS, DELETE, SHEET)
  // ===========================================================================

  // Bottom Sheet: Manage Loan Details & Actions
  void _showManageLoanSheet(BuildContext context, LoanItem loan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: loan.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(loan.icon, color: loan.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.name,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Text(
                              loan.provider,
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: loan.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Due ${loan.dueDayOfMonth}th • ${AppTheme.formatCurrency(loan.monthlyInstallment)}/mo",
                                style: TextStyle(
                                  color: loan.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppTheme.formatCurrency(loan.remainingBalance),
                        style: TextStyle(color: loan.color, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text("Remaining Debt", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: AppTheme.surfaceBorder, height: 1),
              const SizedBox(height: 18),

              // Action 1: Minus / Pay Down Loan
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showMinusLoanDialog(context, loan);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline_rounded, color: AppTheme.primaryTeal, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minus / Pay Down Loan",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Pay off principal or monthly installment, boosts your Net Worth",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryTeal, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Delete Loan
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteLoan(context, loan);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseCoral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.expenseCoral.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppTheme.expenseCoral, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delete Loan / Liability",
                              style: TextStyle(color: AppTheme.expenseCoral, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Permanently remove this commitment and eliminate debt from Net Worth",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.expenseCoral, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Dialog: Minus / Pay Down Loan
  void _showMinusLoanDialog(BuildContext context, LoanItem loan) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: "Repayment for ${loan.name}");
    String? selectedBankId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double currentAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double remainingDebt = (loan.remainingBalance - currentAmount).clamp(0.0, double.infinity);

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.remove_circle_outline, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minus / Pay Down Loan",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          loan.name,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner explaining Net Worth boost
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up_rounded, color: AppTheme.primaryTeal, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Paying down liabilities directly increases your Total Net Worth!",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Debt status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Debt", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(AppTheme.formatCurrency(loan.remainingBalance), style: TextStyle(color: loan.color, fontWeight: FontWeight.w500, fontSize: 14)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("After Repayment", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(
                                remainingDebt == 0 ? "FULLY PAID!" : AppTheme.formatCurrency(remainingDebt),
                                style: TextStyle(
                                  color: remainingDebt == 0 ? AppTheme.primaryTeal : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in [
                          {"label": "+RM 50", "amt": 50.0},
                          {"label": "+RM 100", "amt": 100.0},
                          if (loan.monthlyInstallment > 0)
                            {"label": "Monthly (${loan.monthlyInstallment.toInt()})", "amt": loan.monthlyInstallment},
                          {"label": "Full Payoff", "amt": loan.remainingBalance},
                        ])
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amountController.text = (chip["amt"] as double).toStringAsFixed(0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                chip["label"] as String,
                                style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: "Amount to Minus / Pay Down (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payment_rounded, color: AppTheme.primaryTeal),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Deduct from Bank Dropdown
                    Text("Deduct Repayment From (Optional):", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedBankId,
                          isExpanded: true,
                          dropdownColor: AppTheme.surface,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("None / Paid Outside Blupp"),
                            ),
                            ...state.bankAccounts.map((bank) {
                              return DropdownMenuItem<String?>(
                                value: bank.id,
                                child: Text("${bank.name} (${AppTheme.formatCurrency(bank.balance)})"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedBankId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Note input
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Note / Description",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0) {
                      state.minusLoanBalance(
                        loan.id,
                        amount,
                        fromBankId: selectedBankId,
                        note: noteController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Paid down ${AppTheme.formatCurrency(amount)} from ${loan.name}",
                                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Confirm Repayment", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Confirm Delete Loan
  void _confirmDeleteLoan(BuildContext context, LoanItem loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.expenseCoral.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseCoral, size: 22),
            ),
            const SizedBox(width: 12),
            Text("Delete Loan / Liability", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${loan.name} (${loan.provider})?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Remaining Debt: ${AppTheme.formatCurrency(loan.remainingBalance)}\nThis will permanently remove this commitment from your records and eliminate this liability from your Net Worth.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              state.deleteLoan(loan.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surfaceLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    "Deleted ${loan.name} from loans and liabilities",
                    style: TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
            child: const Text("Delete Loan", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
