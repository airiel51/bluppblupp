import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';

class FomoScreen extends StatefulWidget {
  final FinanceState state;

  const FomoScreen({super.key, required this.state});

  @override
  State<FomoScreen> createState() => _FomoScreenState();
}

class _FomoScreenState extends State<FomoScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  final String _selectedCategory = 'shopping';
  String _selectedUrgency = 'TikTok / Social Media Hype';
  String _selectedCurrency = 'MYR';
  bool _isEvaluating = false;
  String? _inputErrorWhere;
  String? _inputErrorWhy;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.state.baseCurrency;
  }

  // Evaluation Result State
  bool _hasResult = false;
  String _evaluatedItem = '';
  double _evaluatedCost = 0.0;
  String _verdict = '';
  String _verdictType = 'danger';
  String _aiAdvice = '';
  String _whyNotNeed = '';
  double _oldBalance = 0.0;
  double _newBalance = 0.0;
  double _oldDailyAllowance = 0.0;
  double _newDailyAllowance = 0.0;

  final List<String> _urgencyOptions = [
    'TikTok / Social Media Hype',
    'Flash Sale / Limited Time Discount',
    'Saw Friends / Influencer using it',
    'Feeling Stressed / Treat Myself',
    'Actually Need it for Daily Life',
  ];

  Future<void> _evaluatePurchase() async {
    final item = _itemController.text.trim();
    final enteredCost = double.tryParse(_costController.text.trim()) ?? 0.0;

    if (item.isEmpty) {
      setState(() {
        _inputErrorWhere = "Purchase Item Name";
        _inputErrorWhy = "Please specify what you are tempted to buy (e.g. Sony WH-1000XM5, Steam Deck).";
      });
      return;
    }

    if (enteredCost <= 0) {
      setState(() {
        _inputErrorWhere = "Item Cost ($_selectedCurrency)";
        _inputErrorWhy = "Please enter a realistic estimated price greater than 0.00.";
      });
      return;
    }

    setState(() {
      _inputErrorWhere = null;
      _inputErrorWhy = null;
      _isEvaluating = true;
    });

    // Auto convert if entered in travel currency
    final cost = CurrencyManager.convert(
      amount: enteredCost,
      fromCode: _selectedCurrency,
      toCode: widget.state.baseCurrency,
    );

    final userName = widget.state.userName;
    final currentBalance = widget.state.spendingBalanceLeft;
    final projectedBalance = currentBalance - cost;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day).clamp(1, 31);

    final oldDaily = currentBalance / remainingDays;
    final newDaily = projectedBalance > 0 ? projectedBalance / remainingDays : 0.0;

    // Upcoming calendar planned commitments
    final upcomingPlans = widget.state.plannedExpenses
        .where((p) => !p.isPaid && p.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    final upcomingPlannedTotal = upcomingPlans.fold<double>(0.0, (sum, p) => sum + p.amount);

    // Active loan commitments
    final monthlyLoans = widget.state.loans;
    final totalMonthlyLoans = monthlyLoans.fold<double>(0.0, (sum, l) => sum + l.monthlyInstallment);
    final loanSummary = monthlyLoans.map((l) => "${l.name} (${AppTheme.formatCurrency(l.monthlyInstallment)}/mo)").join(", ");

    // Investments return comparison
    final primaryInv = widget.state.investments.isNotEmpty ? widget.state.investments.first : null;
    final invRate = primaryInv != null ? primaryInv.returnRateAnnual : 5.5;
    final invName = primaryInv != null ? primaryInv.name : 'ASNB Fund';
    final invThreeYearGain = cost * (invRate / 100.0) * 3;

    // True safety cushion accounting for scheduled calendar bills
    final effectiveCushion = currentBalance - upcomingPlannedTotal;

    String serverAdvice = '';
    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/advice/0165f8cb-7deb-4dd3-b9b5-59db5e70c2f1');
      final res = await http.get(url).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        serverAdvice = data['advice'] ?? '';
      }
    } catch (_) {
      // Backend offline or timeout -> fallback to intelligent rules
    }

    String vType = 'safe';
    String verdictTitle = 'SAFE TO BUY ✅';
    String adviceText = '';
    String whyNot = '';

    final isTravel = _selectedCurrency != widget.state.baseCurrency;
    final costDisplay = isTravel
        ? "${CurrencyManager.format(enteredCost, _selectedCurrency)} (≈ ${AppTheme.formatCurrency(cost)})"
        : AppTheme.formatCurrency(cost);

    if (projectedBalance < 0) {
      vType = 'danger';
      verdictTitle = '🛑 CRITICAL OVER-BUDGET ALERT!';
      adviceText =
          "$userName, buying '$item' for $costDisplay will completely wipe out your remaining spending balance and plunge you into a negative deficit of ${AppTheme.formatCurrency(projectedBalance.abs())}!";
      whyNot =
          "• Cashflow Crisis: You have $remainingDays days left this month with zero remaining spending margin.\n"
          "• Fixed Obligations: You have ${AppTheme.formatCurrency(totalMonthlyLoans)} committed in monthly installments ($loanSummary). Going negative here puts your essential obligations at risk.\n"
          "• Compounding Opportunity: If you channel $costDisplay into your $invName ($invRate% p.a.), it grows by +${AppTheme.formatCurrency(invThreeYearGain)} over 3 years without stress.\n"
          "• Psychological Trigger: You selected: '$_selectedUrgency'. Impulsive purchases from hype or stress carry an 88% regret rate within 2 weeks. Apply the 30-Day Rule!";
    } else if (cost > effectiveCushion && effectiveCushion > 0) {
      vType = 'warning';
      verdictTitle = '⚠️ CALENDAR CONFLICT: TIGHTENS YOUR MONTH!';
      adviceText =
          "Caution $userName! While your current spending pool is ${AppTheme.formatCurrency(currentBalance)}, you have ${AppTheme.formatCurrency(upcomingPlannedTotal)} reserved for upcoming calendar commitments (${upcomingPlans.take(2).map((p) => p.title).join(', ')}). Buying '$item' leaves only ${AppTheme.formatCurrency(effectiveCushion - cost)} for unexpected emergencies.";
      whyNot =
          "• Scheduled Bills: You have ${upcomingPlans.length} upcoming commitments totaling ${AppTheme.formatCurrency(upcomingPlannedTotal)} this month.\n"
          "• Daily Squeeze: Your daily allowance will drop sharply from ${AppTheme.formatCurrency(oldDaily)}/day down to ${AppTheme.formatCurrency(newDaily)}/day for $remainingDays days.\n"
          "• Active Loans: Keep your monthly installments ($loanSummary) protected.\n"
          "• Cooling Off: Wait 72 hours before completing this order. 70% of urges fade after 3 days.";
    } else if (cost > currentBalance * 0.35 || newDaily < 25.0) {
      vType = 'warning';
      verdictTitle = '⚠️ HEAVY DENT IN DAILY ALLOWANCE';
      adviceText =
          "Hey $userName, '$item' takes ${(cost / currentBalance * 100).toStringAsFixed(0)}% of your remaining spending pool. Your daily budget will drop from ${AppTheme.formatCurrency(oldDaily)}/day to ${AppTheme.formatCurrency(newDaily)}/day for the next $remainingDays days.";
      whyNot =
          "• Daily Pressure: Surviving on ${AppTheme.formatCurrency(newDaily)}/day for $remainingDays days can cause friction with food and essentials.\n"
          "• Growth Alternative: Putting $costDisplay into $invName compounds to +${AppTheme.formatCurrency(invThreeYearGain)} in 3 years.\n"
          "• 48-Hour Pause: Give this urge a 48-hour cooling period. If it's still essential by ${now.add(const Duration(days: 2)).day}/${now.add(const Duration(days: 2)).month}, re-evaluate.";
    } else {
      vType = 'safe';
      verdictTitle = '✅ WITHIN BUDGET: APPROVED';
      adviceText =
          "Great financial discipline, $userName! '$item' ($costDisplay) is well within your spending allocation. You will still have ${AppTheme.formatCurrency(projectedBalance)} left (${AppTheme.formatCurrency(newDaily)}/day) for the rest of the month.";
      whyNot =
          "• Financial Health: Your upcoming commitments (${AppTheme.formatCurrency(upcomingPlannedTotal)}) and loan obligations (${AppTheme.formatCurrency(totalMonthlyLoans)}) are comfortably buffered.\n"
          "• Guilt-Free: Since this is planned and affordable, you can purchase it with confidence!";
    }

    if (serverAdvice.isNotEmpty) {
      adviceText = "$adviceText\n\nAI Coach Note: $serverAdvice";
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isEvaluating = false;
      _hasResult = true;
      _evaluatedItem = item;
      _evaluatedCost = cost;
      _verdictType = vType;
      _verdict = verdictTitle;
      _aiAdvice = adviceText;
      _whyNotNeed = whyNot;
      _oldBalance = currentBalance;
      _newBalance = projectedBalance;
      _oldDailyAllowance = oldDaily;
      _newDailyAllowance = newDaily;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.fomoPurple, size: 24),
            SizedBox(width: 8),
            Text(
              "FOMO Advisor",
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroHero(),
            const SizedBox(height: 20),

            _buildInputCard(),
            const SizedBox(height: 24),

            if (_hasResult) ...[
              _buildEvaluationResultCard(),
              const SizedBox(height: 24),
            ],

            _buildFomoTrophyAndWishlist(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Icon(Icons.psychology_rounded, color: AppTheme.textPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Impulse Purchase Shield",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tell AI what you're tempted to buy. We will simulate the impact on your monthly budget and give you honest advice.",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What do you want to buy?",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          if (_inputErrorWhere != null && _inputErrorWhy != null) ...[
            BluppFieldError(where: _inputErrorWhere!, why: _inputErrorWhy!),
            const SizedBox(height: 14),
          ],

          TextField(
            controller: _itemController,
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: "e.g. Sony WH-1000XM5, Steam Deck, Dyson Airwrap, Nike Dunks",
              hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
              prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryTeal),
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
                  Icon(Icons.travel_explore_rounded, color: AppTheme.fomoPurple, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Price Currency",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _selectedCurrency != widget.state.baseCurrency
                      ? AppTheme.fomoPurple.withValues(alpha: 0.15)
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedCurrency != widget.state.baseCurrency
                        ? AppTheme.fomoPurple
                        : AppTheme.surfaceBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: AppTheme.surface,
                    isDense: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppTheme.fomoPurple),
                    style: TextStyle(
                      color: _selectedCurrency != widget.state.baseCurrency
                          ? AppTheme.fomoPurple
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
                        setState(() => _selectedCurrency = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: _selectedCurrency != widget.state.baseCurrency
                  ? "Price in $_selectedCurrency (Travel Currency)"
                  : "Price (${widget.state.baseCurrency})",
              hintText: "0.00 (e.g. 1,299.00)",
              hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
              labelStyle: TextStyle(color: AppTheme.textSecondary),
              prefixText: "${CurrencyManager.getCurrency(_selectedCurrency).symbol} ",
              prefixStyle: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_selectedCurrency != widget.state.baseCurrency &&
              (double.tryParse(_costController.text.trim()) ?? 0.0) > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.fomoPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.fomoPurple.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange_rounded, color: AppTheme.fomoPurple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Auto-Converted to Base (${widget.state.baseCurrency}):",
                          style: TextStyle(color: AppTheme.fomoPurple, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${CurrencyManager.format(double.tryParse(_costController.text.trim()) ?? 0.0, _selectedCurrency)} ≈ ${AppTheme.formatCurrency(CurrencyManager.convert(amount: double.tryParse(_costController.text.trim()) ?? 0.0, fromCode: _selectedCurrency, toCode: widget.state.baseCurrency))}",
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          Text(
            "What triggered this urge?",
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedUrgency,
            dropdownColor: AppTheme.surface,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _urgencyOptions.map((opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(
                  opt,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedUrgency = val);
              }
            },
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: AppTheme.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isEvaluating ? null : _evaluatePurchase,
              icon: _isEvaluating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: AppTheme.background, strokeWidth: 2),
                    )
                  : Icon(Icons.auto_awesome_rounded, color: AppTheme.background, size: 18),
              label: Text(
                _isEvaluating ? "Analyzing Budget & Psychology..." : "Evaluate with Blupp AI",
                style: TextStyle(
                  color: AppTheme.background,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationResultCard() {
    Color borderColor;
    if (_verdictType == 'danger') {
      borderColor = AppTheme.expenseCoral;
    } else if (_verdictType == 'warning') {
      borderColor = AppTheme.warningAmber;
    } else {
      borderColor = AppTheme.primaryTeal;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              _verdict,
              style: TextStyle(
                color: borderColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            _evaluatedItem,
            style: TextStyle(color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Cost: ${AppTheme.formatCurrency(_evaluatedCost)}",
            style: TextStyle(
              color: borderColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // New financial budget projection
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW FINANCIAL BUDGET PROJECTION",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProjectionCol(
                      "Current Spending Left",
                      AppTheme.formatCurrency(_oldBalance),
                      AppTheme.textSecondary,
                    ),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
                    _buildProjectionCol(
                      "New Balance Left",
                      AppTheme.formatCurrency(_newBalance),
                      _newBalance < 0 ? AppTheme.expenseCoral : AppTheme.primaryTeal,
                    ),
                  ],
                ),
                Divider(color: AppTheme.surfaceBorder, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProjectionCol(
                      "Old Daily Limit",
                      "${AppTheme.formatCurrency(_oldDailyAllowance)}/day",
                      AppTheme.textSecondary,
                    ),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
                    _buildProjectionCol(
                      "New Daily Limit",
                      "${AppTheme.formatCurrency(_newDailyAllowance)}/day",
                      _newDailyAllowance < 25 ? AppTheme.expenseCoral : AppTheme.warningAmber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_aiAdvice.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: borderColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiAdvice,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Why you did not need that
          Text(
            "AI Reality Check: Why You Might Not Need This",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _whyNotNeed,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action decisions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.savings_rounded, size: 18),
                  label: const Text(
                    "Resist & Save",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  onPressed: () {
                    widget.state.recordFomoAvoidance(
                      _evaluatedItem,
                      _evaluatedCost,
                      _selectedCategory,
                      _verdict,
                      _whyNotNeed,
                    );
                    setState(() {
                      _hasResult = false;
                      _itemController.clear();
                      _costController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("🎉 Awesome self-control! Added ${AppTheme.formatCurrency(_evaluatedCost)} to your saved streak!"),
                        backgroundColor: AppTheme.primaryTeal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.fomoPurple,
                    side: const BorderSide(color: AppTheme.fomoPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text(
                    "30-Day Wait",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  onPressed: () {
                    widget.state.addToWishlist(
                      _evaluatedItem,
                      _evaluatedCost,
                      _selectedCategory,
                      _verdict,
                      _whyNotNeed,
                    );
                    setState(() {
                      _hasResult = false;
                      _itemController.clear();
                      _costController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Added to 30-Day Cooldown Wishlist. See if you still need it in a month!"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: () {
                final bankId = widget.state.bankAccounts.isNotEmpty ? widget.state.bankAccounts.first.id : '';
                widget.state.addTransaction(TransactionItem(
                  id: 'tx_fomo_${DateTime.now().millisecondsSinceEpoch}',
                  title: _evaluatedItem,
                  amount: _evaluatedCost,
                  type: TransactionType.expense,
                  categoryId: 'shopping',
                  date: DateTime.now(),
                  bankAccountId: bankId,
                  note: 'Purchased after FOMO review',
                ));
                setState(() {
                  _hasResult = false;
                  _itemController.clear();
                  _costController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged expense of ${AppTheme.formatCurrency(_evaluatedCost)}. Net worth updated."),
                  ),
                );
              },
              child: Text(
                "I really need this (Log as Expense)",
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFomoTrophyAndWishlist() {
    final totalSaved = widget.state.totalFomoSaved;
    final wishlist = widget.state.fomoWishlist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Icon(Icons.military_tech_rounded, color: AppTheme.primaryTeal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MONEY SAVED FROM IMPULSE FOMO",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTheme.formatCurrency(totalSaved),
                      style: TextStyle(color: AppTheme.primaryTeal,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Saved by saying NO to unnecessary wants!",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          "30-Day Cooldown Wishlist",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        if (wishlist.isEmpty)
          BluppEmptyState(
            icon: Icons.timelapse_rounded,
            title: "Cooldown List is Empty",
            description: "Whenever you feel tempted by an impulse buy, evaluate it above and put it on cooldown to save money!",
            actionLabel: "Analyze Urge",
            onAction: () => FocusScope.of(context).unfocus(),
          )
        else
          ...wishlist.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return InteractiveCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.avoided
                          ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                          : AppTheme.fomoPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.avoided ? Icons.check_circle_outline : Icons.timelapse_rounded,
                      color: item.avoided ? AppTheme.primaryTeal : AppTheme.fomoPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
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
                          item.avoided ? "Avoided Impulse Buy" : "In 30-Day Waiting Room",
                          style: TextStyle(
                            color: item.avoided ? AppTheme.primaryTeal : AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppTheme.formatCurrency(item.cost),
                    style: TextStyle(color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Delete Button
                  InkWell(
                    onTap: () => _confirmDeleteWishlistItem(context, item),
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
                        Icons.delete_outline_rounded, color: AppTheme.expenseCoral,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 220.ms, delay: Duration(milliseconds: (30 * index).clamp(0, 300))).slideY(begin: 0.05, end: 0);
          }),
      ],
    );
  }

  void _confirmDeleteWishlistItem(BuildContext context, WishlistItem item) {
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
              "Delete Wishlist Item",
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete '${item.title}'?",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Cost: ${AppTheme.formatCurrency(item.cost)}\nStatus: ${item.avoided ? 'Avoided Impulse Buy' : 'In 30-Day Waiting Room'}\nThis will remove the item and synchronize with Supabase.",
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
              widget.state.deleteWishlistItem(item.id);
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
                        "Deleted '${item.title}' from wishlist",
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
}
