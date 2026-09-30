import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

class TrackingScreen extends StatefulWidget {
  final FinanceState state;

  const TrackingScreen({super.key, required this.state});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategoryFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Expenses",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
            tooltip: "Budget Settings",
            onPressed: () => _showBudgetSettingsDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.surfaceLight,
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
                ),
                dividerColor: Colors.transparent,
                labelColor: AppTheme.textPrimary,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 16, color: AppTheme.expenseCoral),
                        SizedBox(width: 6),
                        Text("Expenses"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward_rounded, size: 16, color: AppTheme.incomeMint),
                        SizedBox(width: 6),
                        Text("Income"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesTab(context),
          _buildIncomeTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Add Entry",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        onPressed: () => _showAddTransactionModal(context),
      ),
    );
  }

  // --- EXPENSES TAB ---
  Widget _buildExpensesTab(BuildContext context) {
    final totalSpent = widget.state.totalExpensesThisMonth;
    final budget = widget.state.monthlySpendingBudget;
    final progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
    final spendingBalance = widget.state.spendingBalanceLeft;

    final expenses = widget.state.transactions.where((t) {
      if (t.type != TransactionType.expense) return false;
      if (_selectedCategoryFilter != 'all' && t.categoryId != _selectedCategoryFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchNote = (t.note ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchNote) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      children: [
        // Search Bar with Realistic Hints
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: "Search expenses (e.g. Starbucks, Groceries, Grab, Netflix)...",
            hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.6), fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.primaryTeal),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Budget & Spend Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOTAL EXPENSE THIS MONTH",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${(progress * 100).toStringAsFixed(0)}% Budget Used",
                      style: TextStyle(color: AppTheme.expenseCoral,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppTheme.formatCurrency(totalSpent),
                style: TextStyle(color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.85 ? AppTheme.expenseCoral : AppTheme.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Spending Balance Left: ${AppTheme.formatCurrency(spendingBalance)}",
                    style: TextStyle(color: AppTheme.primaryTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Budget: ${AppTheme.formatCurrency(budget)}",
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
        const SizedBox(height: 20),

        // Category Filter Chips
        _buildCategoryFilterRow(TransactionType.expense),
        const SizedBox(height: 16),

        // Expense List Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transactions (${expenses.length})",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (expenses.isEmpty)
          _buildEmptyState("No expenses logged for this filter yet.")
        else
          ...expenses.asMap().entries.map((e) => _buildTransactionCard(e.value, e.key)),
      ],
    );
  }

  // --- INCOME TAB ---
  Widget _buildIncomeTab(BuildContext context) {
    final totalIncome = widget.state.totalIncomeThisMonth;
    final incomes = widget.state.transactions.where((t) {
      if (t.type != TransactionType.income) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchNote = (t.note ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchNote) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      children: [
        // Search Bar with Realistic Hints
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: "Search income entries (e.g. Salary, Client Payout, Bonus)...",
            hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.6), fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.incomeMint),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL INCOME THIS MONTH",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppTheme.formatCurrency(totalIncome),
                style: TextStyle(color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded, size: 14, color: AppTheme.incomeMint),
                  const SizedBox(width: 4),
                  Text(
                    "Directly boosts your Net Worth & Bank Balance",
                    style: TextStyle(
                      color: AppTheme.incomeMint.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Income Entries (${incomes.length})",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (incomes.isEmpty)
          _buildEmptyState("No income transactions recorded yet.")
        else
          ...incomes.asMap().entries.map((e) => _buildTransactionCard(e.value, e.key)),
      ],
    );
  }

  // Category filter scrollable row
  Widget _buildCategoryFilterRow(TransactionType type) {
    final categories = widget.state.categories.where((c) => c.type == type).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip("all", "All", Icons.apps_rounded, const Color(0xFF64748B)),
          ...categories.map((cat) {
            return _buildFilterChip(cat.id, cat.name, cat.icon, cat.color);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label, IconData icon, Color color) {
    final isSelected = _selectedCategoryFilter == id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.black : color,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w600,
        ),
        backgroundColor: AppTheme.surface,
        selectedColor: AppTheme.primaryTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceBorder,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategoryFilter = id;
          });
        },
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, TransactionItem tx) {
    final isExpense = tx.type == TransactionType.expense;
    final bank = widget.state.getBankById(tx.bankAccountId);
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
              widget.state.deleteTransaction(tx.id);
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

  Widget _buildTransactionCard(TransactionItem tx, [int index = 0]) {
    final category = widget.state.getCategoryById(tx.categoryId);
    final bank = widget.state.getBankById(tx.bankAccountId);
    final isExpense = tx.type == TransactionType.expense;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.expenseCoral,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        widget.state.deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted '${tx.title}'"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: InteractiveCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
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
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (bank != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bank.name,
                          style: TextStyle(
                            color: bank.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tx.note!,
                      style: TextStyle(
                        color: AppTheme.secondaryCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isExpense ? '-' : '+'}${AppTheme.formatCurrency(tx.amount)}",
                  style: TextStyle(
                    color: isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx.date),
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Visible Delete Button
            InkWell(
              onTap: () => _confirmDeleteTransaction(context, tx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.expenseCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.expenseCoral.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.expenseCoral,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 250.ms, delay: Duration(milliseconds: (30 * index).clamp(0, 300))).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildEmptyState(String message) {
    return BluppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: "No transactions",
      description: message,
      actionLabel: "Add Transaction",
      onAction: () => _showAddTransactionModal(context),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return "Today";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
      return "Yesterday";
    }
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${d.day} ${months[d.month - 1]}";
  }

  void _showAddTransactionModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType activeType = _tabController.index == 0 ? TransactionType.expense : TransactionType.income;
    String selectedCatId = activeType == TransactionType.expense ? 'food' : 'salary';
    String selectedBankId = widget.state.bankAccounts.isNotEmpty ? widget.state.bankAccounts.first.id : '';
    String selectedCurrency = widget.state.baseCurrency;
    String? errorWhere;
    String? errorWhy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final availableCategories = widget.state.categories
                .where((c) => c.type == activeType)
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "New Transaction",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.textMuted),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (errorWhere != null && errorWhy != null) ...[
                      BluppFieldError(where: errorWhere!, why: errorWhy!),
                      const SizedBox(height: 12),
                    ],

                    // Boxed Segmented Type Selector
                    BluppBoxedSegment<TransactionType>(
                      selectedValue: activeType,
                      options: const [
                        {'label': 'Expense (-)', 'value': TransactionType.expense, 'icon': Icons.arrow_downward_rounded},
                        {'label': 'Income (+)', 'value': TransactionType.income, 'icon': Icons.arrow_upward_rounded},
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          activeType = val;
                          selectedCatId = activeType == TransactionType.expense ? 'food' : 'salary';
                        });
                      },
                      activeColor: activeType == TransactionType.expense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Description / Title",
                        hintText: activeType == TransactionType.expense
                            ? "e.g. Dinner with team, Fuel, Grocery run"
                            : "e.g. Client Payment, Monthly Salary, Bonus",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Currency Selector Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.travel_explore_rounded, color: AppTheme.secondaryCyan, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "Currency",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: selectedCurrency != widget.state.baseCurrency
                                ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedCurrency != widget.state.baseCurrency
                                  ? AppTheme.primaryTeal
                                  : AppTheme.surfaceBorder,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCurrency,
                              dropdownColor: AppTheme.surface,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal),
                              style: TextStyle(
                                color: selectedCurrency != widget.state.baseCurrency
                                    ? AppTheme.primaryTeal
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              items: CurrencyManager.supportedCurrencies.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.code,
                                  child: Text("${c.flag} ${c.code} (${c.symbol})"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedCurrency = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: "${CurrencyManager.getCurrency(selectedCurrency).symbol} ",
                        prefixStyle: TextStyle(color: AppTheme.primaryTeal, fontSize: 16, fontWeight: FontWeight.bold),
                        labelText: selectedCurrency != widget.state.baseCurrency
                            ? "Amount in $selectedCurrency (Travel Currency)"
                            : "Amount (${widget.state.baseCurrency})",
                        hintText: "e.g. 45.00",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 14),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (selectedCurrency != widget.state.baseCurrency &&
                        (double.tryParse(amountController.text.trim()) ?? 0.0) > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange_rounded, color: AppTheme.primaryTeal, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Auto-Converted to Base (${widget.state.baseCurrency}):",
                                    style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${CurrencyManager.format(double.tryParse(amountController.text.trim()) ?? 0.0, selectedCurrency)} ≈ ${AppTheme.formatCurrency(CurrencyManager.convert(amount: double.tryParse(amountController.text.trim()) ?? 0.0, fromCode: selectedCurrency, toCode: widget.state.baseCurrency))}",
                                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Rate: 1 ${widget.state.baseCurrency} = ${(CurrencyManager.getCurrency(selectedCurrency).rateToMYR / CurrencyManager.getCurrency(widget.state.baseCurrency).rateToMYR).toStringAsFixed(2)} $selectedCurrency",
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Category Picker Grid
                    Text(
                      "Select Category",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableCategories.map((cat) {
                        final isSelected = selectedCatId == cat.id;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedCatId = cat.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? cat.color.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? cat.color : AppTheme.surfaceBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 14, color: cat.color),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Horizontal Bank Account Box Picker
                    Text(
                      "Source Account / Bank",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.state.bankAccounts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          "No bank accounts found. Please add a bank account first.",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      )
                    else
                      BluppHorizontalBoxPicker<String>(
                        selectedValue: selectedBankId,
                        options: widget.state.bankAccounts.map((b) => {
                          'label': "${b.name} (${AppTheme.formatCurrency(b.balance)})",
                          'value': b.id,
                          'icon': b.icon,
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedBankId = val;
                          });
                        },
                        activeColor: AppTheme.primaryTeal,
                      ),
                    const SizedBox(height: 22),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeType == TransactionType.expense
                              ? AppTheme.expenseCoral
                              : AppTheme.incomeMint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;

                          if (title.isEmpty) {
                            setModalState(() {
                              errorWhere = "Description / Title";
                              errorWhy = "Please describe what this transaction was for.";
                            });
                            return;
                          }
                          if (enteredAmount <= 0) {
                            setModalState(() {
                              errorWhere = "Amount";
                              errorWhy = "Transaction amount must be greater than 0.00.";
                            });
                            return;
                          }
                          if (selectedBankId.isEmpty && widget.state.bankAccounts.isNotEmpty) {
                            setModalState(() {
                              errorWhere = "Source Account / Bank";
                              errorWhy = "Please select which bank or wallet was used.";
                            });
                            return;
                          }

                          final baseAmount = CurrencyManager.convert(
                            amount: enteredAmount,
                            fromCode: selectedCurrency,
                            toCode: widget.state.baseCurrency,
                          );
                          final isForeign = selectedCurrency != widget.state.baseCurrency;
                          final travelNote = isForeign
                              ? "Paid ${CurrencyManager.format(enteredAmount, selectedCurrency)}"
                              : null;

                          widget.state.addTransaction(TransactionItem(
                            id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            amount: baseAmount,
                            type: activeType,
                            categoryId: selectedCatId,
                            date: DateTime.now(),
                            bankAccountId: selectedBankId,
                            note: travelNote,
                          ));
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.surfaceLight,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: Text(
                                isForeign
                                    ? "Added ${activeType == TransactionType.expense ? 'Expense' : 'Income'}: $title (${CurrencyManager.format(enteredAmount, selectedCurrency)} ≈ ${AppTheme.formatCurrency(baseAmount)})"
                                    : "Added ${activeType == TransactionType.expense ? 'Expense' : 'Income'}: $title (${AppTheme.formatCurrency(baseAmount)})",
                                style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          activeType == TransactionType.expense
                              ? "Record Expense & Update Net Worth"
                              : "Record Income & Update Net Worth",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBudgetSettingsDialog(BuildContext context) {
    final controller = TextEditingController(
      text: widget.state.monthlySpendingBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            "Monthly Spending Budget",
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Set your overall target spending limit for this month:",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: "RM ",
                  prefixStyle: TextStyle(color: AppTheme.primaryTeal),
                  labelText: "Budget Amount",
                  labelStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                final val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  widget.state.setMonthlyBudget(val);
                }
                Navigator.pop(ctx);
              },
              child: const Text("Update Budget", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
