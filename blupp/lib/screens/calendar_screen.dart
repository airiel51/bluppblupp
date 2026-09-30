import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

class CalendarScreen extends StatefulWidget {
  final FinanceState state;

  const CalendarScreen({super.key, required this.state});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final nextWeekTotal = widget.state.nextWeekPlannedSpending;
    final selectedDayPlans = widget.state.getPlannedExpensesForDate(_selectedDate);
    final selectedDayTotal = widget.state.getPlannedTotalForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: AppTheme.warningAmber, size: 24),
            SizedBox(width: 8),
            Text(
              "Expense Planner",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNextWeekPlannedHero(nextWeekTotal),
            const SizedBox(height: 20),

            _buildCalendarCard(),
            const SizedBox(height: 24),

            _buildSelectedDaySection(selectedDayPlans, selectedDayTotal),
            const SizedBox(height: 24),

            _buildAllUpcomingPlansSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.textPrimary,
        foregroundColor: AppTheme.background,
        elevation: 0,
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text(
          "Plan Expense",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        onPressed: () => _showAddPlannedExpenseModal(context),
      ),
    );
  }

  Widget _buildNextWeekPlannedHero(double nextWeekTotal) {
    return Container(
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.warningAmber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.trending_flat_rounded, color: AppTheme.warningAmber, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "NEXT WEEK PLANNED SPENDING",
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
                  color: AppTheme.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Next 7 Days",
                  style: TextStyle(
                    color: AppTheme.warningAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppTheme.formatCurrency(nextWeekTotal),
            style: TextStyle(color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Forecasted commitments for the coming week to keep your budget safe.",
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${months[month - 1]} $year",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppTheme.textSecondary, size: 20),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(year, month - 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(year, month + 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel("Mon"),
              _WeekdayLabel("Tue"),
              _WeekdayLabel("Wed"),
              _WeekdayLabel("Thu"),
              _WeekdayLabel("Fri"),
              _WeekdayLabel("Sat"),
              _WeekdayLabel("Sun"),
            ],
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }

              final day = index - startOffset + 1;
              final cellDate = DateTime(year, month, day);
              final isSelected = cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              final now = DateTime.now();
              final isToday = cellDate.year == now.year &&
                  cellDate.month == now.month &&
                  cellDate.day == now.day;

              final plansForDay = widget.state.getPlannedExpensesForDate(cellDate);
              final hasPlans = plansForDay.isNotEmpty;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.textPrimary
                        : (isToday ? AppTheme.surfaceLight : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.textPrimary
                          : (isToday ? AppTheme.surfaceBorder : Colors.transparent),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$day",
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.background
                              : (isToday ? AppTheme.primaryTeal : AppTheme.textPrimary),
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (hasPlans) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.background : AppTheme.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDaySection(List<PlannedExpense> plans, double dayTotal) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final formattedDate =
        "${weekdays[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}";

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
                  formattedDate,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Planned Total for Day: ${AppTheme.formatCurrency(dayTotal)}",
                  style: TextStyle(color: AppTheme.warningAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.warningAmber),
              tooltip: "Plan Expense for this Day",
              onPressed: () => _showAddPlannedExpenseModal(context, preselectedDate: _selectedDate),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (plans.isEmpty)
          BluppEmptyState(
            icon: Icons.event_available_rounded,
            title: "No expenses on this day",
            description: "You have no upcoming commitments planned for $formattedDate.",
            actionLabel: "Plan for this Day",
            onAction: () => _showAddPlannedExpenseModal(context, preselectedDate: _selectedDate),
          )
        else
          ...plans.asMap().entries.map((e) => _buildPlanItemCard(e.value, e.key)),
      ],
    );
  }

  Widget _buildPlanItemCard(PlannedExpense plan, [int index = 0]) {
    final category = widget.state.getCategoryById(plan.categoryId);

    return InteractiveCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.title,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: plan.isPaid ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (plan.isRecurring)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("Monthly", style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  plan.note ?? category.name,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppTheme.formatCurrency(plan.amount),
                style: TextStyle(color: AppTheme.warningAmber,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!plan.isPaid)
                    InkWell(
                      onTap: () {
                        final defaultBank = widget.state.bankAccounts.isNotEmpty
                            ? widget.state.bankAccounts.first.id
                            : '';
                        widget.state.convertPlannedToActual(plan.id, defaultBank);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Recorded '${plan.title}' as actual expense. Net worth updated!"),
                            backgroundColor: AppTheme.primaryTeal,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Mark Paid",
                          style: TextStyle(color: AppTheme.primaryTeal, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    const Text(
                      "Paid ✅",
                      style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(width: 8),
                  // Delete Button
                  InkWell(
                    onTap: () => _confirmDeletePlan(context, plan),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.expenseCoral.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded, color: AppTheme.expenseCoral,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms, delay: Duration(milliseconds: (30 * index).clamp(0, 300))).slideY(begin: 0.05, end: 0);
  }

  void _confirmDeletePlan(BuildContext context, PlannedExpense plan) {
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
              "Delete Commitment",
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete '${plan.title}'?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: ${AppTheme.formatCurrency(plan.amount)}\nDue Date: ${plan.date.day}/${plan.date.month}/${plan.date.year}\nThis will remove the upcoming commitment from your calendar schedule and synchronize with Supabase.",
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
              widget.state.deletePlannedExpense(plan.id);
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
                        "Deleted commitment '${plan.title}'",
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

  Widget _buildAllUpcomingPlansSection() {
    final upcoming = widget.state.plannedExpenses.where((p) => !p.isPaid).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Commitments This Month",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        if (upcoming.isEmpty)
          BluppEmptyState(
            icon: Icons.calendar_today_rounded,
            title: "All commitments cleared",
            description: "No future expenses or recurring bills scheduled for this month.",
            actionLabel: "Plan Future Expense",
            onAction: () => _showAddPlannedExpenseModal(context),
          )
        else
          ...upcoming.asMap().entries.map((e) => _buildPlanItemCard(e.value, e.key)),
      ],
    );
  }

  void _showAddPlannedExpenseModal(BuildContext context, {DateTime? preselectedDate}) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime planDate = preselectedDate ?? _selectedDate;
    String selectedCatId = 'transport';
    bool isRecurring = false;
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
            final categories = widget.state.categories
                .where((c) => c.type == TransactionType.expense)
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
                          "Plan Future Expense",
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
                      const SizedBox(height: 14),
                    ],

                    // Recurrence Segment (Horizontal boxed alignment)
                    Text(
                      "Commitment Type",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    BluppBoxedSegment<bool>(
                      selectedValue: isRecurring,
                      options: const [
                        {'label': 'One-Time Bill', 'value': false, 'icon': Icons.event_note_rounded},
                        {'label': 'Monthly Recurring', 'value': true, 'icon': Icons.repeat_rounded},
                      ],
                      onChanged: (val) => setModalState(() => isRecurring = val),
                      activeColor: AppTheme.warningAmber,
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: titleController,
                      style: TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "What are you planning for?",
                        hintText: "e.g. Car Insurance, Vacation Flight, Annual Gym, Rent",
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
                    const SizedBox(height: 12),

                    // Currency Selector Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.travel_explore_rounded, color: AppTheme.warningAmber, size: 16),
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
                                ? AppTheme.warningAmber.withValues(alpha: 0.15)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedCurrency != widget.state.baseCurrency
                                ? AppTheme.warningAmber
                                : AppTheme.surfaceBorder,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCurrency,
                              dropdownColor: AppTheme.surface,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down, color: AppTheme.warningAmber),
                              style: TextStyle(
                                color: selectedCurrency != widget.state.baseCurrency
                                    ? AppTheme.warningAmber
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

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: "${CurrencyManager.getCurrency(selectedCurrency).symbol} ",
                        prefixStyle: TextStyle(color: AppTheme.warningAmber, fontSize: 16, fontWeight: FontWeight.bold),
                        labelText: selectedCurrency != widget.state.baseCurrency
                            ? "Estimated Amount in $selectedCurrency (Travel)"
                            : "Estimated Amount (${widget.state.baseCurrency})",
                        hintText: "0.00 (e.g. 250.00)",
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
                    if (selectedCurrency != widget.state.baseCurrency &&
                        (double.tryParse(amountController.text.trim()) ?? 0.0) > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange_rounded, color: AppTheme.warningAmber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Auto-Converted to Base (${widget.state.baseCurrency}):",
                                    style: TextStyle(color: AppTheme.warningAmber, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${CurrencyManager.format(double.tryParse(amountController.text.trim()) ?? 0.0, selectedCurrency)} ≈ ${AppTheme.formatCurrency(CurrencyManager.convert(amount: double.tryParse(amountController.text.trim()) ?? 0.0, fromCode: selectedCurrency, toCode: widget.state.baseCurrency))}",
                                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: planDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppTheme.warningAmber,
                                  onPrimary: Colors.black,
                                  surface: AppTheme.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            planDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date of Expense:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            Text(
                              "${planDate.day}/${planDate.month}/${planDate.year}",
                              style: TextStyle(color: AppTheme.warningAmber, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Boxed Category Picker
                    Text("Category", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    BluppHorizontalBoxPicker<String>(
                      selectedValue: selectedCatId,
                      options: categories.map((c) => {
                        'label': c.name,
                        'value': c.id,
                        'icon': c.icon,
                        'color': c.color,
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCatId = val),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: noteController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "Notes / Priority",
                        hintText: "e.g. Due before 15th, remember to ask for official receipt",
                        hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                        labelStyle: TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textPrimary,
                          foregroundColor: AppTheme.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
                          if (title.isEmpty) {
                            setModalState(() {
                              errorWhere = "Commitment Name";
                              errorWhy = "Please specify what you are planning for before saving.";
                            });
                            return;
                          }
                          if (enteredAmount <= 0) {
                            setModalState(() {
                              errorWhere = "Estimated Amount";
                              errorWhy = "Please enter an estimated amount greater than 0.00.";
                            });
                            return;
                          }

                          final baseAmount = CurrencyManager.convert(
                            amount: enteredAmount,
                            fromCode: selectedCurrency,
                            toCode: widget.state.baseCurrency,
                          );
                          final isForeign = selectedCurrency != widget.state.baseCurrency;
                          final originalNote = noteController.text.trim();
                          final finalNote = isForeign
                              ? (originalNote.isEmpty
                                  ? "Planned in ${CurrencyManager.format(enteredAmount, selectedCurrency)}"
                                  : "$originalNote • (${CurrencyManager.format(enteredAmount, selectedCurrency)})")
                              : originalNote;

                          widget.state.addPlannedExpense(PlannedExpense(
                            id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            amount: baseAmount,
                            categoryId: selectedCatId,
                            date: planDate,
                            isRecurring: isRecurring,
                            note: finalNote,
                          ));
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isForeign
                                    ? "Planned '$title' (${CurrencyManager.format(enteredAmount, selectedCurrency)} ≈ ${AppTheme.formatCurrency(baseAmount)}) on ${planDate.day}/${planDate.month}!"
                                    : "Planned '$title' (${AppTheme.formatCurrency(baseAmount)}) on ${planDate.day}/${planDate.month}!",
                              ),
                              backgroundColor: AppTheme.primaryTeal,
                            ),
                          );
                        },
                        child: const Text("Save Planned Expense", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
