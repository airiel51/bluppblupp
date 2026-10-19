import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class CategoryBudgetSheet extends StatefulWidget {
  final FinanceState state;

  const CategoryBudgetSheet({super.key, required this.state});

  static Future<void> show(BuildContext context, {required FinanceState state}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryBudgetSheet(state: state),
    );
  }

  @override
  State<CategoryBudgetSheet> createState() => _CategoryBudgetSheetState();
}

class _CategoryBudgetSheetState extends State<CategoryBudgetSheet> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _overallBudgetController;
  bool _syncOverallBudget = true;

  @override
  void initState() {
    super.initState();
    _overallBudgetController = TextEditingController(
      text: widget.state.monthlySpendingBudget > 0
          ? widget.state.monthlySpendingBudget.toStringAsFixed(0)
          : '',
    );

    _controllers = {};
    final expenseCategories = widget.state.categories
        .where((c) => c.type == TransactionType.expense && c.id != 'bank_transfer')
        .toList();

    for (final cat in expenseCategories) {
      final existing = widget.state.getCategoryBudget(cat.id);
      _controllers[cat.id] = TextEditingController(
        text: existing > 0 ? existing.toStringAsFixed(0) : '',
      );
      _controllers[cat.id]!.addListener(_onCategoryBudgetChanged);
    }
  }

  void _onCategoryBudgetChanged() {
    if (_syncOverallBudget && mounted) {
      final total = _calculateTotalAllocated();
      if (total > 0) {
        _overallBudgetController.text = total.toStringAsFixed(0);
      }
      setState(() {});
    } else if (mounted) {
      setState(() {});
    }
  }

  double _calculateTotalAllocated() {
    double sum = 0.0;
    for (final c in _controllers.values) {
      final val = double.tryParse(c.text.trim()) ?? 0.0;
      sum += val;
    }
    return sum;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _overallBudgetController.dispose();
    super.dispose();
  }

  void _applyPreset(String presetType) {
    final overall = double.tryParse(_overallBudgetController.text.trim()) ??
        (widget.state.monthlySpendingBudget > 0 ? widget.state.monthlySpendingBudget : 3000.0);

    final Map<String, double> ratios;
    if (presetType == '50_30_20') {
      // 50% Needs, 30% Wants, 20% Flexible
      ratios = {
        'groceries': 0.20,
        'utilities': 0.15,
        'transport': 0.15,
        'food': 0.15,
        'shopping': 0.10,
        'entertainment': 0.05,
        'health': 0.10,
        'other_exp': 0.10,
      };
    } else if (presetType == 'balanced') {
      ratios = {
        'food': 0.25,
        'groceries': 0.20,
        'utilities': 0.15,
        'transport': 0.12,
        'shopping': 0.10,
        'entertainment': 0.08,
        'health': 0.05,
        'other_exp': 0.05,
      };
    } else {
      // Clear
      for (final c in _controllers.values) {
        c.text = '';
      }
      return;
    }

    ratios.forEach((catId, ratio) {
      if (_controllers.containsKey(catId)) {
        final amount = (overall * ratio).roundToDouble();
        _controllers[catId]!.text = amount.toStringAsFixed(0);
      }
    });
  }

  void _saveBudgets() {
    final Map<String, double> newBudgets = {};
    for (final entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text.trim()) ?? 0.0;
      if (val > 0) {
        newBudgets[entry.key] = val;
      }
    }

    final overall = double.tryParse(_overallBudgetController.text.trim());
    if (overall != null && overall > 0) {
      widget.state.setMonthlyBudget(overall);
    }

    widget.state.setAllCategoryBudgets(newBudgets, syncOverallBudget: _syncOverallBudget);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Category budgets updated successfully!"),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final totalAllocated = _calculateTotalAllocated();
    final overallBudget = double.tryParse(_overallBudgetController.text.trim()) ?? widget.state.monthlySpendingBudget;
    final expenseCategories = widget.state.categories
        .where((c) => c.type == TransactionType.expense && c.id != 'bank_transfer')
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pie_chart_rounded, color: AppTheme.primaryTeal, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Category Budgets",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Set targeted spending limits per category",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Main Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Overview Card
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "OVERALL MONTHLY TARGET",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Allocated: ${AppTheme.formatCurrency(totalAllocated)}",
                              style: TextStyle(
                                color: totalAllocated > overallBudget && overallBudget > 0
                                    ? AppTheme.expenseCoral
                                    : AppTheme.primaryTeal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _overallBudgetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            prefixText: "RM ",
                            prefixStyle: const TextStyle(
                              color: AppTheme.primaryTeal,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            hintText: "0.00",
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            filled: true,
                            fillColor: AppTheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _syncOverallBudget,
                                activeColor: AppTheme.primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) {
                                  setState(() {
                                    _syncOverallBudget = val ?? true;
                                    if (_syncOverallBudget && totalAllocated > 0) {
                                      _overallBudgetController.text = totalAllocated.toStringAsFixed(0);
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Auto-sync overall budget = sum of category budgets",
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Presets
                  Row(
                    children: [
                      Text(
                        "Quick Presets:",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      _buildPresetChip("50/30/20 Rule", () => _applyPreset('50_30_20')),
                      const SizedBox(width: 6),
                      _buildPresetChip("Balanced", () => _applyPreset('balanced')),
                      const SizedBox(width: 6),
                      _buildPresetChip("Clear", () => _applyPreset('clear')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Rows List
                  Text(
                    "CATEGORIES ALLOCATION",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenseCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final cat = expenseCategories[index];
                      final ctrl = _controllers[cat.id]!;
                      final spentThisMonth = widget.state.getCategorySpentThisMonth(cat.id);
                      final currentBudget = double.tryParse(ctrl.text.trim()) ?? 0.0;
                      final isOverbudget = currentBudget > 0 && spentThisMonth > currentBudget;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isOverbudget
                                ? AppTheme.expenseCoral.withValues(alpha: 0.5)
                                : AppTheme.surfaceBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 18),
                            ),
                            const SizedBox(width: 12),

                            // Category info & spent
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        "Spent: ${AppTheme.formatCurrency(spentThisMonth)}",
                                        style: TextStyle(
                                          color: isOverbudget ? AppTheme.expenseCoral : AppTheme.textMuted,
                                          fontSize: 11.5,
                                          fontWeight: isOverbudget ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                      if (isOverbudget) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.expenseCoral.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "Over",
                                            style: TextStyle(
                                              color: AppTheme.expenseCoral,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Budget input
                            SizedBox(
                              width: 105,
                              height: 38,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  prefixText: "RM ",
                                  prefixStyle: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  hintText: "0",
                                  hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  filled: true,
                                  fillColor: AppTheme.surface,
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
                                    borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Save Action
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _saveBudgets,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  "Save Category Budgets",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
