import 'package:flutter/material.dart';
import '../services/universal_image_picker/universal_image_picker.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'currency_model.dart';

enum TransactionType { expense, income }

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class BankAccount {
  final String id;
  final String name;
  final String accountNumber;
  double balance;
  final Color color;
  final IconData icon;

  BankAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.color,
    required this.icon,
  });
}

class InvestmentItem {
  final String id;
  final String name;
  final String institution;
  double balance;
  final double returnRateAnnual;
  final String notes;
  final IconData icon;
  final Color color;

  InvestmentItem({
    required this.id,
    required this.name,
    required this.institution,
    required this.balance,
    required this.returnRateAnnual,
    required this.notes,
    required this.icon,
    required this.color,
  });
}

class LoanItem {
  final String id;
  final String name;
  final String provider;
  double totalLoan;
  double remainingBalance;
  double monthlyInstallment;
  final int dueDayOfMonth;
  final IconData icon;
  final Color color;

  LoanItem({
    required this.id,
    required this.name,
    required this.provider,
    required this.totalLoan,
    required this.remainingBalance,
    required this.monthlyInstallment,
    required this.dueDayOfMonth,
    required this.icon,
    required this.color,
  });
}

class TransactionItem {
  final String id;
  final String title;
  double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String bankAccountId;
  final String? note;
  final bool isTransfer;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.bankAccountId,
    this.note,
    this.isTransfer = false,
  });
}

class PlannedExpense {
  final String id;
  final String title;
  double amount;
  final String categoryId;
  final DateTime date;
  final bool isRecurring;
  bool isPaid;
  final String? note;

  PlannedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.isRecurring = false,
    this.isPaid = false,
    this.note,
  });
}

class WishlistItem {
  final String id;
  final String title;
  double cost;
  final String categoryId;
  final DateTime addedDate;
  final String aiVerdict;
  final String aiReason;
  bool avoided;

  WishlistItem({
    required this.id,
    required this.title,
    required this.cost,
    required this.categoryId,
    required this.addedDate,
    required this.aiVerdict,
    required this.aiReason,
    this.avoided = false,
  });
}

class DailyExpenseGroup {
  final DateTime date;
  final double totalExpense;
  final List<TransactionItem> items;

  DailyExpenseGroup({
    required this.date,
    required this.totalExpense,
    required this.items,
  });

  String get label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groupDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(groupDay).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }
}

class WeeklyExpenseGroup {
  final int weekIndex;
  final DateTime startDate;
  final DateTime endDate;
  final double totalExpense;
  final List<double> dailySpending; // 7 days: Mon -> Sun
  final List<TransactionItem> items;

  WeeklyExpenseGroup({
    required this.weekIndex,
    required this.startDate,
    required this.endDate,
    required this.totalExpense,
    required this.dailySpending,
    required this.items,
  });

  String get label {
    if (weekIndex == 0) return "This Week";
    if (weekIndex == 1) return "Last Week";
    return "$weekIndex Weeks Ago";
  }

  String get dateRangeFormatted {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${startDate.day} ${months[startDate.month - 1]} – ${endDate.day} ${months[endDate.month - 1]}";
  }
}

class MonthlyExpenseGroup {
  final int year;
  final int month;
  final double totalExpense;
  final Map<String, double> categoryBreakdown;
  final List<TransactionItem> items;

  MonthlyExpenseGroup({
    required this.year,
    required this.month,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.items,
  });

  String get label {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[month - 1]} $year";
  }
}

class AiFinancialDiagnosis {
  final String archetype;
  final String title;
  final String subtitle;
  final String confidence;
  final String diagnosisSummary;
  final List<String> traits;
  final String levelUpAction;
  final Color badgeColor;
  final IconData icon;

  const AiFinancialDiagnosis({
    required this.archetype,
    required this.title,
    required this.subtitle,
    required this.confidence,
    required this.diagnosisSummary,
    required this.traits,
    required this.levelUpAction,
    required this.badgeColor,
    required this.icon,
  });
}

enum BurnRadarZone { safe, caution, over }

class AiSafeToSpendRadar {
  final double safeDailyAllowance;
  final double spentToday;
  final double safeBufferRemainingToday;
  final int daysRemainingInMonth;
  final double upcomingCommittedSpending;
  final double uncommittedLiquidPool;
  final BurnRadarZone zone;
  final double projectedMonthEndSurplus;
  final String statusHeadline;
  final String statusAdvice;
  final Color zoneColor;
  final IconData zoneIcon;

  const AiSafeToSpendRadar({
    required this.safeDailyAllowance,
    required this.spentToday,
    required this.safeBufferRemainingToday,
    required this.daysRemainingInMonth,
    required this.upcomingCommittedSpending,
    required this.uncommittedLiquidPool,
    required this.zone,
    required this.projectedMonthEndSurplus,
    required this.statusHeadline,
    required this.statusAdvice,
    required this.zoneColor,
    required this.zoneIcon,
  });
}

class FinanceState extends ChangeNotifier {
  // Authentication & Profile State
  bool _isAuthenticated = false;
  String _userName = 'Airiel';
  String _userEmail = 'airiel@blupp.ai';
  String _userPhone = '+60 12-345 6789';
  final bool _isVerified = true;
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = true;
  bool _isAuthLoading = false;
  String? _authError;

  FinanceState({bool? initialAuthenticated}) {
    if (initialAuthenticated != null) {
      _isAuthenticated = initialAuthenticated;
      if (initialAuthenticated) {
        loadDemoData();
      }
    } else if (SupabaseService.instance.hasActiveSession) {
      _isAuthenticated = true;
      final user = SupabaseService.instance.currentUser;
      if (user != null) {
        _userEmail = user.email ?? _userEmail;
        final name = user.userMetadata?['full_name'];
        if (name is String && name.isNotEmpty) {
          _userName = name;
        } else if (user.email != null) {
          _userName = user.email!.split('@').first;
        }
      }
    } else {
      _isAuthenticated = false;
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  bool get isVerified => _isVerified;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isAuthLoading => _isAuthLoading;
  String? get authError => _authError;

  // Privacy & Presentation State (Hidden by default as requested)
  bool _isNetWorthHidden = true;
  bool get isNetWorthHidden => _isNetWorthHidden;

  void toggleNetWorthVisibility() {
    _isNetWorthHidden = !_isNetWorthHidden;
    notifyListeners();
  }

  // Profile Picture (Custom Gallery Upload or Default)
  String? _profileImageBase64;
  String? get profileImageBase64 => _profileImageBase64;
  bool get hasCustomProfileImage => _profileImageBase64 != null && _profileImageBase64!.isNotEmpty;

  void setProfileImage(String? base64Str) {
    _profileImageBase64 = base64Str;
    notifyListeners();
    SupabaseService.instance.updateUserProfileImage(base64Str);
  }

  Future<bool> pickProfilePictureFromGallery() async {
    try {
      final img = await UniversalImagePicker.pickImage(isCamera: false);
      if (img != null && img.base64String.isNotEmpty) {
        setProfileImage(img.base64String);
        return true;
      }
    } catch (e) {
      debugPrint('[FinanceState] Error picking profile image: $e');
    }
    return false;
  }

  Future<bool> pickProfilePictureFromCamera() async {
    try {
      final img = await UniversalImagePicker.pickImage(isCamera: true);
      if (img != null && img.base64String.isNotEmpty) {
        setProfileImage(img.base64String);
        return true;
      }
    } catch (e) {
      debugPrint('[FinanceState] Error taking photo from camera: $e');
    }
    return false;
  }

  void removeProfilePicture() {
    setProfileImage(null);
  }

  // --- AI-ASSIGNED FINANCIAL IDENTITY ENGINE ---
  bool _isAiAnalyzingPersona = false;
  bool get isAiAnalyzingPersona => _isAiAnalyzingPersona;

  AiFinancialDiagnosis get aiDiagnosis {
    final savings = savingsRatePercentage;
    final budgetUsed = budgetUsedPercentage;
    final hasInvestments = _investments.isNotEmpty;
    final totalInv = totalInvestmentsAndSavings;
    final totalDebt = totalLoans;
    final fomoProtected = totalFomoSaved;
    final fomoCount = _fomoWishlist.where((w) => w.avoided).length;
    final netWorth = totalNetWorth;

    if (savings >= 35 && hasInvestments && totalDebt == 0) {
      return AiFinancialDiagnosis(
        archetype: '⚡ High-Yield Wealth Accelerator',
        title: 'High-Yield Wealth Accelerator',
        subtitle: 'Aggressive Capital Compounding & Zero Toxic Debt',
        confidence: '96% AI Match',
        diagnosisSummary:
            'Blupp AI detected an outstanding ${savings.toStringAsFixed(1)}% savings rate, active diversified asset portfolios (${AppTheme.formatCurrency(totalInv)}), and zero debt liabilities. You are compounding capital at top-tier institutional velocity.',
        traits: [
          '${savings.toStringAsFixed(0)}% Savings Rate',
          'Zero Consumer Debt',
          'Active Asset Compounding',
          'Disciplined Cash Flow',
        ],
        levelUpAction:
            'Automate monthly contributions into broad-market index funds to sustain generational compounding velocity.',
        badgeColor: const Color(0xFF10B981),
        icon: Icons.bolt_rounded,
      );
    } else if (fomoCount >= 2 && budgetUsed <= 75) {
      return AiFinancialDiagnosis(
        archetype: '🛡️ Disciplined Saver & FOMO Shield',
        title: 'Disciplined Saver & FOMO Shield',
        subtitle: 'Impulse Defense & High Cashflow Protection',
        confidence: '94% AI Match',
        diagnosisSummary:
            'AI Neural Analysis identified superior psychological resistance against retail impulses. You have shielded ${AppTheme.formatCurrency(fomoProtected)} from impulsive buying while keeping budget usage under ${budgetUsed.toStringAsFixed(0)}%.',
        traits: [
          '${AppTheme.formatCurrency(fomoProtected)} Impulses Blocked',
          '${(100 - budgetUsed).clamp(0, 100).toStringAsFixed(0)}% Budget Intact',
          'Emotion-Free Purchasing',
          'High Spending Cushion',
        ],
        levelUpAction:
            'Channel at least 50% of money saved from avoided FOMO purchases directly into a high-yield investment account.',
        badgeColor: const Color(0xFF00E5FF),
        icon: Icons.shield_rounded,
      );
    } else if (hasInvestments && totalInv >= netWorth * 0.35 && netWorth > 1000) {
      return AiFinancialDiagnosis(
        archetype: '💎 Diamond Hands Compounding Sovereign',
        title: 'Diamond Hands Compounding Sovereign',
        subtitle: 'Long-Term Yield Maximalist & Asset Accumulator',
        confidence: '95% AI Match',
        diagnosisSummary:
            'AI identifies high long-term investment conviction. Over ${(totalInv / (netWorth > 0 ? netWorth : 1) * 100).toStringAsFixed(0)}% of your balance sheet is invested in dividend/growth assets rather than sitting dormant in low-yield cash.',
        traits: [
          '${_investments.length} Portfolios Active',
          'Long-Term Conviction',
          'Anti-Inflation Allocation',
          'Passive Yield Compounder',
        ],
        levelUpAction:
            'Rebalance asset allocation bi-annually and maintain an emergency cash buffer of at least 3-6 months living expenses.',
        badgeColor: const Color(0xFF8B5CF6),
        icon: Icons.diamond_rounded,
      );
    } else if (budgetUsed <= 60 && totalExpensesThisMonth > 0) {
      return AiFinancialDiagnosis(
        archetype: '🌿 Mindful Minimalist & Cash Optimizer',
        title: 'Mindful Minimalist & Cash Optimizer',
        subtitle: 'Lean Cost Footprint & Intentional Spending',
        confidence: '92% AI Match',
        diagnosisSummary:
            'Your expenditure footprint is exceptionally lean, utilizing only ${budgetUsed.toStringAsFixed(0)}% of your monthly allowance. You prioritize value and essential utilities over frivolous consumer consumption.',
        traits: [
          'Lean Overhead Cost',
          'High Monthly Surplus',
          'Zero Lifestyle Inflation',
          'Essentialist Mindset',
        ],
        levelUpAction:
            'Put your substantial monthly cash surplus into automated recurring investments to let compounding work for you.',
        badgeColor: const Color(0xFF14B8A6),
        icon: Icons.spa_rounded,
      );
    } else if (totalDebt > 0) {
      return AiFinancialDiagnosis(
        archetype: '🎯 Tactical Debt Eliminator & Rebuilder',
        title: 'Tactical Debt Eliminator & Rebuilder',
        subtitle: 'Structured Liability Payoff & Solvency Expansion',
        confidence: '91% AI Match',
        diagnosisSummary:
            'AI observes focused repayment management across ${_loans.length} active loan obligations (${AppTheme.formatCurrency(totalDebt)} balance). You are maintaining positive monthly liquidity while shrinking liabilities.',
        traits: [
          '${_loans.length} Active Obligations Tracked',
          'Avalanche/Snowball Strategy',
          'Controlled Overhead',
          'Net Worth Turnaround',
        ],
        levelUpAction:
            'Apply any unexpected bonus or side-income directly towards your highest APR loan to accelerate zero-debt graduation.',
        badgeColor: const Color(0xFFF59E0B),
        icon: Icons.track_changes_rounded,
      );
    } else {
      return AiFinancialDiagnosis(
        archetype: '🌱 Foundation Wealth Builder',
        title: 'Foundation Wealth Builder',
        subtitle: 'Building Liquidity Moat & Tracking Mastery',
        confidence: '89% AI Match',
        diagnosisSummary:
            'You are establishing rock-solid personal finance fundamentals. Blupp AI is actively tracking your cash inflows, bank accounts, and daily expenses to calculate your compounding potential.',
        traits: [
          'Active Expense Tracking',
          'Growing Liquid Cushion',
          'Financial Literacy Growth',
          'Positive Net Trajectory',
        ],
        levelUpAction:
            'Aim to save at least 20% of your next incoming salary before spending on discretionary items.',
        badgeColor: const Color(0xFF38BDF8),
        icon: Icons.eco_rounded,
      );
    }
  }

  String get userPersona => aiDiagnosis.archetype;

  Future<void> refreshAiPersona() async {
    _isAiAnalyzingPersona = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1200));
    _isAiAnalyzingPersona = false;
    notifyListeners();
  }

  // --- AI SAFE-TO-SPEND RADAR ENGINE ---
  int get daysRemainingInMonth {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return (lastDay - now.day + 1).clamp(1, 31);
  }

  double get upcomingCommittedExpensesThisMonth {
    final now = DateTime.now();
    final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _plannedExpenses
        .where((p) =>
            !p.isPaid &&
            !p.date.isBefore(startOfTomorrow) &&
            !p.date.isAfter(endOfMonth))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  AiSafeToSpendRadar get aiSafeToSpendRadar {
    final days = daysRemainingInMonth;
    final committed = upcomingCommittedExpensesThisMonth;
    final liquidPool = (spendingBalanceLeft - committed).clamp(0.0, double.infinity);
    final safeDaily = days > 0 ? (liquidPool / days) : 0.0;
    final spentToday = todayExpenseTotal;
    final bufferRemaining = safeDaily - spentToday;

    BurnRadarZone zone;
    Color zoneColor;
    IconData zoneIcon;
    String statusHeadline;
    String statusAdvice;

    // Projected Month-End: based on current spending rate
    final daysPassed = DateTime.now().day;
    final avgDailyBurn = daysPassed > 0 ? (totalExpensesThisMonth / daysPassed) : safeDaily;
    final projectedMonthEndSurplus = (monthlySpendingBudget - (avgDailyBurn * 30)).clamp(-999999.0, double.infinity);

    if (bufferRemaining > safeDaily * 0.25 || (safeDaily == 0 && spentToday == 0)) {
      zone = BurnRadarZone.safe;
      zoneColor = const Color(0xFF10B981); // Emerald
      zoneIcon = Icons.shield_rounded;
      statusHeadline = "Smooth Sailing";
      statusAdvice = "You have ${AppTheme.formatCurrency(bufferRemaining > 0 ? bufferRemaining : 0.0)} safe buffer left for today. Keep this pace to finish with a liquid surplus.";
    } else if (bufferRemaining >= 0) {
      zone = BurnRadarZone.caution;
      zoneColor = const Color(0xFFF59E0B); // Amber
      zoneIcon = Icons.speed_rounded;
      statusHeadline = "Caution";
      statusAdvice = "Only ${AppTheme.formatCurrency(bufferRemaining)} buffer remaining today. Delay non-essential purchases until tomorrow.";
    } else {
      zone = BurnRadarZone.over;
      zoneColor = const Color(0xFFEF4444); // Crimson Red
      zoneIcon = Icons.local_fire_department_rounded;
      statusHeadline = "Burn Overdrive";
      statusAdvice = "Today's spending surpassed radar by ${AppTheme.formatCurrency(bufferRemaining.abs())}. AI recommends a zero-spend day tomorrow to rebalance your runway.";
    }

    return AiSafeToSpendRadar(
      safeDailyAllowance: safeDaily,
      spentToday: spentToday,
      safeBufferRemainingToday: bufferRemaining,
      daysRemainingInMonth: days,
      upcomingCommittedSpending: committed,
      uncommittedLiquidPool: liquidPool,
      zone: zone,
      projectedMonthEndSurplus: projectedMonthEndSurplus,
      statusHeadline: statusHeadline,
      statusAdvice: statusAdvice,
      zoneColor: zoneColor,
      zoneIcon: zoneIcon,
    );
  }

  // Avatar Studio Customization
  String _avatarType = 'preset'; // 'image', 'preset', 'monogram'
  String get avatarType => hasCustomProfileImage ? 'image' : _avatarType;

  int _avatarPresetIndex = 0;
  int get avatarPresetIndex => _avatarPresetIndex;

  int _monogramColorIndex = 0;
  int get monogramColorIndex => _monogramColorIndex;

  static const List<Map<String, dynamic>> characterAvatarPresets = [
    {
      'id': 'dolphin',
      'name': 'Blupp Dolphin',
      'subtitle': 'Agile & Intelligent',
      'icon': Icons.bubble_chart_rounded,
      'colors': [Color(0xFF00E5FF), Color(0xFF00897B)],
    },
    {
      'id': 'shark',
      'name': 'Apex Shark',
      'subtitle': 'Market Predator',
      'icon': Icons.sailing_rounded,
      'colors': [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    },
    {
      'id': 'lion',
      'name': 'Wealth Lion',
      'subtitle': 'King of Capital',
      'icon': Icons.military_tech_rounded,
      'colors': [Color(0xFFF59E0B), Color(0xFFB45309)],
    },
    {
      'id': 'bull',
      'name': 'Market Bull',
      'subtitle': 'Unstoppable Momentum',
      'icon': Icons.trending_up_rounded,
      'colors': [Color(0xFF10B981), Color(0xFF047857)],
    },
    {
      'id': 'diamond',
      'name': 'Diamond Hands',
      'subtitle': 'Unwavering Conviction',
      'icon': Icons.diamond_rounded,
      'colors': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    },
    {
      'id': 'crown',
      'name': 'Financial Sovereign',
      'subtitle': 'Independent & Sovereign',
      'icon': Icons.workspace_premium_rounded,
      'colors': [Color(0xFFFFD700), Color(0xFFD97706)],
    },
    {
      'id': 'falcon',
      'name': 'Falcon Vision',
      'subtitle': 'Sharp Strategic Eyes',
      'icon': Icons.flight_takeoff_rounded,
      'colors': [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
    },
    {
      'id': 'phoenix',
      'name': 'Fire Phoenix',
      'subtitle': 'Resilient Compounding',
      'icon': Icons.local_fire_department_rounded,
      'colors': [Color(0xFFFF5722), Color(0xFFBE123C)],
    },
    {
      'id': 'robot',
      'name': 'AI Cyborg',
      'subtitle': 'Algorithmic Precision',
      'icon': Icons.smart_toy_rounded,
      'colors': [Color(0xFF14B8A6), Color(0xFF4F46E5)],
    },
    {
      'id': 'fox',
      'name': 'Tactical Fox',
      'subtitle': 'Resourceful & Savvy',
      'icon': Icons.psychology_rounded,
      'colors': [Color(0xFFFB923C), Color(0xFFC2410C)],
    },
    {
      'id': 'owl',
      'name': 'Wise Owl',
      'subtitle': 'Long-term Thinker',
      'icon': Icons.visibility_rounded,
      'colors': [Color(0xFF6366F1), Color(0xFF312E81)],
    },
    {
      'id': 'rocket',
      'name': 'Crypto Pioneer',
      'subtitle': 'Hyper-Growth Hunter',
      'icon': Icons.rocket_launch_rounded,
      'colors': [Color(0xFFEC4899), Color(0xFF9D174D)],
    },
  ];

  static const List<Map<String, dynamic>> monogramGradients = [
    {'name': 'Emerald Mint', 'colors': [Color(0xFF00D09C), Color(0xFF00897B)]},
    {'name': 'Electric Cyan', 'colors': [Color(0xFF00E5FF), Color(0xFF0284C7)]},
    {'name': 'Cosmic Purple', 'colors': [Color(0xFFA855F7), Color(0xFF6366F1)]},
    {'name': 'Sunset Amber', 'colors': [Color(0xFFF59E0B), Color(0xFFEA580C)]},
    {'name': 'Neon Rose', 'colors': [Color(0xFFF43F5E), Color(0xFFE11D48)]},
    {'name': 'Ocean Blue', 'colors': [Color(0xFF3B82F6), Color(0xFF1D4ED8)]},
    {'name': 'Cyber Indigo', 'colors': [Color(0xFF6366F1), Color(0xFF1E1B4B)]},
    {'name': 'Titanium Slate', 'colors': [Color(0xFF475569), Color(0xFF0F172A)]},
  ];

  void setAvatarPreset(int index) {
    if (index >= 0 && index < characterAvatarPresets.length) {
      _avatarType = 'preset';
      _avatarPresetIndex = index;
      _profileImageBase64 = null;
      notifyListeners();
      SupabaseService.instance.updateUserProfileImage(null);
    }
  }

  void setMonogram(int colorIndex) {
    if (colorIndex >= 0 && colorIndex < monogramGradients.length) {
      _avatarType = 'monogram';
      _monogramColorIndex = colorIndex;
      _profileImageBase64 = null;
      notifyListeners();
      SupabaseService.instance.updateUserProfileImage(null);
    }
  }

  // --- FINANCIAL PERFORMANCE & STATISTICS ---
  int get financialHealthScore {
    int score = 0;
    final totalAssets = totalBankBalance + totalInvestmentsAndSavings;
    final totalDebt = totalLoans;

    // 1. Debt-to-Asset ratio (up to 35 pts)
    if (totalDebt <= 0) {
      score += 35;
    } else {
      final ratio = totalAssets / totalDebt;
      if (ratio >= 3.0) {
        score += 35;
      } else if (ratio >= 2.0) {
        score += 28;
      } else if (ratio >= 1.2) {
        score += 20;
      } else {
        score += 10;
      }
    }

    // 2. Budget Discipline (up to 35 pts)
    if (_monthlySpendingBudget > 0) {
      final budgetRemainingRatio = spendingBalanceLeft / _monthlySpendingBudget;
      if (budgetRemainingRatio >= 0.5) {
        score += 35;
      } else if (budgetRemainingRatio >= 0.25) {
        score += 26;
      } else if (budgetRemainingRatio > 0) {
        score += 18;
      } else {
        score += 5;
      }
    } else {
      score += 30;
    }

    // 3. Asset & Savings Buffer (up to 30 pts)
    final buffer = _monthlySpendingBudget > 0 ? totalAssets / _monthlySpendingBudget : totalAssets / 1000;
    if (buffer >= 5.0) {
      score += 30;
    } else if (buffer >= 2.5) {
      score += 22;
    } else if (buffer >= 1.0) {
      score += 15;
    } else {
      score += 8;
    }

    return score.clamp(0, 100);
  }

  String get financialHealthGrade {
    final s = financialHealthScore;
    if (s >= 90) return 'A+ Sovereign';
    if (s >= 80) return 'A Excellent';
    if (s >= 70) return 'B+ Strong';
    if (s >= 60) return 'B Steady';
    return 'C Focused';
  }

  double get savingsRatePercentage {
    if (totalIncomeThisMonth <= 0) return 0.0;
    final netSaved = totalIncomeThisMonth - totalExpensesThisMonth;
    return ((netSaved / totalIncomeThisMonth) * 100).clamp(0.0, 100.0);
  }

  double get budgetUsedPercentage {
    if (_monthlySpendingBudget <= 0) return 0.0;
    return ((totalExpensesThisMonth / _monthlySpendingBudget) * 100).clamp(0.0, 100.0);
  }

  double get assetToDebtRatio {
    if (totalLoans <= 0) return 99.9;
    return (totalBankBalance + totalInvestmentsAndSavings) / totalLoans;
  }

  // Loading & Error State for Skeletons
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Future<void> refreshData() async {
    _isRefreshing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750));
    _isRefreshing = false;
    notifyListeners();
  }

  // Theme & Currency Settings
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String _baseCurrency = 'MYR';
  String get baseCurrency => _baseCurrency;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    AppTheme.isDark = (mode == ThemeMode.dark);
    notifyListeners();
  }

  /// Automatically converts all stored money values when changing currency in settings
  void setBaseCurrency(String code) {
    final newCode = code.toUpperCase();
    final oldCode = _baseCurrency.toUpperCase();
    if (oldCode == newCode) return;

    if (_monthlySpendingBudget > 0) {
      _monthlySpendingBudget = CurrencyManager.convert(
        amount: _monthlySpendingBudget,
        fromCode: oldCode,
        toCode: newCode,
      );
      SupabaseService.instance.updateMonthlyBudget(_monthlySpendingBudget);
    }

    for (final bank in _bankAccounts) {
      bank.balance = CurrencyManager.convert(
        amount: bank.balance,
        fromCode: oldCode,
        toCode: newCode,
      );
      SupabaseService.instance.updateBankBalance(bank.id, bank.balance);
    }

    for (final tx in _transactions) {
      tx.amount = CurrencyManager.convert(
        amount: tx.amount,
        fromCode: oldCode,
        toCode: newCode,
      );
    }

    for (final inv in _investments) {
      inv.balance = CurrencyManager.convert(
        amount: inv.balance,
        fromCode: oldCode,
        toCode: newCode,
      );
    }

    for (final loan in _loans) {
      loan.totalLoan = CurrencyManager.convert(
        amount: loan.totalLoan,
        fromCode: oldCode,
        toCode: newCode,
      );
      loan.remainingBalance = CurrencyManager.convert(
        amount: loan.remainingBalance,
        fromCode: oldCode,
        toCode: newCode,
      );
      loan.monthlyInstallment = CurrencyManager.convert(
        amount: loan.monthlyInstallment,
        fromCode: oldCode,
        toCode: newCode,
      );
      SupabaseService.instance.updateLoanBalance(loan.id, loan.remainingBalance);
    }

    for (final plan in _plannedExpenses) {
      plan.amount = CurrencyManager.convert(
        amount: plan.amount,
        fromCode: oldCode,
        toCode: newCode,
      );
    }

    for (final wish in _fomoWishlist) {
      wish.cost = CurrencyManager.convert(
        amount: wish.cost,
        fromCode: oldCode,
        toCode: newCode,
      );
    }

    if (_totalFomoSaved > 0) {
      _totalFomoSaved = CurrencyManager.convert(
        amount: _totalFomoSaved,
        fromCode: oldCode,
        toCode: newCode,
      );
    }

    _baseCurrency = newCode;
    AppTheme.activeCurrencyCode = _baseCurrency;
    notifyListeners();
  }

  // Base Monthly Spending Budget allocated by the user (starts 0 for new users)
  double _monthlySpendingBudget = 0.00;

  // Banks list - empty for clean slate upon new user sign in
  final List<BankAccount> _bankAccounts = [];

  // Investments & Savings - empty for clean slate
  final List<InvestmentItem> _investments = [];

  // Loans & Liabilities - empty for clean slate
  final List<LoanItem> _loans = [];

  // Categories
  final List<CategoryItem> _categories = [
    // Expenses
    const CategoryItem(
      id: 'bank_transfer',
      name: 'Bank Transfer & Top-Up',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF00B4D8),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'withdrawal',
      name: 'Cash & Withdrawal',
      icon: Icons.money_off_rounded,
      color: Color(0xFFFF922B),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6B6B),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'transport',
      name: 'Transport & Petrol',
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFF4D96FF),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'shopping',
      name: 'Shopping & E-Commerce',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFF76AC),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'utilities',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF9D4EDD),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'entertainment',
      name: 'Entertainment & Subs',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFF6C5CE7),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'groceries',
      name: 'Groceries & Market',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFFFFAA00),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'health',
      name: 'Health & Pharmacy',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF00B894),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'loan_repay',
      name: 'ShopeePay & Loan Repayment',
      icon: Icons.payments_rounded,
      color: Color(0xFFFF5252),
      type: TransactionType.expense,
    ),
    const CategoryItem(
      id: 'other_exp',
      name: 'Other Expense',
      icon: Icons.category_rounded,
      color: Color(0xFF78909C),
      type: TransactionType.expense,
    ),

    // Incomes
    const CategoryItem(
      id: 'salary',
      name: 'Monthly Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF00D09C),
      type: TransactionType.income,
    ),
    const CategoryItem(
      id: 'freelance',
      name: 'Freelance & Side Hustle',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF00B4D8),
      type: TransactionType.income,
    ),
    const CategoryItem(
      id: 'dividend',
      name: 'Investment & Dividends',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF55E6C1),
      type: TransactionType.income,
    ),
    const CategoryItem(
      id: 'bonus',
      name: 'Bonus & Cashback',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFFFC048),
      type: TransactionType.income,
    ),
  ];

  // Transactions list - empty for clean slate
  final List<TransactionItem> _transactions = [];

  // Planned Expenses (for Calendar Planner) - empty for clean slate
  final List<PlannedExpense> _plannedExpenses = [];

  // FOMO Wishlist & Avoided Purchases - empty for clean slate
  final List<WishlistItem> _fomoWishlist = [];

  // Total amount saved by saying NO to FOMO
  double _totalFomoSaved = 0.00;

  /// Completely clears all user data for fresh user accounts or sign outs
  void clearAllData() {
    _bankAccounts.clear();
    _investments.clear();
    _loans.clear();
    _transactions.clear();
    _plannedExpenses.clear();
    _fomoWishlist.clear();
    _totalFomoSaved = 0.00;
    _monthlySpendingBudget = 0.00;
    _profileImageBase64 = null;
    notifyListeners();
  }

  /// Explicitly loads sample data only when Demo Mode is clicked
  void loadDemoData() {
    _monthlySpendingBudget = 3200.00;
    _bankAccounts.clear();
    _bankAccounts.addAll([
      BankAccount(
        id: 'mb_1',
        name: 'Maybank',
        accountNumber: '•••• 8921',
        balance: 4250.00,
        color: const Color(0xFFFFB800),
        icon: Icons.account_balance,
      ),
      BankAccount(
        id: 'cimb_1',
        name: 'CIMB Bank',
        accountNumber: '•••• 4310',
        balance: 2180.50,
        color: const Color(0xFFE53935),
        icon: Icons.account_balance,
      ),
      BankAccount(
        id: 'bi_1',
        name: 'Bank Islam',
        accountNumber: '•••• 6742',
        balance: 1450.00,
        color: const Color(0xFF00897B),
        icon: Icons.account_balance,
      ),
    ]);

    _investments.clear();
    _investments.addAll([
      InvestmentItem(
        id: 'asnb_1',
        name: 'ASNB (Amanah Saham Bumiputera)',
        institution: 'Permodalan Nasional Berhad',
        balance: 15400.00,
        returnRateAnnual: 5.25,
        notes: 'Monthly auto-deduct RM 300',
        icon: Icons.savings_rounded,
        color: const Color(0xFF00C48C),
      ),
      InvestmentItem(
        id: 'stash_1',
        name: 'StashAway General Investing',
        institution: 'StashAway Malaysia',
        balance: 3850.00,
        returnRateAnnual: 7.40,
        notes: 'High growth portfolio',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF7C4DFF),
      ),
      InvestmentItem(
        id: 'th_1',
        name: 'Tabung Haji Savings',
        institution: 'Lembaga Tabung Haji',
        balance: 4500.00,
        returnRateAnnual: 3.10,
        notes: 'Emergency reserve fund',
        icon: Icons.shield_rounded,
        color: const Color(0xFF009688),
      ),
    ]);

    _loans.clear();
    _loans.addAll([
      LoanItem(
        id: 'spay_1',
        name: 'ShopeePay Later (SPayLater)',
        provider: 'SeaMoney Malaysia',
        totalLoan: 650.00,
        remainingBalance: 390.00,
        monthlyInstallment: 130.00,
        dueDayOfMonth: 10,
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFFEE4D2D),
      ),
      LoanItem(
        id: 'car_1',
        name: 'Transport / Car Loan',
        provider: 'Maybank Hire Purchase',
        totalLoan: 36000.00,
        remainingBalance: 16800.00,
        monthlyInstallment: 520.00,
        dueDayOfMonth: 5,
        icon: Icons.directions_car_rounded,
        color: const Color(0xFF3B82F6),
      ),
      LoanItem(
        id: 'grab_1',
        name: 'Grab PayLater',
        provider: 'Grab Financial Services',
        totalLoan: 320.00,
        remainingBalance: 180.00,
        monthlyInstallment: 90.00,
        dueDayOfMonth: 18,
        icon: Icons.electric_scooter_rounded,
        color: const Color(0xFF00B14F),
      ),
    ]);

    _transactions.clear();
    _transactions.addAll([
      TransactionItem(
        id: 'tx_1',
        title: 'Groceries at Jaya Grocer',
        amount: 145.80,
        type: TransactionType.expense,
        categoryId: 'groceries',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        bankAccountId: 'mb_1',
        note: 'Weekly essentials & fresh veggies',
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Shell Fuel V-Power',
        amount: 65.00,
        type: TransactionType.expense,
        categoryId: 'transport',
        date: DateTime.now().subtract(const Duration(days: 1)),
        bankAccountId: 'mb_1',
        note: 'Full tank',
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'ShopeePay SPayLater Installment',
        amount: 130.00,
        type: TransactionType.expense,
        categoryId: 'loan_repay',
        date: DateTime.now().subtract(const Duration(days: 2)),
        bankAccountId: 'cimb_1',
        note: 'Monthly gadget installment',
      ),
      TransactionItem(
        id: 'tx_4',
        title: 'Nasi Lemak & Kopi Tealive',
        amount: 28.50,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        bankAccountId: 'cimb_1',
        note: 'Lunch with colleagues',
      ),
      TransactionItem(
        id: 'tx_5',
        title: 'Uniqlo Airism T-Shirts',
        amount: 119.00,
        type: TransactionType.expense,
        categoryId: 'shopping',
        date: DateTime.now().subtract(const Duration(days: 3)),
        bankAccountId: 'bi_1',
        note: 'Weekend shopping',
      ),
      TransactionItem(
        id: 'tx_6',
        title: 'Freelance UI Design Project',
        amount: 850.00,
        type: TransactionType.income,
        categoryId: 'freelance',
        date: DateTime.now().subtract(const Duration(days: 4)),
        bankAccountId: 'mb_1',
        note: 'Milestone 2 payment',
      ),
      TransactionItem(
        id: 'tx_7',
        title: 'Netflix & Spotify Subs',
        amount: 68.00,
        type: TransactionType.expense,
        categoryId: 'entertainment',
        date: DateTime.now().subtract(const Duration(days: 5)),
        bankAccountId: 'cimb_1',
        note: 'Family plan auto-debit',
      ),
      TransactionItem(
        id: 'tx_8',
        title: 'TNB Electric & Air Selangor',
        amount: 142.30,
        type: TransactionType.expense,
        categoryId: 'utilities',
        date: DateTime.now().subtract(const Duration(days: 6)),
        bankAccountId: 'mb_1',
        note: 'Monthly condo utility bills',
      ),
    ]);

    _plannedExpenses.clear();
    _plannedExpenses.addAll([
      PlannedExpense(
        id: 'plan_1',
        title: 'Car Service & Engine Oil',
        amount: 280.00,
        categoryId: 'transport',
        date: DateTime.now().add(const Duration(days: 2)),
        note: '10,000km scheduled maintenance',
      ),
      PlannedExpense(
        id: 'plan_2',
        title: 'Shopee 10.10 Wishlist Checkout',
        amount: 150.00,
        categoryId: 'shopping',
        date: DateTime.now().add(const Duration(days: 4)),
        note: 'Voucher sales checkout',
      ),
      PlannedExpense(
        id: 'plan_3',
        title: 'Car Loan EMI Monthly',
        amount: 520.00,
        categoryId: 'loan_repay',
        date: DateTime.now().add(const Duration(days: 6)),
        isRecurring: true,
        note: 'Auto debit Maybank HP',
      ),
      PlannedExpense(
        id: 'plan_4',
        title: 'Unifi High Speed Wifi Bill',
        amount: 139.00,
        categoryId: 'utilities',
        date: DateTime.now().add(const Duration(days: 9)),
        note: 'Monthly internet bill',
      ),
      PlannedExpense(
        id: 'plan_5',
        title: 'Weekend Groceries at Village Grocer',
        amount: 180.00,
        categoryId: 'groceries',
        date: DateTime.now().add(const Duration(days: 12)),
        note: 'Pantry restocking',
      ),
    ]);

    _fomoWishlist.clear();
    _fomoWishlist.addAll([
      WishlistItem(
        id: 'fomo_1',
        title: 'Sony WH-1000XM5 Wireless Headphones',
        cost: 1399.00,
        categoryId: 'shopping',
        addedDate: DateTime.now().subtract(const Duration(days: 8)),
        aiVerdict: 'FOMO Alert: You already have working earbuds!',
        aiReason: 'Spending RM 1,399 drops your daily allowance from RM 58 to RM 12/day. Put in 30-day cooldown instead.',
        avoided: true,
      ),
      WishlistItem(
        id: 'fomo_2',
        title: 'Mechanical Custom Keyboard Kit',
        cost: 450.00,
        categoryId: 'shopping',
        addedDate: DateTime.now().subtract(const Duration(days: 3)),
        aiVerdict: 'Impulse Detected: High hype factor',
        aiReason: 'Waiting 30 days gives your ASNB account RM 23.60 extra compound interest instead.',
        avoided: true,
      ),
    ]);

    _totalFomoSaved = 1849.00;
    notifyListeners();
  }

  // --- GETTERS ---
  List<BankAccount> get bankAccounts => List.unmodifiable(_bankAccounts);
  List<InvestmentItem> get investments => List.unmodifiable(_investments);
  List<LoanItem> get loans => List.unmodifiable(_loans);
  List<CategoryItem> get categories => List.unmodifiable(_categories);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);
  List<PlannedExpense> get plannedExpenses => List.unmodifiable(_plannedExpenses);
  List<WishlistItem> get fomoWishlist => List.unmodifiable(_fomoWishlist);
  double get totalFomoSaved => _totalFomoSaved;
  double get monthlySpendingBudget => _monthlySpendingBudget;

  // Total Bank Balances
  double get totalBankBalance {
    return _bankAccounts.fold(0.0, (sum, b) => sum + b.balance);
  }

  // Total Investments & Savings (ASNB + StashAway + Tabung Haji)
  double get totalInvestmentsAndSavings {
    return _investments.fold(0.0, (sum, i) => sum + i.balance);
  }

  // Total Outstanding Loans & Liabilities (ShopeePay + Transport/Car + Grab)
  double get totalLoans {
    return _loans.fold(0.0, (sum, l) => sum + l.remainingBalance);
  }

  // Helper to detect if a transaction is an inter-bank transfer or top-up
  // (Prevents top-ups from inflating monthly expenses or monthly salary income)
  bool isTransferOrTopUp(TransactionItem t) {
    if (t.isTransfer || t.categoryId == 'bank_transfer') return true;
    final lowerTitle = t.title.toLowerCase();
    final lowerNote = (t.note ?? '').toLowerCase();
    final combined = '$lowerTitle $lowerNote';

    // Match Bank Islam and inter-bank topups / transfers
    if (combined.contains('bank islam') &&
        (combined.contains('topup') ||
            combined.contains('top-up') ||
            combined.contains('top up') ||
            combined.contains('transfer'))) {
      return true;
    }
    if ((combined.contains('transfer') ||
            combined.contains('topup') ||
            combined.contains('top up') ||
            combined.contains('top-up')) &&
        (combined.contains('from bank') ||
            combined.contains('to bank') ||
            combined.contains('bank to bank') ||
            combined.contains('interbank') ||
            combined.contains('inter-bank') ||
            combined.contains('cimb') ||
            combined.contains('maybank') ||
            combined.contains('islam') ||
            combined.contains('another bank') ||
            combined.contains('internal'))) {
      return true;
    }
    return false;
  }

  // Monthly Expenses (calculated from transactions logged this month, excluding internal bank transfers / topups)
  double get totalExpensesThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !isTransferOrTopUp(t) &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Monthly Income (calculated from transactions logged this month, excluding internal bank transfers / topups)
  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            !isTransferOrTopUp(t) &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Total Spending Balance Left:
  // User Requirement: "spending balance need to change according to total spending balance minus expense"
  // "total savings change to total spending balance left"
  double get spendingBalanceLeft {
    final remaining = _monthlySpendingBudget - totalExpensesThisMonth;
    return remaining > 0 ? remaining : 0.0;
  }

  // Total Net Worth:
  // User Requirement:
  // "dont add the spending left to the total net worth"
  // Net Worth = (All Bank Balances + Total Investments/Savings) - Total Loans/Liabilities
  double get totalNetWorth {
    final assets = totalBankBalance + totalInvestmentsAndSavings;
    final liabilities = totalLoans;
    return assets - liabilities;
  }

  // Category helper
  CategoryItem getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => const CategoryItem(
        id: 'other',
        name: 'General',
        icon: Icons.category_rounded,
        color: Colors.grey,
        type: TransactionType.expense,
      ),
    );
  }

  // Bank helper
  BankAccount? getBankById(String id) {
    try {
      return _bankAccounts.firstWhere((b) => b.id == id);
    } catch (_) {
      return _bankAccounts.isNotEmpty ? _bankAccounts.first : null;
    }
  }

  // Investment helper
  InvestmentItem? getInvestmentById(String id) {
    try {
      return _investments.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // Loan helper
  LoanItem? getLoanById(String id) {
    try {
      return _loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // Category expense breakdown for Analytics (excluding internal bank transfers / topups)
  Map<String, double> get categoryExpenseBreakdown {
    final now = DateTime.now();
    final Map<String, double> map = {};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          !isTransferOrTopUp(t) &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
      }
    }
    return map;
  }

  // Planned spending for the next 7 days (User requirement: "planned out for the next week i will spend how much")
  double get nextWeekPlannedSpending {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfWeek = startOfToday.add(const Duration(days: 7, hours: 23, minutes: 59));

    return _plannedExpenses
        .where((p) =>
            !p.isPaid &&
            p.date.isAfter(startOfToday.subtract(const Duration(seconds: 1))) &&
            p.date.isBefore(endOfWeek))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // Planned expenses for a specific date (User requirement: "plan out my expense for the day")
  List<PlannedExpense> getPlannedExpensesForDate(DateTime date) {
    return _plannedExpenses.where((p) {
      return p.date.year == date.year &&
          p.date.month == date.month &&
          p.date.day == date.day;
    }).toList();
  }

  double getPlannedTotalForDate(DateTime date) {
    return getPlannedExpensesForDate(date)
        .where((p) => !p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // --- DAILY, WEEKLY, MONTHLY EXPENSES HISTORY ---
  List<DailyExpenseGroup> get dailyExpenseHistory {
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense && !isTransferOrTopUp(t))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<TransactionItem>> grouped = {};
    for (final t in expenses) {
      final key = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final List<DailyExpenseGroup> result = [];
    grouped.forEach((key, list) {
      final total = list.fold<double>(0.0, (sum, item) => sum + item.amount);
      result.add(DailyExpenseGroup(
        date: list.first.date,
        totalExpense: total,
        items: list,
      ));
    });

    return result;
  }

  double get todayExpenseTotal {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !isTransferOrTopUp(t) &&
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get yesterdayExpenseTotal {
    final yest = DateTime.now().subtract(const Duration(days: 1));
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !isTransferOrTopUp(t) &&
            t.date.year == yest.year &&
            t.date.month == yest.month &&
            t.date.day == yest.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<WeeklyExpenseGroup> get weeklyExpenseHistory {
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense && !isTransferOrTopUp(t))
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find current week Monday
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));

    final List<WeeklyExpenseGroup> result = [];

    // Group last 8 weeks
    for (int w = 0; w < 8; w++) {
      final weekStart = currentMonday.subtract(Duration(days: w * 7));
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final weekItems = expenses.where((t) {
        return !t.date.isBefore(weekStart) && !t.date.isAfter(weekEnd);
      }).toList()..sort((a, b) => b.date.compareTo(a.date));

      final total = weekItems.fold<double>(0.0, (sum, t) => sum + t.amount);

      final List<double> dailySpending = List.filled(7, 0.0);
      for (final t in weekItems) {
        final dayIndex = (t.date.weekday - 1).clamp(0, 6);
        dailySpending[dayIndex] += t.amount;
      }

      if (weekItems.isNotEmpty || w < 2) {
        result.add(WeeklyExpenseGroup(
          weekIndex: w,
          startDate: weekStart,
          endDate: weekEnd,
          totalExpense: total,
          dailySpending: dailySpending,
          items: weekItems,
        ));
      }
    }

    return result;
  }

  double get thisWeekExpenseTotal {
    final history = weeklyExpenseHistory;
    return history.isNotEmpty ? history.first.totalExpense : 0.0;
  }

  double get lastWeekExpenseTotal {
    final history = weeklyExpenseHistory;
    return history.length > 1 ? history[1].totalExpense : 0.0;
  }

  List<MonthlyExpenseGroup> get monthlyExpenseHistory {
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense && !isTransferOrTopUp(t))
        .toList();

    final Map<String, List<TransactionItem>> grouped = {};
    for (final t in expenses) {
      final key = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(t);
    }

    // Always include current month even if 0 expenses
    final now = DateTime.now();
    final currentKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    grouped.putIfAbsent(currentKey, () => []);

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final List<MonthlyExpenseGroup> result = [];
    for (final key in sortedKeys) {
      final list = grouped[key]!;
      final parts = key.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);

      final total = list.fold<double>(0.0, (sum, t) => sum + t.amount);
      final Map<String, double> catMap = {};
      for (final t in list) {
        catMap[t.categoryId] = (catMap[t.categoryId] ?? 0.0) + t.amount;
      }

      result.add(MonthlyExpenseGroup(
        year: y,
        month: m,
        totalExpense: total,
        categoryBreakdown: catMap,
        items: list..sort((a, b) => b.date.compareTo(a.date)),
      ));
    }

    return result;
  }

  // --- SUPABASE SYNCHRONIZATION ---
  bool _isLoadingFromSupabase = false;
  bool get isLoadingFromSupabase => _isLoadingFromSupabase;

  Future<void> syncWithSupabase() async {
    if (!SupabaseService.instance.isConfigured) return;

    _isLoadingFromSupabase = true;
    notifyListeners();

    try {
      // 1. Fetch User Profile & Settings
      final profile = await SupabaseService.instance.fetchUserProfile();
      if (profile != null) {
        if (profile['full_name'] != null && (profile['full_name'] as String).isNotEmpty) {
          _userName = profile['full_name'];
        }
        if (profile['email'] != null && (profile['email'] as String).isNotEmpty) {
          _userEmail = profile['email'];
        }
        if (profile['phone'] != null && (profile['phone'] as String).isNotEmpty) {
          _userPhone = profile['phone'];
        }
        if (profile['profile_image'] != null && (profile['profile_image'] as String).isNotEmpty) {
          _profileImageBase64 = profile['profile_image'] as String;
        } else if (profile['avatar_url'] != null && (profile['avatar_url'] as String).isNotEmpty) {
          _profileImageBase64 = profile['avatar_url'] as String;
        }
        if (profile['notifications_enabled'] != null) {
          _notificationsEnabled = profile['notifications_enabled'] as bool;
        }
        if (profile['biometrics_enabled'] != null) {
          _biometricsEnabled = profile['biometrics_enabled'] as bool;
        }
        if (profile['monthly_budget'] != null) {
          _monthlySpendingBudget = (profile['monthly_budget'] as num).toDouble();
        }
      }

      // 2. Fetch Bank Accounts (Empty for new users)
      final supaBanks = await SupabaseService.instance.fetchBankAccounts();
      _bankAccounts.clear();
      _bankAccounts.addAll(supaBanks);

      // 3. Fetch Transactions
      final supaTransactions = await SupabaseService.instance.fetchTransactions();
      _transactions.clear();
      _transactions.addAll(supaTransactions);

      // 4. Fetch Investments
      final supaInvestments = await SupabaseService.instance.fetchInvestments();
      _investments.clear();
      _investments.addAll(supaInvestments);

      // 5. Fetch Loans
      final supaLoans = await SupabaseService.instance.fetchLoans();
      _loans.clear();
      _loans.addAll(supaLoans);

      // 6. Fetch Planned Expenses
      final supaPlans = await SupabaseService.instance.fetchPlannedExpenses();
      _plannedExpenses.clear();
      _plannedExpenses.addAll(supaPlans);

      // 7. Fetch FOMO Wishlist
      final supaWishlist = await SupabaseService.instance.fetchWishlist();
      _fomoWishlist.clear();
      _fomoWishlist.addAll(supaWishlist);
      _totalFomoSaved = _fomoWishlist.where((w) => w.avoided).fold(0.0, (sum, w) => sum + w.cost);
    } catch (e) {
      debugPrint('[FinanceState] Error syncing with Supabase: $e');
    } finally {
      _isLoadingFromSupabase = false;
      notifyListeners();
    }
  }

  // --- ACTIONS ---

  void setMonthlyBudget(double newBudget) {
    _monthlySpendingBudget = newBudget;
    SupabaseService.instance.updateMonthlyBudget(newBudget);
    notifyListeners();
  }

  // Add new transaction (Income or Expense)
  // Directly updates bank balance, spending balance, and total net worth!
  void addTransaction(TransactionItem tx) {
    _transactions.insert(0, tx);

    // Update target bank account
    final bank = getBankById(tx.bankAccountId);
    if (bank != null) {
      if (tx.type == TransactionType.expense) {
        bank.balance -= tx.amount;
        if (bank.balance < 0) bank.balance = 0;
      } else {
        bank.balance += tx.amount;
      }
      SupabaseService.instance.updateBankBalance(bank.id, bank.balance);
    }

    // Background sync to Supabase
    SupabaseService.instance.insertTransaction(tx);

    notifyListeners();
  }

  void deleteTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = _transactions[index];
      // Reverse bank impact
      final bank = getBankById(tx.bankAccountId);
      if (bank != null) {
        if (tx.type == TransactionType.expense) {
          bank.balance += tx.amount;
        } else {
          bank.balance -= tx.amount;
          if (bank.balance < 0) bank.balance = 0;
        }
        SupabaseService.instance.updateBankBalance(bank.id, bank.balance);
      }
      _transactions.removeAt(index);

      // Background sync to Supabase
      SupabaseService.instance.deleteTransaction(id);

      notifyListeners();
    }
  }

  // Add a new bank account
  void addBankAccount(String name, String accountNumber, double initialBalance, Color color) {
    final newBank = BankAccount(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      accountNumber: accountNumber,
      balance: initialBalance,
      color: color,
      icon: Icons.account_balance_rounded,
    );
    _bankAccounts.add(newBank);
    SupabaseService.instance.insertBankAccount(newBank);
    notifyListeners();
  }

  // Delete a bank account
  void deleteBankAccount(String id) {
    _bankAccounts.removeWhere((b) => b.id == id);
    SupabaseService.instance.deleteBankAccount(id);
    notifyListeners();
  }

  // Inter-bank transfer: Moves money from one bank to another without counting as an expense
  void transferBetweenBanks({
    required String fromBankId,
    required String toBankId,
    required double amount,
    String? note,
  }) {
    if (fromBankId == toBankId || amount <= 0) return;
    final fromBank = getBankById(fromBankId);
    final toBank = getBankById(toBankId);
    if (fromBank == null || toBank == null) return;
    if (fromBank.balance < amount) return;

    // Deduct from source bank
    fromBank.balance -= amount;
    // Add to target bank
    toBank.balance += amount;

    SupabaseService.instance.updateBankBalance(fromBank.id, fromBank.balance);
    SupabaseService.instance.updateBankBalance(toBank.id, toBank.balance);

    final now = DateTime.now();
    final timeStr = now.millisecondsSinceEpoch;

    // Outflow transaction on source bank
    final outTx = TransactionItem(
      id: 'tx_tf_out_$timeStr',
      title: 'Transfer to ${toBank.name}',
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'bank_transfer',
      date: now,
      bankAccountId: fromBank.id,
      note: note ?? 'Transfer from ${fromBank.name} to ${toBank.name}',
      isTransfer: true,
    );

    // Inflow transaction on target bank
    final inTx = TransactionItem(
      id: 'tx_tf_in_${timeStr + 1}',
      title: 'Top-Up from ${fromBank.name}',
      amount: amount,
      type: TransactionType.income,
      categoryId: 'bank_transfer',
      date: now,
      bankAccountId: toBank.id,
      note: note ?? 'Received from ${fromBank.name}',
      isTransfer: true,
    );

    _transactions.insert(0, outTx);
    _transactions.insert(0, inTx);

    SupabaseService.instance.insertTransaction(outTx);
    SupabaseService.instance.insertTransaction(inTx);

    notifyListeners();
  }

  // Add money / top up bank account balance
  void addMoneyToBank(String bankId, double amount, {String? note, String? fromBankId}) {
    if (fromBankId != null && fromBankId.isNotEmpty && fromBankId != bankId) {
      transferBetweenBanks(
        fromBankId: fromBankId,
        toBankId: bankId,
        amount: amount,
        note: note,
      );
      return;
    }

    final bank = getBankById(bankId);
    if (bank != null && amount > 0) {
      bank.balance += amount;
      SupabaseService.instance.updateBankBalance(bank.id, bank.balance);

      final tx = TransactionItem(
        id: 'tx_topup_${DateTime.now().millisecondsSinceEpoch}',
        title: '${bank.name} Top-Up',
        amount: amount,
        type: TransactionType.income,
        categoryId: 'bank_transfer',
        date: DateTime.now(),
        bankAccountId: bankId,
        note: note ?? 'Top up into ${bank.name}',
        isTransfer: true,
      );

      _transactions.insert(0, tx);
      SupabaseService.instance.insertTransaction(tx);
      notifyListeners();
    }
  }

  // Minus / Withdraw money from bank account balance
  void minusMoneyFromBank(String bankId, double amount, {String? note, String? categoryId}) {
    final bank = getBankById(bankId);
    if (bank != null && amount > 0) {
      addTransaction(TransactionItem(
        id: 'tx_bank_wd_${DateTime.now().millisecondsSinceEpoch}',
        title: '${bank.name} Withdrawal',
        amount: amount,
        type: TransactionType.expense,
        categoryId: categoryId ?? 'withdrawal',
        date: DateTime.now(),
        bankAccountId: bankId,
        note: note ?? 'Withdrawal from ${bank.name}',
      ));
    }
  }

  // Adjust / Set bank account balance directly
  void setBankBalance(String bankId, double newBalance) {
    final bank = getBankById(bankId);
    if (bank != null) {
      bank.balance = newBalance;
      SupabaseService.instance.updateBankBalance(bank.id, bank.balance);
      notifyListeners();
    }
  }

  // Add a new loan (e.g. ShopeePay, Transport, Personal)
  void addLoan(String name, String provider, double totalAmount, double monthlyInstallment, int dueDay) {
    final newLoan = LoanItem(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      provider: provider,
      totalLoan: totalAmount,
      remainingBalance: totalAmount,
      monthlyInstallment: monthlyInstallment,
      dueDayOfMonth: dueDay,
      icon: Icons.credit_card_rounded,
      color: const Color(0xFFFF6584),
    );
    _loans.add(newLoan);
    SupabaseService.instance.insertLoan(newLoan);
    notifyListeners();
  }

  // Pay down loan
  void payLoanInstallment(String loanId, double paymentAmount, String fromBankId) {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final bank = getBankById(fromBankId);
    if (bank != null && bank.balance >= paymentAmount) {
      bank.balance -= paymentAmount;
      loan.remainingBalance -= paymentAmount;
      if (loan.remainingBalance < 0) loan.remainingBalance = 0;

      // Sync loan balance & bank balance to Supabase
      SupabaseService.instance.updateLoanBalance(loan.id, loan.remainingBalance);
      SupabaseService.instance.updateBankBalance(bank.id, bank.balance);

      // Also record as expense transaction
      addTransaction(TransactionItem(
        id: 'tx_loan_${DateTime.now().millisecondsSinceEpoch}',
        title: '${loan.name} Payment',
        amount: paymentAmount,
        type: TransactionType.expense,
        categoryId: 'loan_repay',
        date: DateTime.now(),
        bankAccountId: fromBankId,
        note: 'Loan installment deducted',
      ));
    }
    notifyListeners();
  }

  // Minus / Pay down loan balance directly (or with optional bank deduction)
  void minusLoanBalance(String loanId, double amount, {String? fromBankId, String? note}) {
    final loan = getLoanById(loanId);
    if (loan != null && amount > 0) {
      loan.remainingBalance -= amount;
      if (loan.remainingBalance < 0) loan.remainingBalance = 0;
      SupabaseService.instance.updateLoanBalance(loan.id, loan.remainingBalance);

      if (fromBankId != null && fromBankId.isNotEmpty) {
        final bank = getBankById(fromBankId);
        if (bank != null && bank.balance >= amount) {
          // addTransaction automatically updates bank.balance and syncs with Supabase
          addTransaction(TransactionItem(
            id: 'tx_loan_deduct_${DateTime.now().millisecondsSinceEpoch}',
            title: '${loan.name} Repayment',
            amount: amount,
            type: TransactionType.expense,
            categoryId: 'loan_repay',
            date: DateTime.now(),
            bankAccountId: fromBankId,
            note: note ?? 'Principal deduction for ${loan.name}',
          ));
        }
      }
      notifyListeners();
    }
  }

  // Delete a loan / liability
  void deleteLoan(String id) {
    _loans.removeWhere((l) => l.id == id);
    SupabaseService.instance.deleteLoan(id);
    notifyListeners();
  }

  void setLoanBalance(String id, double newBalance) {
    final loan = getLoanById(id);
    if (loan != null) {
      loan.remainingBalance = newBalance < 0 ? 0 : newBalance;
      SupabaseService.instance.updateLoanBalance(loan.id, loan.remainingBalance);
      notifyListeners();
    }
  }

  // --- INVESTMENTS & SAVINGS MANAGEMENT ---
  void addInvestment(InvestmentItem item) {
    _investments.add(item);
    SupabaseService.instance.insertInvestment(item);
    notifyListeners();
  }

  void deleteInvestment(String id) {
    _investments.removeWhere((i) => i.id == id);
    SupabaseService.instance.deleteInvestment(id);
    notifyListeners();
  }

  void minusInvestmentBalance(String id, double amount, {String? toBankId, String? note}) {
    final inv = getInvestmentById(id);
    if (inv != null && amount > 0) {
      inv.balance -= amount;
      if (inv.balance < 0) inv.balance = 0;
      SupabaseService.instance.updateInvestmentBalance(inv.id, inv.balance);

      if (toBankId != null && toBankId.isNotEmpty) {
        final bank = getBankById(toBankId);
        if (bank != null) {
          // addTransaction automatically updates bank.balance and syncs with Supabase
          addTransaction(TransactionItem(
            id: 'tx_inv_wd_${DateTime.now().millisecondsSinceEpoch}',
            title: '${inv.name} Withdrawal',
            amount: amount,
            type: TransactionType.income,
            categoryId: 'income_general',
            date: DateTime.now(),
            bankAccountId: toBankId,
            note: note ?? 'Withdrawn from ${inv.name} into ${bank.name}',
          ));
        }
      }
      notifyListeners();
    }
  }

  void addMoneyToInvestment(String id, double amount, {String? fromBankId, String? note}) {
    final inv = getInvestmentById(id);
    if (inv != null && amount > 0) {
      inv.balance += amount;
      SupabaseService.instance.updateInvestmentBalance(inv.id, inv.balance);

      if (fromBankId != null && fromBankId.isNotEmpty) {
        final bank = getBankById(fromBankId);
        if (bank != null && bank.balance >= amount) {
          // addTransaction automatically updates bank.balance and syncs with Supabase
          addTransaction(TransactionItem(
            id: 'tx_inv_dp_${DateTime.now().millisecondsSinceEpoch}',
            title: '${inv.name} Deposit',
            amount: amount,
            type: TransactionType.expense,
            categoryId: 'investment_deposit',
            date: DateTime.now(),
            bankAccountId: fromBankId,
            note: note ?? 'Deposited into ${inv.name} from ${bank.name}',
          ));
        }
      }
      notifyListeners();
    }
  }

  void setInvestmentBalance(String id, double newBalance) {
    final inv = getInvestmentById(id);
    if (inv != null) {
      inv.balance = newBalance < 0 ? 0 : newBalance;
      SupabaseService.instance.updateInvestmentBalance(inv.id, inv.balance);
      notifyListeners();
    }
  }

  // Add a planned expense to the calendar
  void addPlannedExpense(PlannedExpense plan) {
    _plannedExpenses.add(plan);
    _plannedExpenses.sort((a, b) => a.date.compareTo(b.date));

    // Background sync to Supabase
    SupabaseService.instance.insertPlannedExpense(plan);

    notifyListeners();
  }

  // Mark planned expense as paid -> Converts it into an actual transaction!
  void convertPlannedToActual(String planId, String bankId) {
    final index = _plannedExpenses.indexWhere((p) => p.id == planId);
    if (index != -1) {
      final plan = _plannedExpenses[index];
      plan.isPaid = true;

      // Update in Supabase
      SupabaseService.instance.updatePlannedExpense(plan);

      // Add to real transactions
      addTransaction(TransactionItem(
        id: 'tx_from_plan_${DateTime.now().millisecondsSinceEpoch}',
        title: plan.title,
        amount: plan.amount,
        type: TransactionType.expense,
        categoryId: plan.categoryId,
        date: DateTime.now(),
        bankAccountId: bankId,
        note: 'Scheduled expense executed from Calendar Planner',
      ));
      notifyListeners();
    }
  }

  void deletePlannedExpense(String id) {
    _plannedExpenses.removeWhere((p) => p.id == id);
    SupabaseService.instance.deletePlannedExpense(id);
    notifyListeners();
  }

  // Record FOMO avoidance (Saying NO to impulse buy!)
  void recordFomoAvoidance(String title, double cost, String categoryId, String advice, String reason) {
    _totalFomoSaved += cost;
    final item = WishlistItem(
      id: 'wish_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      cost: cost,
      categoryId: categoryId,
      addedDate: DateTime.now(),
      aiVerdict: advice,
      aiReason: reason,
      avoided: true,
    );
    _fomoWishlist.insert(0, item);
    SupabaseService.instance.insertWishlistItem(item);
    notifyListeners();
  }

  // Add to 30-day wishlist
  void addToWishlist(String title, double cost, String categoryId, String advice, String reason) {
    final item = WishlistItem(
      id: 'wish_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      cost: cost,
      categoryId: categoryId,
      addedDate: DateTime.now(),
      aiVerdict: advice,
      aiReason: reason,
      avoided: false,
    );
    _fomoWishlist.insert(0, item);
    SupabaseService.instance.insertWishlistItem(item);
    notifyListeners();
  }

  // Delete item from FOMO wishlist
  void deleteWishlistItem(String id) {
    final index = _fomoWishlist.indexWhere((w) => w.id == id);
    if (index != -1) {
      final item = _fomoWishlist[index];
      if (item.avoided) {
        _totalFomoSaved = (_totalFomoSaved - item.cost).clamp(0.0, double.infinity);
      }
      _fomoWishlist.removeAt(index);
      SupabaseService.instance.deleteWishlistItem(id);
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION & PROFILE ACTIONS
  // ---------------------------------------------------------------------------
  Future<bool> signIn({required String email, required String password}) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    // Wipe any existing/mock data before signing into actual user session
    clearAllData();

    try {
      if (SupabaseService.instance.isConfigured) {
        final res = await SupabaseService.instance.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (res?.user != null) {
          _userEmail = res!.user!.email ?? email.trim();
          final metaName = res.user!.userMetadata?['full_name'];
          if (metaName is String && metaName.isNotEmpty) {
            _userName = metaName;
          } else {
            _userName = email.trim().split('@').first;
          }
        }
      } else {
        // Resilient demo/offline sign in
        await Future.delayed(const Duration(milliseconds: 600));
        _userEmail = email.trim();
        _userName = email.trim().split('@').first;
      }

      _isAuthenticated = true;
      _isAuthLoading = false;
      _authError = null;
      notifyListeners();

      // Trigger data sync upon sign in - new users will have empty lists
      syncWithSupabase();
      return true;
    } catch (e) {
      _isAuthLoading = false;
      String msg = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      if (msg.contains('Email not confirmed')) {
        msg = 'Your email has not been confirmed yet. Please check your inbox for the confirmation link, or disable "Confirm email" in Supabase Dashboard to sign in immediately.';
      } else if (msg.contains('Invalid login credentials')) {
        msg = 'Invalid email or password. Please check your credentials or reset your password.';
      }
      _authError = msg;
      notifyListeners();
      return false;
    }
  }

  bool _requiresSignUpVerification = false;
  bool get requiresSignUpVerification => _requiresSignUpVerification;
  String _pendingSignUpEmail = '';
  String get pendingSignUpEmail => _pendingSignUpEmail;

  void clearSignUpVerification() {
    _requiresSignUpVerification = false;
    _pendingSignUpEmail = '';
    notifyListeners();
  }

  Future<bool> signUp({required String email, required String password, String? name}) async {
    _isAuthLoading = true;
    _authError = null;
    _requiresSignUpVerification = false;
    notifyListeners();

    // Fresh clean slate for new registrations - no default/mock data
    clearAllData();

    try {
      if (SupabaseService.instance.isConfigured) {
        final res = await SupabaseService.instance.signUp(
          email: email.trim(),
          password: password,
          fullName: name,
        );
        if (res?.user != null) {
          _userEmail = res!.user!.email ?? email.trim();
          _userName = name ?? email.trim().split('@').first;
          
          if (res.session != null) {
            // Session established immediately (Confirm email is OFF in Supabase)
            await SupabaseService.instance.updateUserProfile(
              name: _userName,
              email: _userEmail,
            );
            _isAuthenticated = true;
            _isAuthLoading = false;
            _authError = null;
            notifyListeners();
            syncWithSupabase();
            return true;
          } else {
            // Confirm email is ON in Supabase - user needs to verify PIN code
            _isAuthLoading = false;
            _requiresSignUpVerification = true;
            _pendingSignUpEmail = _userEmail;
            _authError = null;
            notifyListeners();
            return false;
          }
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        _userEmail = email.trim();
        _userName = name ?? email.trim().split('@').first;
        _isAuthenticated = true;
        _isAuthLoading = false;
        _authError = null;
        notifyListeners();
        return true;
      }

      _isAuthLoading = false;
      _authError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthLoading = false;
      String msg = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      if (msg.contains('Error sending confirmation email') || msg.contains('unexpected_failure')) {
        msg = 'Failed to send confirmation email. Check your Supabase SMTP settings, or if using Resend onboarding domain, test with your Resend account email.';
      } else if (msg.contains('over_email_send_rate_limit') || msg.contains('rate limit')) {
        msg = 'Supabase email limit reached (max 2 emails/hour on free tier). Connect custom SMTP in Supabase to send unlimited emails!';
      } else if (msg.contains('User already registered')) {
        msg = 'An account with this email already exists. Please sign in or use Forgot Password.';
      }
      _authError = msg;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifySignUpCode({
    required String email,
    required String token,
    String? name,
  }) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      if (SupabaseService.instance.isConfigured) {
        final res = await SupabaseService.instance.verifySignUpOtp(
          email: email.trim(),
          token: token.trim(),
        );
        if (res?.user != null) {
          _userEmail = res!.user!.email ?? email.trim();
          _userName = name ?? _userName;
          
          await SupabaseService.instance.updateUserProfile(
            name: _userName,
            email: _userEmail,
          );
          _isAuthenticated = true;
          _requiresSignUpVerification = false;
          _pendingSignUpEmail = '';
          _isAuthLoading = false;
          _authError = null;
          notifyListeners();
          syncWithSupabase();
          return true;
        }
      }
      _isAuthLoading = false;
      _authError = 'Could not verify code. Please check your PIN and try again.';
      notifyListeners();
      return false;
    } catch (e) {
      _isAuthLoading = false;
      _authError = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      notifyListeners();
      return false;
    }
  }

  void signInDemo() {
    clearAllData();
    loadDemoData();
    _isAuthenticated = true;
    _userName = 'Airiel';
    _userEmail = 'airiel@blupp.ai';
    _authError = null;
    notifyListeners();
    syncWithSupabase();
  }

  Future<void> signOut() async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      await SupabaseService.instance.signOut();
    } catch (e) {
      debugPrint('[FinanceState] Error during signOut: $e');
    } finally {
      clearAllData();
      _isAuthenticated = false;
      _isAuthLoading = false;
      _authError = null;
      notifyListeners();
    }
  }

  void updateProfile({required String name, required String email, String? phone}) {
    _userName = name.trim();
    _userEmail = email.trim();
    if (phone != null && phone.trim().isNotEmpty) {
      _userPhone = phone.trim();
    }
    SupabaseService.instance.updateUserProfile(
      name: _userName,
      email: _userEmail,
      phone: _userPhone,
      notificationsEnabled: _notificationsEnabled,
      biometricsEnabled: _biometricsEnabled,
      monthlyBudget: _monthlySpendingBudget,
    );
    notifyListeners();
  }

  void toggleNotifications(bool val) {
    _notificationsEnabled = val;
    SupabaseService.instance.updateUserProfile(
      name: _userName,
      email: _userEmail,
      phone: _userPhone,
      notificationsEnabled: val,
      biometricsEnabled: _biometricsEnabled,
      monthlyBudget: _monthlySpendingBudget,
    );
    notifyListeners();
  }

  void toggleBiometrics(bool val) {
    _biometricsEnabled = val;
    SupabaseService.instance.updateUserProfile(
      name: _userName,
      email: _userEmail,
      phone: _userPhone,
      notificationsEnabled: _notificationsEnabled,
      biometricsEnabled: val,
      monthlyBudget: _monthlySpendingBudget,
    );
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Password Reset with Email Verification PIN Code
  Future<String> requestPasswordResetCode(String email) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final code = await SupabaseService.instance.sendPasswordResetVerification(email);
      _isAuthLoading = false;
      notifyListeners();
      return code;
    } catch (e) {
      _isAuthLoading = false;
      _authError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> verifyPasswordResetPin({
    required String email,
    required String token,
    required String expectedCode,
  }) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final verified = await SupabaseService.instance.verifyPasswordResetPin(
        email: email,
        token: token,
        fallbackCode: expectedCode,
      );
      _isAuthLoading = false;
      notifyListeners();
      return verified;
    } catch (e) {
      _isAuthLoading = false;
      _authError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPasswordWithVerification({required String newPassword}) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final success = await SupabaseService.instance.updatePassword(newPassword);
      _isAuthLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isAuthLoading = false;
      _authError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
