import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class BluppSearchDialog extends StatefulWidget {
  final FinanceState state;
  final Function(int)? onNavigateTab;

  const BluppSearchDialog({
    super.key,
    required this.state,
    this.onNavigateTab,
  });

  static Future<void> show(
    BuildContext context, {
    required FinanceState state,
    Function(int)? onNavigateTab,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => BluppSearchDialog(
        state: state,
        onNavigateTab: onNavigateTab,
      ),
    );
  }

  @override
  State<BluppSearchDialog> createState() => _BluppSearchDialogState();
}

class _BluppSearchDialogState extends State<BluppSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = widget.state.transactions;
    final accounts = widget.state.bankAccounts;
    final budgets = widget.state.categoryBudgets;

    final q = _query.toLowerCase();

    // 1. Matched transactions
    final matchedTransactions = _query.isEmpty
        ? <TransactionItem>[]
        : transactions.where((t) {
            final catName = widget.state.getCategoryById(t.categoryId).name.toLowerCase();
            return t.title.toLowerCase().contains(q) ||
                catName.contains(q) ||
                (t.note?.toLowerCase().contains(q) ?? false) ||
                t.amount.toString().contains(q);
          }).take(6).toList();

    // 2. Matched accounts
    final matchedAccounts = _query.isEmpty
        ? <BankAccount>[]
        : accounts.where((a) {
            return a.name.toLowerCase().contains(q) ||
                a.accountNumber.toLowerCase().contains(q);
          }).toList();

    // 3. Matched categories / budgets
    final matchedBudgets = _query.isEmpty
        ? <MapEntry<String, double>>[]
        : budgets.entries.where((b) {
            final catName = widget.state.getCategoryById(b.key).name.toLowerCase();
            return catName.contains(q) || b.key.toLowerCase().contains(q);
          }).toList();

    // 4. Quick navigation matches
    final navItems = [
      {'title': 'Home Overview', 'tab': 0, 'icon': Icons.home_rounded, 'desc': 'Net worth, cards & accounts'},
      {'title': 'Expenses & Transactions', 'tab': 1, 'icon': Icons.receipt_long_rounded, 'desc': 'Expense logs & filters'},
      {'title': 'Analytics & Cash Flow', 'tab': 2, 'icon': Icons.insights_rounded, 'desc': 'Spending trends & charts'},
      {'title': 'FOMO AI Advisor', 'tab': 3, 'icon': Icons.auto_awesome_rounded, 'desc': 'AI safe-to-spend analysis'},
      {'title': 'Financial Calendar', 'tab': 4, 'icon': Icons.calendar_month_rounded, 'desc': 'Scheduled bills & payments'},
      {'title': 'Profile & Preferences', 'tab': 5, 'icon': Icons.person_rounded, 'desc': 'Dark mode, currency, security'},
    ];

    final matchedNav = navItems.where((n) {
      if (_query.isEmpty) return true;
      return (n['title'] as String).toLowerCase().contains(q) ||
          (n['desc'] as String).toLowerCase().contains(q);
    }).take(_query.isEmpty ? 4 : 6).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: AppTheme.isDark ? 0.6 : 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Search Input Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppTheme.primaryTeal,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transactions, accounts, budgets, or navigation...',
                            hintStyle: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                          onPressed: () => _searchController.clear(),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          'ESC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),

                // Results list
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    children: [
                      // Quick App Navigation Section
                      if (matchedNav.isNotEmpty) ...[
                        _buildSectionHeader('Navigation & Features'),
                        ...matchedNav.map((n) {
                          return _buildListTile(
                            icon: n['icon'] as IconData,
                            iconColor: AppTheme.primaryTeal,
                            title: n['title'] as String,
                            subtitle: n['desc'] as String,
                            onTap: () {
                              Navigator.pop(context);
                              widget.onNavigateTab?.call(n['tab'] as int);
                            },
                          );
                        }),
                      ],

                      // Transactions Section
                      if (matchedTransactions.isNotEmpty) ...[
                        _buildSectionHeader('Transactions (${matchedTransactions.length})'),
                        ...matchedTransactions.map((t) {
                          final isExpense = t.type == TransactionType.expense;
                          final catName = widget.state.getCategoryById(t.categoryId).name;
                          return _buildListTile(
                            icon: isExpense ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                            iconColor: isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                            title: t.title,
                            subtitle: '$catName • ${t.date.day}/${t.date.month}/${t.date.year}',
                            trailing: Text(
                              '${isExpense ? "-" : "+"}${AppTheme.formatCurrency(t.amount)}',
                              style: TextStyle(
                                color: isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onNavigateTab?.call(1);
                            },
                          );
                        }),
                      ],

                      // Accounts Section
                      if (matchedAccounts.isNotEmpty) ...[
                        _buildSectionHeader('Bank Accounts (${matchedAccounts.length})'),
                        ...matchedAccounts.map((a) {
                          return _buildListTile(
                            icon: a.icon,
                            iconColor: a.color,
                            title: a.name,
                            subtitle: 'Acct •••• ${a.accountNumber}',
                            trailing: Text(
                              AppTheme.formatCurrency(a.balance),
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onNavigateTab?.call(0);
                            },
                          );
                        }),
                      ],

                      // Budgets Section
                      if (matchedBudgets.isNotEmpty) ...[
                        _buildSectionHeader('Envelopes & Budgets (${matchedBudgets.length})'),
                        ...matchedBudgets.map((b) {
                          final catName = widget.state.getCategoryById(b.key).name;
                          final limit = b.value;
                          final spent = widget.state.getCategorySpentThisMonth(b.key);
                          final percent = limit > 0 ? ((spent / limit) * 100).clamp(0, 999) : 0;
                          final isOver = spent > limit;

                          return _buildListTile(
                            icon: Icons.pie_chart_outline_rounded,
                            iconColor: AppTheme.warningAmber,
                            title: '$catName Budget',
                            subtitle: 'Limit: ${AppTheme.formatCurrency(limit)}',
                            trailing: Text(
                              '${percent.toStringAsFixed(0)}% used',
                              style: TextStyle(
                                color: isOver ? AppTheme.expenseCoral : AppTheme.incomeMint,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onNavigateTab?.call(2);
                            },
                          );
                        }),
                      ],

                      // Empty state when search yields zero results
                      if (_query.isNotEmpty &&
                          matchedTransactions.isEmpty &&
                          matchedAccounts.isEmpty &&
                          matchedBudgets.isEmpty &&
                          matchedNav.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'No matching results for "$_query"',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try searching for merchant names, amounts, categories, or "dark mode".',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Bottom shortcut hints
                Divider(height: 1, color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Search anything across Blupp OS',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const Text(
                        'Ctrl+K / ⌘K',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
