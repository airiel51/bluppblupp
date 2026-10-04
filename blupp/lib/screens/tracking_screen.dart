import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';
import '../widgets/ai_safe_to_spend_card.dart';
import '../widgets/ai_quick_log_sheet.dart';
import '../widgets/ai_receipt_scanner_sheet.dart';

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
  String _expenseTimeframe = 'daily'; // 'daily', 'weekly', 'monthly'

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
            icon: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981)),
            tooltip: "AI Quick-Log",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AiQuickLogSheet(state: widget.state),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded, color: Color(0xFF00E5FF)),
            tooltip: "Scan Receipt/QR",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AiReceiptScannerSheet(state: widget.state),
              );
            },
          ),
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

        // AI Safe-to-Spend Radar Card
        AiSafeToSpendCard(state: widget.state)
            .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.04, end: 0),
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

        // Timeframe Selector: Daily, Weekly, Monthly
        _buildTimeframeSelector(),
        const SizedBox(height: 14),

        // Category Filter Chips
        _buildCategoryFilterRow(TransactionType.expense),
        const SizedBox(height: 16),

        // Expense View based on Selected Timeframe
        if (_expenseTimeframe == 'daily')
          _buildDailyExpensesSection(expenses)
        else if (_expenseTimeframe == 'weekly')
          _buildWeeklyExpensesSection(expenses)
        else
          _buildMonthlyExpensesSection(expenses),
      ],
    );
  }

  // --- TIMEFRAME SELECTOR ---
  Widget _buildTimeframeSelector() {
    final options = [
      {'id': 'daily', 'label': 'Daily', 'icon': Icons.today_rounded},
      {'id': 'weekly', 'label': 'Weekly', 'icon': Icons.date_range_rounded},
      {'id': 'monthly', 'label': 'Monthly', 'icon': Icons.calendar_month_rounded},
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = _expenseTimeframe == opt['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expenseTimeframe = opt['id'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surfaceLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.6), width: 1)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 15,
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 1. DAILY EXPENSES SECTION ---
  Widget _buildDailyExpensesSection(List<TransactionItem> filteredExpenses) {
    final todaySpent = widget.state.todayExpenseTotal;
    final yesterdaySpent = widget.state.yesterdayExpenseTotal;

    // Group the filtered expenses by date
    final Map<String, List<TransactionItem>> grouped = {};
    for (final t in filteredExpenses) {
      final key = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily KPI Comparison Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.expenseCoral,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "TODAY'S SPENT",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(todaySpent),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "YESTERDAY",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(yesterdaySpent),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daily History (${filteredExpenses.length} entries)",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              "${sortedKeys.length} Days",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filteredExpenses.isEmpty)
          _buildEmptyState("No expenses recorded for this daily filter.")
        else
          ...sortedKeys.map((dateKey) {
            final items = grouped[dateKey]!;
            final firstDate = items.first.date;
            final dayTotal = items.fold<double>(0.0, (sum, t) => sum + t.amount);

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final dayDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
            final diff = today.difference(dayDate).inDays;

            String label;
            if (diff == 0) {
              label = "Today";
            } else if (diff == 1) {
              label = "Yesterday";
            } else {
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              label = "${weekdays[firstDate.weekday - 1]}, ${firstDate.day} ${months[firstDate.month - 1]}";
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Header Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder.withValues(alpha: 0.5))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                diff == 0 ? Icons.bolt_rounded : Icons.calendar_today_rounded,
                                size: 14,
                                color: diff == 0 ? AppTheme.primaryTeal : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  color: diff == 0 ? AppTheme.primaryTeal : AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "${items.length} ${items.length == 1 ? 'tx' : 'txs'}",
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppTheme.formatCurrency(dayTotal),
                            style: const TextStyle(
                              color: AppTheme.expenseCoral,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Items for this day
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: items.map((tx) => _buildTransactionCard(tx)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- 2. WEEKLY EXPENSES SECTION (with 7-Day Sparkline Bar Chart) ---
  Widget _buildWeeklyExpensesSection(List<TransactionItem> filteredExpenses) {
    final weeklyGroups = widget.state.weeklyExpenseHistory;
    final thisWeekSpent = widget.state.thisWeekExpenseTotal;
    final lastWeekSpent = widget.state.lastWeekExpenseTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly KPI Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "THIS WEEK",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(thisWeekSpent),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "LAST WEEK",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(lastWeekSpent),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Weekly Trends (${weeklyGroups.length} Weeks)",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              "Mon – Sun Breakdown",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (weeklyGroups.isEmpty)
          _buildEmptyState("No weekly expense records found.")
        else
          ...weeklyGroups.map((week) {
            // Find max day spend in this week for proportional bar heights
            final maxDaySpend = week.dailySpending.fold<double>(0.0, (max, v) => v > max ? v : max);
            final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

            // Match any filtered transactions in this week
            final weekItems = filteredExpenses.where((t) {
              return !t.date.isBefore(week.startDate) && !t.date.isAfter(week.endDate);
            }).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: week.weekIndex == 0
                      ? AppTheme.primaryTeal.withValues(alpha: 0.4)
                      : AppTheme.surfaceBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                week.label,
                                style: TextStyle(
                                  color: week.weekIndex == 0 ? AppTheme.primaryTeal : AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (week.weekIndex == 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "CURRENT",
                                    style: TextStyle(color: AppTheme.primaryTeal, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            week.dateRangeFormatted,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppTheme.formatCurrency(week.totalExpense),
                            style: const TextStyle(
                              color: AppTheme.expenseCoral,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "${week.items.length} ${week.items.length == 1 ? 'expense' : 'expenses'}",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7-Day Sparkline Bar Chart
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "7-DAY SPENDING INTENSITY",
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (i) {
                              final spent = week.dailySpending[i];
                              final ratio = maxDaySpend > 0 ? (spent / maxDaySpend).clamp(0.08, 1.0) : 0.08;
                              final hasSpent = spent > 0;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 38 * ratio,
                                            decoration: BoxDecoration(
                                              color: hasSpent
                                                  ? (spent == maxDaySpend && maxDaySpend > 0
                                                      ? AppTheme.expenseCoral
                                                      : AppTheme.primaryTeal.withValues(alpha: 0.8))
                                                  : AppTheme.surfaceBorder.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dayLabels[i],
                                        style: TextStyle(
                                          color: hasSpent ? AppTheme.textSecondary : AppTheme.textMuted,
                                          fontSize: 10,
                                          fontWeight: hasSpent ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Transactions list under this week
                  if (weekItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...weekItems.map((tx) => _buildTransactionCard(tx)),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  // --- 3. MONTHLY EXPENSES SECTION (with Category Distribution Pills) ---
  Widget _buildMonthlyExpensesSection(List<TransactionItem> filteredExpenses) {
    final monthlyGroups = widget.state.monthlyExpenseHistory;
    final totalSpentThisMonth = widget.state.totalExpensesThisMonth;
    final budgetLeft = widget.state.spendingBalanceLeft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly KPI Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "THIS MONTH SPENT",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(totalSpentThisMonth),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SPENDING POOL LEFT",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.formatCurrency(budgetLeft),
                      style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Monthly History (${monthlyGroups.length} Months)",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              "Category Breakdown",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (monthlyGroups.isEmpty)
          _buildEmptyState("No monthly expenses logged yet.")
        else
          ...monthlyGroups.map((month) {
            final now = DateTime.now();
            final isCurrentMonth = month.year == now.year && month.month == now.month;

            final monthItems = filteredExpenses.where((t) {
              return t.date.year == month.year && t.date.month == month.month;
            }).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentMonth
                      ? AppTheme.primaryTeal.withValues(alpha: 0.4)
                      : AppTheme.surfaceBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: isCurrentMonth ? AppTheme.primaryTeal : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            month.label,
                            style: TextStyle(
                              color: isCurrentMonth ? AppTheme.primaryTeal : AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isCurrentMonth) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(color: AppTheme.primaryTeal, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        AppTheme.formatCurrency(month.totalExpense),
                        style: const TextStyle(
                          color: AppTheme.expenseCoral,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Breakdown Chips
                  if (month.categoryBreakdown.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: month.categoryBreakdown.entries.map((entry) {
                        final cat = widget.state.getCategoryById(entry.key);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 12, color: cat.color),
                              const SizedBox(width: 5),
                              Text(
                                "${cat.name}: ${AppTheme.formatCurrency(entry.value)}",
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Transactions list
                  if (monthItems.isNotEmpty)
                    ...monthItems.map((tx) => _buildTransactionCard(tx))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "No transactions matching current filter for this month.",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            );
          }),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        radius: 14,
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: category.color, size: 18),
            ),
            const SizedBox(width: 12),

            // Middle Column: Title, Category • Bank Name, Note (Guaranteed no overflow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  // Combined single-span line so text never draws outside or overlaps
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: category.name,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        if (bank != null) ...[
                          TextSpan(
                            text: " • ",
                            style: TextStyle(
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: bank.name,
                            style: TextStyle(
                              color: bank.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tx.note!.trim(),
                      style: TextStyle(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.85),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right Column: Amount & Compact Delete Button
            Builder(
              builder: (context) {
                final isTransfer = tx.isTransfer || widget.state.isTransferOrTopUp(tx);
                final isExpense = tx.type == TransactionType.expense;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTransfer
                              ? "⇄ ${AppTheme.formatCurrency(tx.amount)}"
                              : "${isExpense ? '-' : '+'}${AppTheme.formatCurrency(tx.amount)}",
                          style: TextStyle(
                            color: isTransfer
                                ? const Color(0xFF38BDF8)
                                : (isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_expenseTimeframe != 'daily') ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(tx.date),
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Compact Delete Icon
                    InkWell(
                      onTap: () => _confirmDeleteTransaction(context, tx),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.expenseCoral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.expenseCoral,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
