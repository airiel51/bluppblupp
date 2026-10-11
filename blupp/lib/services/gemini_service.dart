import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';
import '../models/finance_state.dart';
import '../theme/app_theme.dart';
import 'ai_devils_advocate_engine.dart';

class GeminiFomoEvaluationResult {
  final String verdictTitle;
  final String verdictType; // 'safe', 'warning', 'danger'
  final String adviceText;
  final String whyNotNeed;
  final int regretScore;
  final List<Map<String, dynamic>> recommendations;
  final bool isRealAi;

  GeminiFomoEvaluationResult({
    required this.verdictTitle,
    required this.verdictType,
    required this.adviceText,
    required this.whyNotNeed,
    required this.regretScore,
    required this.recommendations,
    required this.isRealAi,
  });
}

class GeminiService extends ChangeNotifier {
  GeminiService._internal();
  static final GeminiService instance = GeminiService._internal();

  static const String _prefKeyGemini = 'blupp_gemini_api_key';
  static const String _prefKeyModel = 'blupp_gemini_model';

  String _apiKey = '';
  String _selectedModel = AiConfig.defaultModel;
  bool _isInitialized = false;

  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;
  bool get isInitialized => _isInitialized;

  /// Initialize Gemini service and load stored API key
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString(_prefKeyGemini);
      final storedModel = prefs.getString(_prefKeyModel);

      if (storedKey != null && storedKey.trim().isNotEmpty) {
        _apiKey = storedKey.trim();
      } else if (AiConfig.defaultGeminiApiKey.isNotEmpty) {
        _apiKey = AiConfig.defaultGeminiApiKey.trim();
      }

      if (storedModel != null && storedModel.trim().isNotEmpty) {
        _selectedModel = storedModel.trim();
      }
    } catch (e) {
      debugPrint('[GeminiService] Error reading shared preferences: $e');
      if (AiConfig.defaultGeminiApiKey.isNotEmpty) {
        _apiKey = AiConfig.defaultGeminiApiKey.trim();
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update the Gemini API key and persist to storage
  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_apiKey.isEmpty) {
        await prefs.remove(_prefKeyGemini);
      } else {
        await prefs.setString(_prefKeyGemini, _apiKey);
      }
    } catch (e) {
      debugPrint('[GeminiService] Failed to persist API key: $e');
    }
    notifyListeners();
  }

  /// Change active Gemini model
  Future<void> setModel(String model) async {
    _selectedModel = model;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyModel, model);
    } catch (e) {
      debugPrint('[GeminiService] Failed to persist model choice: $e');
    }
    notifyListeners();
  }

  /// Test an API key by sending a lightweight validation ping
  Future<({bool success, String message})> testApiKey(String keyToTest) async {
    final key = keyToTest.trim();
    if (key.isEmpty) {
      return (success: false, message: 'API key cannot be empty.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_selectedModel:generateContent?key=$key',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Ping test. Reply with: OK'}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 10,
            'temperature': 0.1,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return (success: true, message: 'Successfully connected to Google Gemini!');
      } else {
        try {
          final errBody = jsonDecode(response.body);
          final errMsg = errBody['error']?['message'] ?? 'Status ${response.statusCode}';
          return (success: false, message: 'Google Gemini Error: $errMsg');
        } catch (_) {
          return (success: false, message: 'Connection failed with status ${response.statusCode}');
        }
      }
    } catch (e) {
      return (success: false, message: 'Network connection failed: $e');
    }
  }

  /// Core helper to call Gemini generateContent with fallback models
  Future<String?> _callGemini({
    required String prompt,
    String? systemInstruction,
    double temperature = 0.7,
    int maxOutputTokens = 1000,
  }) async {
    if (!hasApiKey) return null;

    final modelsToTry = [
      _selectedModel,
      ...AiConfig.fallbackModels.where((m) => m != _selectedModel),
    ];

    for (final model in modelsToTry) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey',
      );

      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxOutputTokens,
        }
      };

      if (systemInstruction != null && systemInstruction.isNotEmpty) {
        requestBody['systemInstruction'] = {
          'parts': [
            {'text': systemInstruction}
          ]
        };
      }

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
        } else {
          debugPrint('[GeminiService] Model $model returned ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('[GeminiService] Exception calling $model: $e');
      }
    }

    return null;
  }

  /// Evaluates an impulse purchase using real Google Gemini AI
  /// Falls back to local financial psychometrics if AI is not configured or offline.
  Future<GeminiFomoEvaluationResult> evaluateFomoPurchase({
    required String itemName,
    required double enteredCost,
    required String selectedCurrency,
    required String urgencyOption,
    required FinanceState state,
  }) async {
    final userName = state.userName.isNotEmpty ? state.userName : 'Saver';
    final baseCurrency = state.baseCurrency;
    final currentBalance = state.spendingBalanceLeft;
    final projectedBalance = currentBalance - enteredCost;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day).clamp(1, 31);
    final oldDaily = currentBalance > 0 ? currentBalance / remainingDays : 0.0;
    final newDaily = projectedBalance > 0 ? projectedBalance / remainingDays : 0.0;

    final monthlyIncome = state.totalIncomeThisMonth > 0 ? state.totalIncomeThisMonth : 4500.0;
    final hourlyWage = (monthlyIncome / 160.0).clamp(15.0, 500.0);
    final workHours = enteredCost / hourlyWage;
    final tenYearCompound = enteredCost * pow(1.08, 10);

    final upcomingPlans = state.plannedExpenses
        .where((p) => !p.isPaid && p.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    final upcomingPlannedTotal = upcomingPlans.fold<double>(0.0, (sum, p) => sum + p.amount);

    final totalMonthlyLoans = state.loans.fold<double>(0.0, (sum, l) => sum + l.monthlyInstallment);

    // If Gemini is configured, invoke the Real AI
    if (hasApiKey) {
      final systemPrompt = '''
You are Blupp's Real Anti-FOMO AI Intelligence Engine.
Your job is to objectively analyze a potential impulse purchase for a user and save them from buyer's remorse.
Be sharp, psychologically insightful, financially grounded, and witty.
Respond STRICTLY with a valid JSON object without surrounding markdown code fences, using this schema:
{
  "verdictTitle": "Short bold verdict line with emoji, e.g. 🛑 CRITICAL OVER-BUDGET ALERT! or ⚠️ HEAVY DENT IN DAILY ALLOWANCE or ✅ APPROVED WITHIN BUDGET",
  "verdictType": "danger" | "warning" | "safe",
  "adviceText": "2-3 punchy, conversational sentences speaking directly to the user by name. Evaluate the specific item, its real-world value/depreciation, and the financial impact on their monthly balance.",
  "whyNotNeed": "Bulleted markdown points explaining: 1) the psychological impulse trap behind their urgency trigger, 2) cold math opportunity cost (labor hours or compounding), 3) alternative action (cooling off period or smart second-hand alternative).",
  "regretScore": <integer between 10 and 99 representing probability of regret>,
  "recommendations": [
    {
      "title": "Protocol Name (e.g. 72-Hour Anti-FOMO Cooling Chamber)",
      "tag": "Category Tag (e.g. Neuroscience Protocol)",
      "desc": "Actionable advice specific to this item and circumstance."
    },
    {
      "title": "Protocol Name (e.g. Smart Refurbished Alternative)",
      "tag": "Category Tag (e.g. Value Optimization)",
      "desc": "Specific alternative for this item."
    }
  ]
}
''';

      final userPrompt = '''
User: $userName
Base Currency: $baseCurrency
Item Temptation: "$itemName"
Cost: $baseCurrency ${enteredCost.toStringAsFixed(2)}
Urgency Trigger Selected: "$urgencyOption"
Current Discretionary Spending Balance: $baseCurrency ${currentBalance.toStringAsFixed(2)}
Projected Balance if Bought: $baseCurrency ${projectedBalance.toStringAsFixed(2)}
Days Remaining in Month: $remainingDays
Daily Allowance Drop: from $baseCurrency ${oldDaily.toStringAsFixed(2)}/day to $baseCurrency ${newDaily.toStringAsFixed(2)}/day
Monthly Committed Loans/Debt: $baseCurrency ${totalMonthlyLoans.toStringAsFixed(2)}
Upcoming Calendar Bills: $baseCurrency ${upcomingPlannedTotal.toStringAsFixed(2)}
Equivalent Work Hours Required: ${workHours.toStringAsFixed(1)} hours
10-Year Opportunity Cost if Invested @ 8%: $baseCurrency ${tenYearCompound.toStringAsFixed(2)}

Perform a thorough Anti-FOMO analysis and return the strict JSON output.
''';

      try {
        final rawResponse = await _callGemini(
          prompt: userPrompt,
          systemInstruction: systemPrompt,
          temperature: 0.6,
          maxOutputTokens: 1200,
        );

        if (rawResponse != null && rawResponse.isNotEmpty) {
          // Clean possible markdown code fences (```json ... ```)
          String cleaned = rawResponse.trim();
          if (cleaned.startsWith('```')) {
            final firstNewline = cleaned.indexOf('\n');
            if (firstNewline != -1) {
              cleaned = cleaned.substring(firstNewline + 1);
            }
            if (cleaned.endsWith('```')) {
              cleaned = cleaned.substring(0, cleaned.length - 3);
            }
            cleaned = cleaned.trim();
          }

          final Map<String, dynamic> parsed = jsonDecode(cleaned);
          final verdictTitle = parsed['verdictTitle'] as String? ?? '⚠️ IMPULSE CHECK';
          final verdictType = parsed['verdictType'] as String? ?? 'warning';
          final adviceText = parsed['adviceText'] as String? ?? '';
          final whyNotNeed = parsed['whyNotNeed'] as String? ?? '';
          final regretScore = (parsed['regretScore'] as num?)?.toInt() ?? 75;

          final recsList = <Map<String, dynamic>>[];
          if (parsed['recommendations'] is List) {
            for (final r in parsed['recommendations']) {
              if (r is Map) {
                recsList.add({
                  'title': r['title']?.toString() ?? 'Cooling Period',
                  'tag': r['tag']?.toString() ?? 'Psychological Protocol',
                  'desc': r['desc']?.toString() ?? '',
                });
              }
            }
          }

          return GeminiFomoEvaluationResult(
            verdictTitle: verdictTitle,
            verdictType: verdictType,
            adviceText: adviceText,
            whyNotNeed: whyNotNeed,
            regretScore: regretScore.clamp(10, 99),
            recommendations: recsList,
            isRealAi: true,
          );
        }
      } catch (e) {
        debugPrint('[GeminiService] Error evaluating with Gemini: $e (Falling back to local engine)');
      }
    }

    // Offline / Fallback Heuristics
    String vType = 'safe';
    String verdictTitle = 'SAFE TO BUY ✅';
    String adviceText = '';
    String whyNot = '';

    if (projectedBalance < 0) {
      vType = 'danger';
      verdictTitle = '🛑 CRITICAL OVER-BUDGET ALERT!';
      adviceText =
          "$userName, buying '$itemName' for ${AppTheme.formatCurrency(enteredCost)} will completely wipe out your remaining spending balance and plunge you into a negative deficit of ${AppTheme.formatCurrency(projectedBalance.abs())}!";
      whyNot =
          "• Cashflow Crisis: You have $remainingDays days left this month with zero remaining spending margin.\n"
          "• Fixed Obligations: You have ${AppTheme.formatCurrency(totalMonthlyLoans)} committed in monthly installments. Going negative puts your essentials at risk.\n"
          "• Compounding Opportunity: In 10 years, investing this generates ${AppTheme.formatCurrency(tenYearCompound)}.\n"
          "• Psychological Trigger: You selected: '$urgencyOption'. Impulsive purchases from hype or stress carry an 88% regret rate within 2 weeks.";
    } else if (enteredCost > currentBalance * 0.35 || newDaily < 25.0) {
      vType = 'warning';
      verdictTitle = '⚠️ HEAVY DENT IN DAILY ALLOWANCE';
      adviceText =
          "Hey $userName, '$itemName' takes ${(enteredCost / currentBalance * 100).toStringAsFixed(0)}% of your remaining spending pool. Your daily budget will drop from ${AppTheme.formatCurrency(oldDaily)}/day to ${AppTheme.formatCurrency(newDaily)}/day for the next $remainingDays days.";
      whyNot =
          "• Daily Pressure: Surviving on ${AppTheme.formatCurrency(newDaily)}/day for $remainingDays days can cause friction with essentials.\n"
          "• Labor Cost: You must work ${workHours.toStringAsFixed(1)} full hours at your desk to pay for this.\n"
          "• 48-Hour Pause: Give this urge a 48-hour cooling period. If it's still essential, re-evaluate.";
    } else {
      vType = 'safe';
      verdictTitle = '✅ WITHIN BUDGET: APPROVED';
      adviceText =
          "Great financial discipline, $userName! '$itemName' (${AppTheme.formatCurrency(enteredCost)}) is well within your spending allocation. You will still have ${AppTheme.formatCurrency(projectedBalance)} left (${AppTheme.formatCurrency(newDaily)}/day) for the rest of the month.";
      whyNot =
          "• Financial Health: Your upcoming commitments and loan obligations are comfortably buffered.\n"
          "• Guilt-Free: Since this is affordable and leaves ample daily cushion, you can purchase it with confidence!";
    }

    int computedRegret = 70;
    if (urgencyOption.contains('TikTok')) computedRegret = 88;
    if (urgencyOption.contains('Flash Sale')) computedRegret = 84;
    if (urgencyOption.contains('Friends')) computedRegret = 79;
    if (urgencyOption.contains('Stressed')) computedRegret = 74;
    if (urgencyOption.contains('Actually Need')) computedRegret = 24;

    return GeminiFomoEvaluationResult(
      verdictTitle: verdictTitle,
      verdictType: vType,
      adviceText: adviceText,
      whyNotNeed: whyNot,
      regretScore: computedRegret,
      recommendations: [
        {
          'title': '72-Hour Anti-FOMO Cooling Chamber',
          'tag': 'Neuroscience Protocol',
          'desc': 'Neuroscience shows 74% of retail urges are temporary dopamine spikes that fade after 72 hours. Pause before buying "$itemName".',
        },
        {
          'title': 'Smart & Cheaper Alternatives',
          'tag': 'Value Optimization',
          'desc': 'Check secondhand platforms or certified refurbished options for "$itemName" to save up to 40%.',
        },
      ],
      isRealAi: false,
    );
  }

  /// Interactive Anti-FOMO Devil's Advocate Chat powered by Google Gemini
  Future<DevilsAdvocateResponse> generateDevilsAdvocateChat({
    required String userMessage,
    required FinanceState state,
    required String? currentItem,
    required double? currentPrice,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    final userName = state.userName.isNotEmpty ? state.userName : 'friend';
    final balanceLeft = state.spendingBalanceLeft;
    final dailyAllowance = state.aiSafeToSpendRadar.safeDailyAllowance;
    final monthlyIncome = state.totalIncomeThisMonth > 0 ? state.totalIncomeThisMonth : 4500.0;
    final hourlyWage = (monthlyIncome / 160.0).clamp(15.0, 500.0);
    final daysRemaining = state.daysRemainingInMonth;

    double price = currentPrice ?? 150.0;
    String item = (currentItem != null && currentItem.isNotEmpty) ? currentItem : 'this item';

    // Parse potential price/item mentions from user message
    final amountRegex = RegExp(r'(?:rm|\$)?\s*([0-9]+(?:[\.,][0-9]{1,2})?)\s*(?:rm|ringgit|myr|k)?', caseSensitive: false);
    final match = amountRegex.firstMatch(userMessage.toLowerCase());
    if (match != null) {
      final parsed = double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '');
      if (parsed != null && parsed > 0) {
        price = parsed;
        if (userMessage.toLowerCase().contains('k') && price < 100) {
          price *= 1000;
        }
      }
    }

    if (item == 'this item' || item.isEmpty) {
      final itemMatch = RegExp(
        r'(?:buy|get|purchase|want|craving)\s+(?:a|an|the)?\s*([a-zA-Z0-9\s\-]+?)(?:\s+for|\s+at|\s+rm|\s+\$|\s+cost|\?|\.|$)',
        caseSensitive: false,
      ).firstMatch(userMessage);
      if (itemMatch != null) {
        final extracted = itemMatch.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty && extracted.length < 40) {
          item = extracted;
        }
      }
    }

    final workHours = (price / hourlyWage).toStringAsFixed(1);
    final futureValue10Yr = price * pow(1.08, 10);
    final allowanceDropPct = state.monthlySpendingBudget > 0
        ? ((price / state.monthlySpendingBudget) * 100).toStringAsFixed(1)
        : '25.0';
    final newDaily = balanceLeft > price && daysRemaining > 0
        ? (balanceLeft - price) / daysRemaining
        : 0.0;

    final cardData = {
      'price': price,
      'workHours': workHours,
      'futureValue': futureValue10Yr,
      'allowanceDrop': allowanceDropPct,
      'newDaily': newDaily,
      'item': item,
    };

    // If Gemini API is available, ask Gemini to be the Devil's Advocate
    if (hasApiKey) {
      final systemInstruction = '''
You are Blupp's "ANTI-FOMO AI Devil's Advocate".
Your mission: Fiercely and humorously protect $userName from spending money on impulse purchases, flashy gadgets, e-commerce hype sales, BNPL traps, and emotional spending excuses.
Tone: Sharp, candid, psychologically savvy, witty, yet deeply caring for the user's future net worth.
User financial facts:
- Name: $userName
- Remaining discretionary budget: RM ${balanceLeft.toStringAsFixed(2)}
- Days remaining in month: $daysRemaining days
- Safe daily allowance: RM ${dailyAllowance.toStringAsFixed(2)}/day
- Current item under debate: "$item"
- Price: RM ${price.toStringAsFixed(2)}
- Desk labor hours to earn this: $workHours hours
- 10-Year investment future value @ 8%: RM ${futureValue10Yr.toStringAsFixed(2)}
- Allowance after purchase: RM ${newDaily.toStringAsFixed(2)}/day

Instructions:
1. Directly tackle the user's latest message or excuse.
2. Expose the cognitive bias or marketing trap (e.g., BNPL illusion, artificial urgency countdowns, false productivity justification, retail therapy).
3. Throw their cold financial numbers back at them (sweat equity / hours of work, daily allowance pinch, opportunity cost).
4. If the user concedes or agrees to wait/cancel, celebrate their financial discipline and tell them to lock it into the 30-Day Cooling Chamber.
5. Format your output with Markdown (bolding, bullet points).
6. AT THE VERY END OF YOUR RESPONSE, include a JSON block formatted exactly like:
<<<CHIPS
["Option 1", "Option 2", "Option 3", "Option 4"]
CHIPS>>>
Where each option is a short (under 35 chars) quick-reply for the user to reply back with.
''';

      // Build conversation context
      final buffer = StringBuffer();
      final recentHistory = conversationHistory.length > 6
          ? conversationHistory.sublist(conversationHistory.length - 6)
          : conversationHistory;

      for (final msg in recentHistory) {
        final role = (msg['isUser'] == true) ? 'User' : "AI Devil's Advocate";
        buffer.writeln('$role: ${msg['text']}');
      }
      buffer.writeln('User: $userMessage');
      buffer.writeln("AI Devil's Advocate:");

      try {
        final geminiReply = await _callGemini(
          prompt: buffer.toString(),
          systemInstruction: systemInstruction,
          temperature: 0.75,
          maxOutputTokens: 900,
        );

        if (geminiReply != null && geminiReply.isNotEmpty) {
          String replyText = geminiReply;
          List<String> extractedChips = [
            "What if I find a cheaper option?",
            "I'll put it on 30-day cooldown",
            "Can I buy it using installment?",
            "Fine, you win! I'll skip it",
          ];

          final chipsRegex = RegExp(r'<<<CHIPS\s*(\[.*?\])\s*CHIPS>>>', dotAll: true);
          final chipsMatch = chipsRegex.firstMatch(replyText);
          if (chipsMatch != null) {
            try {
              final rawJson = chipsMatch.group(1);
              if (rawJson != null) {
                final list = jsonDecode(rawJson) as List;
                extractedChips = list.map((e) => e.toString()).take(4).toList();
              }
            } catch (_) {}
            replyText = replyText.replaceAll(chipsMatch.group(0)!, '').trim();
          }

          return DevilsAdvocateResponse(
            text: replyText,
            currentPrice: price,
            currentItem: item,
            cardData: cardData,
            suggestedChips: extractedChips,
          );
        }
      } catch (e) {
        debugPrint('[GeminiService] Error generating chat response: $e');
      }
    }

    // Fallback to offline rule engine
    return AiDevilsAdvocateEngine.generateResponse(
      userMessage: userMessage,
      state: state,
      currentItem: item,
      currentPrice: price,
      conversationHistory: conversationHistory,
    );
  }
}
