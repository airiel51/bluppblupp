import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  final FinanceState state;

  const AnalyticsScreen({super.key, required this.state});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartAnimController;
  late Animation<double> _chartProgressAnim;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartProgressAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeOutCubic,
    );
    _chartAnimController.forward();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.state.categoryExpenseBreakdown;
    final totalExpense = widget.state.totalExpensesThisMonth;
    final spendingBalanceLeft = widget.state.spendingBalanceLeft;
    final budget = widget.state.monthlySpendingBudget;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day).clamp(1, 31);
    final dailyAllowance = spendingBalanceLeft / remainingDays;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Analytics",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpendingBalanceHero(spendingBalanceLeft, budget, totalExpense, dailyAllowance, remainingDays),
            const SizedBox(height: 24),

            _buildSpendingEquation(budget, totalExpense, spendingBalanceLeft),
            const SizedBox(height: 28),

            _buildCategoryBreakdownSection(breakdown, totalExpense),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingBalanceHero(
    double balanceLeft,
    double budget,
    double totalExpense,
    double dailyAllowance,
    int remainingDays,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded, color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "TOTAL SPENDING BALANCE LEFT",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$remainingDays days left",
                  style: TextStyle(color: AppTheme.primaryTeal,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            AppTheme.formatCurrency(balanceLeft),
            style: TextStyle(color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppTheme.warningAmber, size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Safe Daily Allowance",
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${AppTheme.formatCurrency(dailyAllowance)} / day",
                          style: TextStyle(color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: dailyAllowance > 40
                        ? AppTheme.primaryTeal.withValues(alpha: 0.2)
                        : AppTheme.expenseCoral.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dailyAllowance > 40 ? "On Track 👍" : "Tight Budget ⚠️",
                    style: TextStyle(
                      color: dailyAllowance > 40 ? AppTheme.primaryTeal : AppTheme.expenseCoral,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingEquation(double budget, double totalExpense, double balanceLeft) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Flow Breakdown",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEquationItem("Monthly Target", AppTheme.formatCurrency(budget), AppTheme.textSecondary),
              const Icon(Icons.remove, size: 16, color: AppTheme.expenseCoral),
              _buildEquationItem("Expenses Logged", AppTheme.formatCurrency(totalExpense), AppTheme.expenseCoral),
              const Icon(Icons.drag_handle, size: 16, color: AppTheme.primaryTeal),
              _buildEquationItem("Balance Left", AppTheme.formatCurrency(balanceLeft), AppTheme.primaryTeal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquationItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection(Map<String, double> breakdown, double totalExpense) {
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Category Breakdown",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(Icons.replay_rounded, size: 18, color: AppTheme.textSecondary),
              tooltip: "Replay Animation",
              onPressed: () {
                _chartAnimController.reset();
                _chartAnimController.forward();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (totalExpense <= 0 || sortedEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: AppTheme.cardDecoration(),
            child: Text(
              "No expenses recorded this month yet.\nLog transactions in the Expense tab to see live breakdown!",
              style: TextStyle(color: AppTheme.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: AppTheme.cardDecoration(),
            child: Center(
              child: AnimatedBuilder(
                animation: _chartProgressAnim,
                builder: (context, child) {
                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: DonutChartPainter(
                            entries: sortedEntries,
                            total: totalExpense,
                            categories: widget.state.categories,
                            progress: _chartProgressAnim.value,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "TOTAL SPENT",
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppTheme.formatCurrency(totalExpense * _chartProgressAnim.value),
                              style: TextStyle(color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          ...sortedEntries.map((entry) {
            final category = widget.state.getCategoryById(entry.key);
            final amount = entry.value;
            final pct = totalExpense > 0 ? (amount / totalExpense) : 0.0;

            return AnimatedBuilder(
              animation: _chartProgressAnim,
              builder: (context, child) {
                final animPct = pct * _chartProgressAnim.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(category.icon, color: category.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${(pct * 100).toStringAsFixed(1)}% of total expenses",
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppTheme.formatCurrency(amount),
                            style: TextStyle(
                              color: category.color,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: animPct,
                          minHeight: 6,
                          backgroundColor: AppTheme.surfaceBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(category.color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final List<CategoryItem> categories;
  final double progress;

  DonutChartPainter({
    required this.entries,
    required this.total,
    required this.categories,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 20.0;

    final basePaint = Paint()
      ..color = AppTheme.surfaceBorder.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, basePaint);

    double startAngle = -math.pi / 2;

    for (final entry in entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => const CategoryItem(
          id: 'other',
          name: 'Other',
          icon: Icons.category,
          color: Colors.grey,
          type: TransactionType.expense,
        ),
      );

      final sweepAngle = (entry.value / total) * 2 * math.pi * progress;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (sweepAngle > 0.05) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + 0.02,
          sweepAngle - 0.04,
          false,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.total != total;
  }
}
