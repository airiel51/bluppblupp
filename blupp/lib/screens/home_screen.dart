import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

class HomeScreen extends StatelessWidget {
  final FinanceState state;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

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
                // Top App Bar / Greeting
                _buildHeader(context),
                const SizedBox(height: 20),

                // 1. Total Net Worth Hero Card
                _buildNetWorthHeroCard(context)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),

                // Quick Action Bar
                _buildQuickActions(context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 60.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),

                // 2. All Banks Section
                _buildBankAccountsSection(context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 120.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),

                // 3. Investments & Savings Section
                _buildInvestmentsSection(context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 180.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),

                // 4. Loans & Liabilities Section
                _buildLoansSection(context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 240.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),

                // Recent Activity Teaser
                _buildRecentTransactionsSection(context)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_getGreeting()} 👋",
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              state.userName.isNotEmpty ? state.userName : "Airiel",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () => onNavigateTab(3),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => onNavigateTab(5),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: state.hasCustomProfileImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.memory(
                          base64Decode(state.profileImageBase64!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 1. TOTAL NET WORTH HERO CARD
  Widget _buildNetWorthHeroCard(BuildContext context) {
    if (state.isRefreshing) {
      return BluppSkeleton.netWorthHero();
    }

    final netWorth = state.totalNetWorth;
    final totalBanks = state.totalBankBalance;
    final spendingBalance = state.spendingBalanceLeft;
    final investments = state.totalInvestmentsAndSavings;
    final totalLoans = state.totalLoans;

    return InteractiveCard(
      onTap: state.toggleNetWorthVisibility,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "TOTAL NET WORTH",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isNetWorthHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 11,
                          color: state.isNetWorthHidden ? AppTheme.textMuted : AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.isNetWorthHidden ? "Hidden" : "Visible",
                          style: TextStyle(
                            color: state.isNetWorthHidden ? AppTheme.textMuted : AppTheme.primaryTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showNetWorthFormulaSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        "Formula",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bold Highlight Amount (Hidden by default, prominent when revealed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  state.isNetWorthHidden ? "••••••••••" : AppTheme.formatCurrency(netWorth),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: state.isNetWorthHidden ? 3.0 : -1.0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  state.isNetWorthHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: state.toggleNetWorthVisibility,
                tooltip: state.isNetWorthHidden ? "Show Net Worth" : "Hide Net Worth",
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Asset vs Liability breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAssetStat(
                  "Banks",
                  state.isNetWorthHidden ? "••••" : AppTheme.formatCurrency(totalBanks),
                  AppTheme.textPrimary,
                ),
                Container(height: 20, width: 1, color: AppTheme.surfaceBorder),
                _buildAssetStat(
                  "Spending",
                  state.isNetWorthHidden ? "••••" : AppTheme.formatCurrency(spendingBalance),
                  AppTheme.textPrimary,
                ),
                Container(height: 20, width: 1, color: AppTheme.surfaceBorder),
                _buildAssetStat(
                  "Investments",
                  state.isNetWorthHidden ? "••••" : AppTheme.formatCurrency(investments),
                  AppTheme.textPrimary,
                ),
                Container(height: 20, width: 1, color: AppTheme.surfaceBorder),
                _buildAssetStat(
                  "Loans",
                  state.isNetWorthHidden ? "••••" : "-${AppTheme.formatCurrency(totalLoans)}",
                  AppTheme.expenseCoral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetStat(String title, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Quick Action Buttons
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionBtn(
            icon: Icons.add_circle_outline_rounded,
            label: "Track Expense",
            color: AppTheme.expenseCoral,
            onTap: () => onNavigateTab(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionBtn(
            icon: Icons.psychology_rounded,
            label: "FOMO AI",
            color: AppTheme.fomoPurple,
            onTap: () => onNavigateTab(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionBtn(
            icon: Icons.calendar_month_rounded,
            label: "Plan Expenses",
            color: AppTheme.warningAmber,
            onTap: () => onNavigateTab(4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
      child: SizedBox(
        width: 192,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(bank.icon, color: AppTheme.textSecondary, size: 15),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTheme.formatCurrency(bank.balance),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => _showAddMoneyDialog(context, bank),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
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
            children: state.investments.asMap().entries.map((entry) {
              final index = entry.key;
              final inv = entry.value;
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                inv.institution,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "+${inv.returnRateAnnual}% p.a.",
                                  style: TextStyle(
                                    color: AppTheme.primaryTeal,
                                    fontSize: 9,
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
              ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 60 * index)).slideY(begin: 0.08, end: 0);
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                "Due on ${loan.dueDayOfMonth}th",
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
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

  // Recent transactions preview
  Widget _buildRecentTransactionsSection(BuildContext context) {
    final recent = state.transactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activity",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => onNavigateTab(1),
              child: const Text(
                "View All",
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recent.map((tx) {
            final category = state.getCategoryById(tx.categoryId);
            final isExpense = tx.type == TransactionType.expense;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: AppTheme.cardDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${isExpense ? '-' : '+'}${AppTheme.formatCurrency(tx.amount)}",
                    style: TextStyle(
                      color: isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _confirmDeleteTransaction(context, tx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.expenseCoral.withValues(alpha: 0.3),
                          width: 1,
                        ),
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
            );
          }).toList(),
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
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: AppTheme.primaryTeal, size: 18),
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
                      onSelected: (val) => setDialogState(() => accountType = val),
                    ),
                    const SizedBox(height: 14),

                    // Bank Name Field with Hint
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Bank / Institution Name",
                        hintText: "e.g. Maybank, CIMB, Hong Leong",
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (_) {
                        if (nameError != null) setDialogState(() => nameError = null);
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
                    backgroundColor: AppTheme.textPrimary,
                    foregroundColor: AppTheme.background,
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
                        accountType == 'Wallet' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
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

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_card_rounded, color: AppTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Money",
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        Text(
                          bank.name,
                          style: TextStyle(color: AppTheme.primaryTeal, fontSize: 13, fontWeight: FontWeight.w600),
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
                      "Current Balance: ${AppTheme.formatCurrency(bank.balance)}",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),

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
                              style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Amount to Add (RM)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.payments_outlined, color: AppTheme.primaryTeal),
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
                      color: bank.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(bank.icon, color: bank.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.name,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          bank.accountNumber,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppTheme.formatCurrency(bank.balance),
                    style: TextStyle(color: bank.color, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: AppTheme.surfaceBorder, height: 1),
              const SizedBox(height: 18),

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
      {'label': 'Vehicle', 'icon': Icons.directions_car_rounded},
      {'label': 'Housing', 'icon': Icons.home_rounded},
      {'label': 'Education', 'icon': Icons.school_rounded},
      {'label': 'Personal/BNPL', 'icon': Icons.credit_card_rounded},
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

                    state.addLoan(name, provider.isEmpty ? 'Credit Provider' : provider, total, monthly, 15);
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
      {'label': 'Fixed/ASNB', 'icon': Icons.account_balance_rounded},
      {'label': 'Stocks/ETF', 'icon': Icons.trending_up_rounded},
      {'label': 'Crypto', 'icon': Icons.currency_bitcoin_rounded},
      {'label': 'High Yield', 'icon': Icons.savings_rounded},
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
