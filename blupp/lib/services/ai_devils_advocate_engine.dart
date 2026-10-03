import 'dart:math';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';

class DevilsAdvocateResponse {
  final String text;
  final double currentPrice;
  final String currentItem;
  final Map<String, dynamic> cardData;
  final List<String> suggestedChips;

  DevilsAdvocateResponse({
    required this.text,
    required this.currentPrice,
    required this.currentItem,
    required this.cardData,
    required this.suggestedChips,
  });
}

class AiDevilsAdvocateEngine {
  /// Generates a deeply personalized, contextual, conversational counter-argument
  /// that responds directly to the user's specific inputs and excuses.
  static DevilsAdvocateResponse generateResponse({
    required String userMessage,
    required FinanceState state,
    required String? currentItem,
    required double? currentPrice,
    required List<Map<String, dynamic>> conversationHistory,
  }) {
    final lower = userMessage.toLowerCase();
    final name = state.userName.isNotEmpty ? state.userName : 'Airiel';
    final balanceLeft = state.spendingBalanceLeft;
    final dailyAllowance = state.aiSafeToSpendRadar.safeDailyAllowance;
    final monthlyIncome = state.totalIncomeThisMonth > 0 ? state.totalIncomeThisMonth : 4500.0;
    final hourlyWage = (monthlyIncome / 160.0).clamp(15.0, 500.0);

    // 1. Dynamic Extraction of Item and Price
    double price = currentPrice ?? 150.0;
    final amountRegex = RegExp(r'(?:rm|\$)?\s*([0-9]+(?:[\.,][0-9]{1,2})?)\s*(?:rm|ringgit|myr|k)?', caseSensitive: false);
    final match = amountRegex.firstMatch(lower);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '');
      if (parsed != null && parsed > 0) {
        price = parsed;
        if (lower.contains('k') && price < 100) {
          price *= 1000;
        }
      }
    }

    String item = currentItem ?? 'this item';
    // Clean common prefixes
    if (currentItem == null || currentItem.isEmpty || currentItem == 'this item') {
      final itemMatch = RegExp(r'(?:buy|get|purchase|want|craving)\s+(?:a|an|the)?\s*([a-zA-Z0-9\s\-]+?)(?:\s+for|\s+at|\s+rm|\s+\$|\s+cost|\?|\.|$)', caseSensitive: false).firstMatch(userMessage);
      if (itemMatch != null) {
        final extracted = itemMatch.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty && extracted.length < 40) {
          item = extracted;
        }
      }
    }

    // Mathematical metrics
    final workHours = (price / hourlyWage).toStringAsFixed(1);
    final futureValue10Yr = price * pow(1.08, 10);
    final allowanceDropPct = state.monthlySpendingBudget > 0
        ? ((price / state.monthlySpendingBudget) * 100).toStringAsFixed(1)
        : '25.0';
    final remainingDays = state.daysRemainingInMonth;
    final newDaily = balanceLeft > price && remainingDays > 0
        ? (balanceLeft - price) / remainingDays
        : 0.0;

    final cardData = {
      'price': price,
      'workHours': workHours,
      'futureValue': futureValue10Yr,
      'allowanceDrop': allowanceDropPct,
      'newDaily': newDaily,
      'item': item,
    };

    String responseText = '';
    List<String> nextChips = [];

    // --- 2. INTENT CLASSIFICATION & PERSONA GENERATION ---

    // A. User brings up Buy Now Pay Later (SPayLater / GrabPayLater / installment)
    if (lower.contains('spaylater') ||
        lower.contains('paylater') ||
        lower.contains('installment') ||
        lower.contains('atome') ||
        lower.contains('bulan') ||
        lower.contains('monthly payment') ||
        lower.contains('split payment') ||
        lower.contains('0%')) {
      final monthlySlice = price / 6.0;
      responseText =
          "⚠️ **The BNPL Trap Alert, $name!**\n\n"
          "Spreading ${AppTheme.formatCurrency(price)} over 6 months at ~${AppTheme.formatCurrency(monthlySlice)}/month doesn't make '$item' any cheaper — it just mortgages your future freedom.\n\n"
          "Here is what PayLater apps don't tell you:\n"
          "• It silently locks up ${AppTheme.formatCurrency(monthlySlice)} of your monthly buffer until next year.\n"
          "• If your car needs tires or an unexpected dentist visit pops up, this installment becomes dead weight.\n"
          "• One delayed payment triggers late processing fees that instantly erase any perceived discount.\n\n"
          "If you wouldn't pay cash for $item today, you definitely shouldn't borrow from your future self to buy it.";

      nextChips = [
        "What if I buy second-hand instead?",
        "I'll wait for next paycheck",
        "Fine, put it on 30-day cooldown",
        "Is there a zero-cost alternative?",
      ];
    }
    // B. User claims it's on a Flash Sale / Limited Time Discount
    else if (lower.contains('sale') ||
        lower.contains('discount') ||
        lower.contains('promo') ||
        lower.contains('voucher') ||
        lower.contains('off') ||
        lower.contains('murah') ||
        lower.contains('deal') ||
        lower.contains('ending soon') ||
        lower.contains('tamat')) {
      responseText =
          "⏳ **The Marketer's Scarcity Illusion!**\n\n"
          "E-commerce algorithms intentionally put countdown timers on '$item' to trigger urgency so you skip logical thinking.\n\n"
          "Remember the golden rule of wealth, $name:\n"
          "👉 Spending ${AppTheme.formatCurrency(price)} on an item you weren't actively searching for 7 days ago **is not saving money — it's losing ${AppTheme.formatCurrency(price)}.**\n\n"
          "Shopee and Lazada run sales every single month (4.4, 5.5, Payday Sale). If you still genuinely need '$item' in 30 days, there will be another promo. Put it on cooldown now!";

      nextChips = [
        "I actually need it for work/study",
        "Can I afford it with my current balance?",
        "Alright, add to 30-day wishlist",
        "What would this grow to if invested?",
      ];
    }
    // C. User claims they need it for Work / Productivity / Career
    else if (lower.contains('work') ||
        lower.contains('productivity') ||
        lower.contains('kerja') ||
        lower.contains('study') ||
        lower.contains('career') ||
        lower.contains('invest in myself') ||
        lower.contains('office') ||
        lower.contains('laptop') ||
        lower.contains('need it for')) {
      responseText =
          "💼 **The 'Productivity Rationalization' Test!**\n\n"
          "We love telling ourselves '$item' is an 'investment in myself', because it feels responsible. But let's run the cold ROI calculation:\n\n"
          "1. Will '$item' directly generate +${AppTheme.formatCurrency(price * 1.5)} in freelance/career income within 90 days?\n"
          "2. Can your existing setup get the job done 80% as well right now?\n"
          "3. You have to work **$workHours full hours** at your desk just to cover the invoice.\n\n"
          "If it's an essential tool, plan it in your calendar for next month's budget. Don't impulse-buy it out of today's liquid reserves.";

      nextChips = [
        "What if I find a cheaper alternative?",
        "Can I split the cost with someone?",
        "I'll put it on 30-day cooldown",
        "How bad is my remaining allowance?",
      ];
    }
    // D. User says they are stressed / deserve a treat / emotional reward
    else if (lower.contains('stress') ||
        lower.contains('deserve') ||
        lower.contains('penat') ||
        lower.contains('tired') ||
        lower.contains('treat') ||
        lower.contains('reward') ||
        lower.contains('bad day') ||
        lower.contains('self care') ||
        lower.contains('healing')) {
      responseText =
          "🫂 **I Hear You, $name — But Retail Therapy is a Scam!**\n\n"
          "You worked hard, your energy is drained, and your brain is craving a quick hit of dopamine. That's 100% human.\n\n"
          "Here's the psychological trap:\n"
          "The dopamine rush from clicking 'Buy Now' on '$item' lasts **about 15 minutes**. But when your package arrives, your remaining allowance is crippled down to ${AppTheme.formatCurrency(newDaily > 0 ? newDaily : 0.0)}/day, bringing back financial stress for weeks.\n\n"
          "💡 **Zero-Cost Dopamine Alternative Tonight:**\n"
          "Take a warm shower, grab your favorite comfort drink, watch a great movie, or hit the gym. Protect your peace AND your RM ${price.toStringAsFixed(0)}.";

      nextChips = [
        "You're right, I was just stressed",
        "Add to 30-day cooldown instead",
        "What if I spend only RM 30 on food?",
        "Show me my investment growth instead",
      ];
    }
    // E. User offers to sacrifice food / eat Maggi / budget restriction
    else if (lower.contains('maggi') ||
        lower.contains('skip meal') ||
        lower.contains('cut food') ||
        lower.contains('puasa') ||
        lower.contains('save next week') ||
        lower.contains('eat less') ||
        lower.contains('diet')) {
      responseText =
          "🍜 **Don't Do The 'Maggi Diet' Bargain, $name!**\n\n"
          "Whenever people bargain with: *'I'll just eat instant noodles for 2 weeks to pay for $item'*, it almost always backfires:\n\n"
          "• Extreme deprivation triggers binge spending the following weekend.\n"
          "• Lower energy and poor nutrition hurt your focus and productivity at work.\n"
          "• Your health and daily vitality are your highest-yield financial assets.\n\n"
          "Never sacrifice your physical well-being to subsidize a consumer gadget or luxury item.";

      nextChips = [
        "Haha guilty as charged! Put in cooldown",
        "What if I buy second-hand?",
        "How much would this earn in ASNB?",
        "Okay, let me wait 30 days",
      ];
    }
    // F. User asks about buying second-hand / refurbished
    else if (lower.contains('second hand') ||
        lower.contains('used') ||
        lower.contains('carousell') ||
        lower.contains('refurbished') ||
        lower.contains('terpakai') ||
        lower.contains('cheaper')) {
      final discountedPrice = price * 0.55;
      responseText =
          "🔍 **Smart Shift! Second-Hand Evaluation:**\n\n"
          "Shopping on Carousell or certified refurbished is already 10x smarter than paying brand new retail markup.\n\n"
          "If you can get '$item' for ~${AppTheme.formatCurrency(discountedPrice)} instead of ${AppTheme.formatCurrency(price)}:\n"
          "• You instantly pocket **${AppTheme.formatCurrency(price - discountedPrice)} in savings**.\n"
          "• Your labor commitment drops from $workHours hours down to ${(discountedPrice / hourlyWage).toStringAsFixed(1)} hours.\n\n"
          "⚠️ **Condition:** Even for second-hand, apply the **72-Hour Rule**. If you still want it on Friday, search Carousell with cash ready!";

      nextChips = [
        "Deal! Put in 72-hour cooldown",
        "Add to 30-Day Wishlist",
        "How does this affect my daily budget?",
      ];
    }
    // G. User agrees / concedes / wants to cooldown
    else if (lower.contains('fine') ||
        lower.contains('okay') ||
        lower.contains('ok') ||
        lower.contains('you win') ||
        lower.contains('cooldown') ||
        lower.contains('wishlist') ||
        lower.contains('agree') ||
        lower.contains('betul') ||
        lower.contains('setuju') ||
        lower.contains('wait') ||
        lower.contains('cancel')) {
      responseText =
          "🎉 **Victory! You Just Defeated Retail FOMO, $name!**\n\n"
          "By resisting '$item' right now, you kept **${AppTheme.formatCurrency(price)}** right where it belongs: in your pocket building your net worth.\n\n"
          "Tap the button below to park it in your **30-Day Cooling Chamber**. Blupp will track your savings, and if you still need it in 30 days when your next paycheck lands, you can buy it guilt-free!";

      nextChips = [
        "🛡️ Lock into 30-Day Cooldown",
        "Evaluate another temptation",
        "Show my Safe-to-Spend runway",
      ];
    }
    // H. Direct proposal or general impulse interrogation
    else {
      if (price > balanceLeft && balanceLeft > 0) {
        responseText =
            "🚨 **STOP! Balance Sheet Overdraft Warning!**\n\n"
            "Hey $name, buying '$item' for ${AppTheme.formatCurrency(price)} **EXCEEDS your entire remaining spending allowance (${AppTheme.formatCurrency(balanceLeft)})** by ${AppTheme.formatCurrency(price - balanceLeft)}!\n\n"
            "• Immediate Deficit: This purchase plunges your discretionary pool straight into the negative.\n"
            "• Days Remaining: You have $remainingDays days left this month. Buying this means surviving with ZERO spending margin.\n"
            "• True Sweat Cost: That's **$workHours hours of desk labor**.\n\n"
            "Is '$item' really worth enduring two weeks of financial stress?";
      } else if (price >= 300) {
        responseText =
            "🥊 **Hold up $name! Let's Talk Facts About '$item':**\n\n"
            "At ${AppTheme.formatCurrency(price)}, this single purchase wipes out **$allowanceDropPct% of your monthly discretionary budget**.\n\n"
            "• Labor Equivalent: You have to trade **$workHours hours of your life** at work to pay for this.\n"
            "• Daily Squeeze: Your daily safe allowance drops from ${AppTheme.formatCurrency(dailyAllowance)}/day to **${AppTheme.formatCurrency(newDaily)}/day**.\n"
            "• 10-Year Opportunity Cost: If compounded in an ASNB/EPF portfolio at 8%, this ${AppTheme.formatCurrency(price)} becomes **${AppTheme.formatCurrency(futureValue10Yr)}**.\n\n"
            "Why do you feel you need this today instead of waiting 30 days?";
      } else {
        responseText =
            "🧐 **Let's Reality-Check '$item' (${AppTheme.formatCurrency(price)}):**\n\n"
            "It might look like a small purchase, but death by a thousand papercuts is how budgets collapse.\n\n"
            "• It costs you **$workHours hours of hard work** to earn after taxes.\n"
            "• In 10 years, investing this produces **${AppTheme.formatCurrency(futureValue10Yr)}**.\n\n"
            "Be honest with yourself, $name: Did you plan on buying '$item' before today, or did an algorithm or friend put it in your head?";
      }

      nextChips = [
        "It's on a limited-time flash sale!",
        "Can I buy it using SPayLater?",
        "I need this for work productivity",
        "I had a stressful day, I deserve it",
      ];
    }

    return DevilsAdvocateResponse(
      text: responseText,
      currentPrice: price,
      currentItem: item,
      cardData: cardData,
      suggestedChips: nextChips,
    );
  }
}
