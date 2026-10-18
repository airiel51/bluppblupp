import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_avatar.dart';

class CardsScreen extends StatefulWidget {
  final FinanceState state;

  const CardsScreen({super.key, required this.state});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isCardRevealed = false;
  bool _isCardFrozen = false;

  @override
  Widget build(BuildContext context) {
    final currency = widget.state.baseCurrency;
    final totalSpentThisMonth = widget.state.totalExpensesThisMonth;
    final budget = widget.state.monthlySpendingBudget > 0 ? widget.state.monthlySpendingBudget : 3000.0;
    final budgetPercent = (totalSpentThisMonth / budget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              _buildHeader(context),
              const SizedBox(height: 22),

              // Sunset Gradient Visual Card
              _buildVisualCard(currency),
              const SizedBox(height: 16),

              // 3 Action Pill Buttons (Reveal, Freeze, Settings)
              _buildCardActionPills(),
              const SizedBox(height: 24),

              // Limits Section
              _buildLimitsSection(currency, totalSpentThisMonth, budget, budgetPercent),
              const SizedBox(height: 24),

              // Monthly Limit Donut Chart (From Dribbble Detail View)
              _buildMonthlyLimitChartCard(totalSpentThisMonth, budget, budgetPercent),
              const SizedBox(height: 24),

              // Recent Transactions for Card
              _buildRecentTransactionsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            BluppAvatar(
              state: widget.state,
              size: 38,
            ),
            const SizedBox(width: 12),
            Text(
              "My Cards",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 20),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentCoral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualCard(String currency) {
    final balance = widget.state.spendingBalanceLeft > 0 ? widget.state.spendingBalanceLeft : 1021.65;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: _isCardFrozen
            ? const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF475569), Color(0xFF334155)],
              )
            : AppTheme.sunsetCardGradient,
        boxShadow: [
          BoxShadow(
            color: (_isCardFrozen ? Colors.blueGrey : const Color(0xFFFB923C)).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "General card",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isCardRevealed ? "4214 •••• •••• 8821" : "$currency · VIRTUAL",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _isCardFrozen ? "Frozen" : "Active",
                  style: TextStyle(
                    color: _isCardFrozen ? Colors.blueGrey.shade800 : Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Card Balance & Visa Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppTheme.formatCurrency(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const Text(
                "VISA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionPills() {
    return Row(
      children: [
        // 1. Reveal details
        Expanded(
          child: _buildActionPill(
            icon: _isCardRevealed ? Icons.visibility_off_rounded : Icons.remove_red_eye_rounded,
            onTap: () {
              setState(() => _isCardRevealed = !_isCardRevealed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isCardRevealed ? "Card number visible: 4214 9821 0034 8821 (CVV 821)" : "Card number hidden"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // 2. Freeze card
        Expanded(
          child: _buildActionPill(
            icon: Icons.ac_unit_rounded,
            isActive: _isCardFrozen,
            onTap: () {
              setState(() => _isCardFrozen = !_isCardFrozen);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _isCardFrozen ? const Color(0xFF0284C7) : AppTheme.primaryTeal,
                  content: Text(_isCardFrozen ? "❄️ Card frozen. Transactions paused." : "✅ Card active and ready."),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // 3. Settings / Limits
        Expanded(
          child: _buildActionPill(
            icon: Icons.tune_rounded,
            onTap: () => _showCardSettingsDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLimitsSection(String currency, double totalSpent, double budget, double budgetPercent) {
    final dailyAllowance = widget.state.aiSafeToSpendRadar.safeDailyAllowance;
    final dailySpent = widget.state.transactions
        .where((t) => t.type == TransactionType.expense && t.date.day == DateTime.now().day)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final dailyTarget = dailyAllowance > 0 ? dailyAllowance : 150.0;
    final dailyPercent = (dailySpent / dailyTarget).clamp(0.0, 1.0);

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
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => _showCardSettingsDialog(context),
              child: Text(
                "Edit",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Daily Limit Tile
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
                    Text("Daily limit", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$currency ${(dailySpent > 0 ? dailySpent : 45.0).toStringAsFixed(0)} ",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: "/ ${dailyTarget.toStringAsFixed(0)}",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "${(dailyPercent * 100).toInt()}%",
                          style: const TextStyle(color: AppTheme.accentCoral, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: dailyPercent > 0 ? dailyPercent : 0.35,
                              backgroundColor: AppTheme.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCoral),
                              minHeight: 5,
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

            // Monthly Limit Tile
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
                    Text("Monthly limit", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$currency ${totalSpent.toStringAsFixed(0)} ",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: "/ ${budget.toStringAsFixed(0)}",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "${(budgetPercent * 100).toInt()}%",
                          style: const TextStyle(color: AppTheme.accentAmber, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: budgetPercent > 0 ? budgetPercent : 0.45,
                              backgroundColor: AppTheme.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentAmber),
                              minHeight: 5,
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

  Widget _buildMonthlyLimitChartCard(double totalSpent, double budget, double budgetPercent) {
    final currency = widget.state.baseCurrency;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Monthly limit",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Refreshes on 1st",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showCardSettingsDialog(context),
                child: Text(
                  "Edit",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular Donut Progress Ring
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(170, 170),
                    painter: _MultiSegmentRingPainter(
                      progress: budgetPercent,
                      strokeWidth: 14,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${DateTime.now().year}",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$currency ${totalSpent.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "/ $currency ${budget.toStringAsFixed(0)}",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${(budgetPercent * 100).toInt()}%",
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _CategoryPill(label: "45% Food & Dining", color: Color(0xFFE879F9)),
              _CategoryPill(label: "19% Shopping", color: Color(0xFFFF7A45)),
              _CategoryPill(label: "15% Utilities", color: Color(0xFFF6C343)),
              _CategoryPill(label: "21% Other", color: Color(0xFF60A5FA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recent = widget.state.transactions.take(4).toList();

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
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              "See all",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text("No transactions recorded yet", style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (context, index) => Divider(color: AppTheme.surfaceBorder.withValues(alpha: 0.5), height: 1),
              itemBuilder: (context, index) {
                final tx = recent[index];
                final isIncome = tx.type == TransactionType.income;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? const Color(0xFF4ADE80).withValues(alpha: 0.15)
                          : AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.add_rounded : Icons.shopping_bag_outlined,
                      color: isIncome ? const Color(0xFF4ADE80) : AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${tx.categoryId.toUpperCase()} · ${_formatDate(tx.date)}",
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    "${isIncome ? '+' : '-'}${AppTheme.formatCurrency(tx.amount)}",
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF4ADE80) : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    }
    return "${d.day}/${d.month}";
  }

  void _showCardSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Text("Card Security & Limits", style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SwitchListTile(
                value: !_isCardFrozen,
                onChanged: (val) {
                  setState(() => _isCardFrozen = !val);
                  Navigator.pop(ctx);
                },
                title: Text("Enable Online Payments", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text("Allows virtual card checkouts", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                activeTrackColor: AppTheme.primaryTeal,
              ),
              SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: Text("International Transactions", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text("Multi-currency zero foreign fee enabled", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                activeTrackColor: AppTheme.primaryTeal,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MultiSegmentRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _MultiSegmentRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFF232532)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Segmented rings
    final sweep = 2 * math.pi * progress.clamp(0.05, 1.0);
    final seg1Sweep = sweep * 0.45;
    final seg2Sweep = sweep * 0.25;
    final seg3Sweep = sweep * 0.18;
    final seg4Sweep = sweep * 0.12;

    double startAngle = -math.pi / 2;

    // Segment 1 (Pink)
    final p1 = Paint()
      ..color = const Color(0xFFE879F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg1Sweep, false, p1);
    startAngle += seg1Sweep;

    // Segment 2 (Orange)
    final p2 = Paint()
      ..color = const Color(0xFFFF7A45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg2Sweep, false, p2);
    startAngle += seg2Sweep;

    // Segment 3 (Yellow)
    final p3 = Paint()
      ..color = const Color(0xFFF6C343)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg3Sweep, false, p3);
    startAngle += seg3Sweep;

    // Segment 4 (Blue)
    final p4 = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, seg4Sweep, false, p4);
  }

  @override
  bool shouldRepaint(covariant _MultiSegmentRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
