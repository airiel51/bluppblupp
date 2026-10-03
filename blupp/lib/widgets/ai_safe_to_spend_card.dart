import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class AiSafeToSpendCard extends StatelessWidget {
  final FinanceState state;

  const AiSafeToSpendCard({super.key, required this.state});

  void _showDiagnosticsSheet(BuildContext context) {
    final radar = state.aiSafeToSpendRadar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: radar.zoneColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(radar.zoneIcon, color: radar.zoneColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "AI Safe-to-Spend Diagnostics",
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: radar.zoneColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  radar.statusHeadline,
                                  style: TextStyle(color: radar.zoneColor, fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Dynamic monthly runway & daily burn simulation",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.paddingOf(context).bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mathematical Formula Narrative Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: radar.zoneColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: radar.zoneColor.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 16, color: radar.zoneColor),
                                const SizedBox(width: 8),
                                Text(
                                  "AI Velocity Formula",
                                  style: TextStyle(color: radar.zoneColor, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              radar.statusAdvice,
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.45),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Telemetry Metrics Grid
                      Text(
                        "Runway Telemetry Breakdown",
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTelemetryTile(
                              "Safe Daily Ceiling",
                              AppTheme.formatCurrency(radar.safeDailyAllowance),
                              "Target limit per day",
                              Icons.speed_rounded,
                              radar.zoneColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTelemetryTile(
                              "Spent Today",
                              AppTheme.formatCurrency(radar.spentToday),
                              radar.safeBufferRemainingToday >= 0
                                  ? "${AppTheme.formatCurrency(radar.safeBufferRemainingToday)} buffer left"
                                  : "Over by ${AppTheme.formatCurrency(radar.safeBufferRemainingToday.abs())}",
                              Icons.today_rounded,
                              radar.safeBufferRemainingToday >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTelemetryTile(
                              "Days Remaining",
                              "${radar.daysRemainingInMonth} Days",
                              "In current month cycle",
                              Icons.calendar_today_rounded,
                              const Color(0xFF38BDF8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTelemetryTile(
                              "Locked Commitments",
                              AppTheme.formatCurrency(radar.upcomingCommittedSpending),
                              "Reserved for bills/rent",
                              Icons.lock_clock_rounded,
                              const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Month-End Forecast Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insights_rounded, size: 16, color: Color(0xFF38BDF8)),
                                const SizedBox(width: 8),
                                const Text(
                                  "Month-End Liquidity Projection",
                                  style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              radar.projectedMonthEndSurplus >= 0
                                  ? "At current daily spending velocity, you are on track to close the month with a surplus of ~${AppTheme.formatCurrency(radar.projectedMonthEndSurplus)}."
                                  : "Warning: At current velocity, you are projected to face a month-end deficit of ${AppTheme.formatCurrency(radar.projectedMonthEndSurplus.abs())}. Consider pausing discretionary dining and shopping.",
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTelemetryTile(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radar = state.aiSafeToSpendRadar;
    final progress = radar.safeDailyAllowance > 0
        ? (radar.spentToday / radar.safeDailyAllowance).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: () => _showDiagnosticsSheet(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: radar.zoneColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: radar.zoneColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: radar.zoneColor,
                        boxShadow: [
                          BoxShadow(
                            color: radar.zoneColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "AI SAFE-TO-SPEND RADAR",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: radar.zoneColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: radar.zoneColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(radar.zoneIcon, size: 12, color: radar.zoneColor),
                      const SizedBox(width: 4),
                      Text(
                        radar.statusHeadline,
                        style: TextStyle(color: radar.zoneColor, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle Hero Metric
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  AppTheme.formatCurrency(radar.safeDailyAllowance),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "/ day today",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress Bar (Spent Today vs Allowance)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.background,
                valueColor: AlwaysStoppedAnimation<Color>(radar.zoneColor),
              ),
            ),

            const SizedBox(height: 10),

            // Sub-metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Spent today: ${AppTheme.formatCurrency(radar.spentToday)}",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
                Row(
                  children: [
                    Text(
                      radar.safeBufferRemainingToday >= 0
                          ? "${AppTheme.formatCurrency(radar.safeBufferRemainingToday)} safe buffer"
                          : "Over by ${AppTheme.formatCurrency(radar.safeBufferRemainingToday.abs())}",
                      style: TextStyle(
                        color: radar.zoneColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
