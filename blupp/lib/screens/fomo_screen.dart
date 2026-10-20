import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import '../widgets/blupp_states.dart';
import '../widgets/blupp_forms.dart';
import '../widgets/ai_devils_advocate_sheet.dart';
import '../widgets/gemini_api_key_dialog.dart';
import '../widgets/blupp_formatted_text.dart';
import '../services/gemini_service.dart';

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
  bool _isRealAiResult = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.state.baseCurrency;
    GeminiService.instance.addListener(_onGeminiUpdate);
  }

  @override
  void dispose() {
    GeminiService.instance.removeListener(_onGeminiUpdate);
    _itemController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _onGeminiUpdate() {
    if (mounted) setState(() {});
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
  int _regretScore = 75;
  double _workHoursNeeded = 0.0;
  double _tenYearCompoundCost = 0.0;
  List<Map<String, dynamic>> _aiRecommendations = [];

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

    final currentBalance = widget.state.spendingBalanceLeft;
    final projectedBalance = currentBalance - cost;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day).clamp(1, 31);

    final oldDaily = currentBalance / remainingDays;
    final newDaily = projectedBalance > 0 ? projectedBalance / remainingDays : 0.0;

    final monthlyIncome = widget.state.totalIncomeThisMonth > 0 ? widget.state.totalIncomeThisMonth : 4500.0;
    final hourlyWage = (monthlyIncome / 160.0).clamp(15.0, 500.0);
    final workHours = cost / hourlyWage;
    final compound10Yr = cost * pow(1.08, 10);

    // Call Real Google Gemini AI (or fallback to intelligent local engine)
    final evalResult = await GeminiService.instance.evaluateFomoPurchase(
      itemName: item,
      enteredCost: cost,
      selectedCurrency: _selectedCurrency,
      urgencyOption: _selectedUrgency,
      state: widget.state,
    );

    if (!mounted) return;

    setState(() {
      _isEvaluating = false;
      _hasResult = true;
      _isRealAiResult = evalResult.isRealAi;
      _evaluatedItem = item;
      _evaluatedCost = cost;
      _verdictType = evalResult.verdictType;
      _verdict = evalResult.verdictTitle;
      _aiAdvice = evalResult.adviceText;
      _whyNotNeed = evalResult.whyNotNeed;
      _oldBalance = currentBalance;
      _newBalance = projectedBalance;
      _oldDailyAllowance = oldDaily;
      _newDailyAllowance = newDaily;
      _regretScore = evalResult.regretScore;
      _workHoursNeeded = workHours;
      _tenYearCompoundCost = compound10Yr;
      _aiRecommendations = evalResult.recommendations.map((r) => {
        'title': r['title'] ?? '72-Hour Anti-FOMO Cooling Chamber',
        'tag': r['tag'] ?? 'Neuroscience Protocol',
        'icon': Icons.psychology_alt_rounded,
        'color': const Color(0xFF8B5CF6),
        'desc': r['desc'] ?? '',
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.fomoPurple, size: 24),
            const SizedBox(width: 8),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => GeminiApiKeyDialog.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: GeminiService.instance.hasApiKey
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: GeminiService.instance.hasApiKey
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: GeminiService.instance.hasApiKey
                          ? const Color(0xFF10B981)
                          : Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      GeminiService.instance.hasApiKey ? "Gemini AI" : "AI Config",
                      style: TextStyle(
                        color: GeminiService.instance.hasApiKey
                            ? const Color(0xFF10B981)
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroHero(),
            const SizedBox(height: 16),

            // Conversational AI Devil's Advocate Live Chat Banner
            _buildDevilsAdvocateHeroBanner(),
            const SizedBox(height: 20),

            _buildInputCard(),
            const SizedBox(height: 24),

            if (_hasResult) ...[
              _buildEvaluationResultCard(),
              const SizedBox(height: 24),
            ],

            _buildFomoTrophyAndWishlist(),
            const SizedBox(height: 110),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _verdict,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
              if (_isRealAiResult) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 12),
                      SizedBox(width: 4),
                      Text(
                        "Gemini AI",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
                    child: BluppFormattedText(
                      text: _aiAdvice,
                      baseStyle: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      accentColor: borderColor,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: BluppFormattedText(
              text: _whyNotNeed,
              baseStyle: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                height: 1.5,
              ),
              accentColor: AppTheme.fomoPurple,
            ),
          ),
          const SizedBox(height: 18),

          // --- AI PSYCHOMETRICS & TRUE COST DASHBOARD ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
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
                        const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFF00E5FF)),
                        const SizedBox(width: 6),
                        Text(
                          "AI PSYCHOMETRICS & CAPITAL METRICS",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (_regretScore > 65 ? AppTheme.expenseCoral : AppTheme.incomeMint).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$_regretScore% Regret Risk",
                        style: TextStyle(
                          color: _regretScore > 65 ? AppTheme.expenseCoral : AppTheme.incomeMint,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Metrics Columns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Labor Cost", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(
                            "${_workHoursNeeded.toStringAsFixed(1)} hrs",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text("of hard work", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppTheme.surfaceBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("10-Yr Compounding", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(
                            AppTheme.formatCurrency(_tenYearCompoundCost),
                            style: const TextStyle(color: Color(0xFF00D09C), fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text("if invested at 8%", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppTheme.surfaceBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Trigger Source", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(
                            _selectedUrgency.contains('/') ? _selectedUrgency.split('/').first.trim() : _selectedUrgency,
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text("Impulse Vector", style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- 4 AI STRATEGIC RECOMMENDATIONS ---
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text(
                "4 AI ACTIONABLE RECOMMENDATIONS",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ..._aiRecommendations.map((rec) {
            final color = rec['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(rec['icon'] as IconData, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                rec['title'] as String,
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rec['tag'] as String,
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rec['desc'] as String,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Interactive "Ask AI Devil's Advocate" Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00E5FF),
                side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.forum_rounded, size: 18),
              label: const Text(
                "Ask AI Devil's Advocate: Convince Me NOT to Buy",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              onPressed: () => _showAiDevilsAdvocateSheet(context),
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

  Widget _buildDevilsAdvocateHeroBanner() {
    return InkWell(
      onTap: () => _showAiDevilsAdvocateSheet(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: Color(0xFFA78BFA), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Talk Me Out of It",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "LIVE AI CHAT",
                          style: TextStyle(color: Color(0xFFA78BFA), fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Chat live with your AI Devil's Advocate to crush retail impulses.",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFA78BFA)),
          ],
        ),
      ),
    );
  }

  void _showAiDevilsAdvocateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AiDevilsAdvocateSheet(
          state: widget.state,
          initialItem: _evaluatedItem.isNotEmpty ? _evaluatedItem : null,
          initialPrice: _evaluatedCost > 0 ? _evaluatedCost : null,
        );
      },
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
