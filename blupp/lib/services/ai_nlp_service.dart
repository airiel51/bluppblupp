import '../models/finance_state.dart';

class ParsedQuickLog {
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? bankAccountId;
  final String title;
  final DateTime date;
  final double confidence;
  final List<String> detectedEntities;

  const ParsedQuickLog({
    required this.amount,
    required this.type,
    required this.categoryId,
    this.bankAccountId,
    required this.title,
    required this.date,
    required this.confidence,
    required this.detectedEntities,
  });
}

class AiNlpService {
  /// Parses plain English and Malaysian conversational text into a structured transaction
  static ParsedQuickLog? parse(String input, FinanceState state) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final lower = raw.toLowerCase();
    final entities = <String>[];

    // 1. Extract Amount
    // Regex matches: RM 45, rm45.50, $45, 45.00, 45 ringgit, or standalone digits
    double amount = 0.0;
    final amountRegex = RegExp(r'(?:rm|\$)?\s*([0-9]+(?:[\.,][0-9]{1,2})?)\s*(?:rm|ringgit|myr)?', caseSensitive: false);
    final match = amountRegex.firstMatch(lower);

    if (match != null) {
      final numStr = match.group(1)?.replaceAll(',', '.') ?? '0';
      amount = double.tryParse(numStr) ?? 0.0;
      if (amount > 0) {
        entities.add('Amount: RM ${amount.toStringAsFixed(2)}');
      }
    }

    if (amount <= 0) {
      // Look for any numbers in the string
      final fallbackNum = RegExp(r'\b\d+(?:\.\d{1,2})?\b').firstMatch(lower);
      if (fallbackNum != null) {
        amount = double.tryParse(fallbackNum.group(0)!) ?? 0.0;
        if (amount > 0) entities.add('Amount: RM ${amount.toStringAsFixed(2)}');
      }
    }

    // 2. Extract Transaction Type (Income vs Expense)
    TransactionType type = TransactionType.expense;
    const incomeKeywords = [
      'salary', 'gaji', 'income', 'earned', 'received', 'got', 'bonus',
      'freelance', 'dividend', 'cashback', 'profit', 'claim', 'refund', 'inflow'
    ];
    for (final kw in incomeKeywords) {
      if (lower.contains(kw)) {
        type = TransactionType.income;
        entities.add('Type: Income');
        break;
      }
    }
    if (type == TransactionType.expense) {
      entities.add('Type: Expense');
    }

    // 3. Extract Category
    String categoryId = type == TransactionType.income ? 'salary' : 'food';

    if (type == TransactionType.income) {
      if (lower.contains('freelance') || lower.contains('project') || lower.contains('side hustle') || lower.contains('gig')) {
        categoryId = 'freelance';
      } else if (lower.contains('dividend') || lower.contains('interest') || lower.contains('asnb') || lower.contains('invest')) {
        categoryId = 'dividend';
      } else if (lower.contains('bonus') || lower.contains('cashback') || lower.contains('reward') || lower.contains('angpow')) {
        categoryId = 'bonus';
      } else {
        categoryId = 'salary';
      }
    } else {
      // Expense Category Mapping
      if (_hasAny(lower, ['grab', 'petrol', 'shell', 'petronas', 'ron95', 'parking', 'toll', 'tng', 'touch n go', 'mrt', 'lrt', 'bus', 'fuel', 'car service'])) {
        categoryId = 'transport';
      } else if (_hasAny(lower, ['shopee', 'lazada', 'tiktok', 'uniqlo', 'zara', 'shopping', 'shoes', 'clothes', 'keyboard', 'gadget', 'haul', 'buy', 'bought'])) {
        categoryId = 'shopping';
      } else if (_hasAny(lower, ['netflix', 'spotify', 'cinema', 'movie', 'game', 'steam', 'playstation', 'concert', 'karaoke', 'fun'])) {
        categoryId = 'entertainment';
      } else if (_hasAny(lower, ['pasar', 'groceries', 'grocery', 'supermarket', 'lotus', 'jaya grocer', 'village grocer', 'aeon', 'market', 'telur', 'beras'])) {
        categoryId = 'groceries';
      } else if (_hasAny(lower, ['pharmacy', 'clinic', 'doctor', 'medicine', 'panadol', 'hospital', 'dentist', 'watsons', 'guardian', 'health', 'supplement'])) {
        categoryId = 'health';
      } else if (_hasAny(lower, ['spaylater', 'loan', 'repay', 'repayment', 'instalment', 'debt', 'hutang', 'bayar hutang', 'car loan'])) {
        categoryId = 'loan_repay';
      } else if (_hasAny(lower, ['tnb', 'electric', 'water', 'unifi', 'maxis', 'celcom', 'digi', 'bill', 'wifi', 'rent', 'sewa', 'utilities'])) {
        categoryId = 'utilities';
      } else if (_hasAny(lower, ['lunch', 'dinner', 'breakfast', 'makan', 'coffee', 'kopi', 'starbucks', 'zus', 'mcd', 'kfc', 'burger', 'tea', 'nasi', 'ayam', 'food', 'cafe', 'boba', 'biscuit'])) {
        categoryId = 'food';
      } else {
        categoryId = 'other_exp';
      }
    }
    entities.add('Category: $categoryId');

    // 4. Extract Bank Account
    String? bankId;
    if (state.bankAccounts.isNotEmpty) {
      if (_hasAny(lower, ['maybank', 'mb', 'mae', 'yellow'])) {
        final found = state.bankAccounts.where((b) => b.name.toLowerCase().contains('maybank'));
        if (found.isNotEmpty) bankId = found.first.id;
      } else if (_hasAny(lower, ['cimb', 'red bank', 'cimbclicks'])) {
        final found = state.bankAccounts.where((b) => b.name.toLowerCase().contains('cimb'));
        if (found.isNotEmpty) bankId = found.first.id;
      } else if (_hasAny(lower, ['islam', 'bank islam', 'green'])) {
        final found = state.bankAccounts.where((b) => b.name.toLowerCase().contains('islam'));
        if (found.isNotEmpty) bankId = found.first.id;
      }
      bankId ??= state.bankAccounts.first.id;
      final matchedBank = state.getBankById(bankId);
      if (matchedBank != null) {
        entities.add('Account: ${matchedBank.name}');
      }
    }

    // 5. Extract Date
    DateTime date = DateTime.now();
    if (_hasAny(lower, ['yesterday', 'semalam'])) {
      date = date.subtract(const Duration(days: 1));
      entities.add('Date: Yesterday');
    } else {
      entities.add('Date: Today');
    }

    // 6. Clean Title
    String title = raw;
    // Strip common prefixes
    final stopWords = [
      'spent', 'paid', 'bought', 'bought for', 'spent on', 'spent rm', 'paid rm',
      'received', 'got', 'earned', 'for', 'with', 'using', 'at', 'on', 'semalam', 'yesterday'
    ];
    String cleaned = raw;
    // Remove amount substring
    cleaned = cleaned.replaceAll(amountRegex, ' ');
    // Remove matched bank name
    cleaned = cleaned.replaceAll(RegExp(r'\b(maybank|cimb|bank islam|islam|cash|wallet)\b', caseSensitive: false), ' ');
    // Remove standalone stop words
    for (final sw in stopWords) {
      cleaned = cleaned.replaceAll(RegExp('\\b$sw\\b', caseSensitive: false), ' ');
    }
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length > 2) {
      // Capitalize first letter
      title = cleaned[0].toUpperCase() + cleaned.substring(1);
    } else {
      // Fallback title to category name
      final cat = state.getCategoryById(categoryId);
      title = cat.name;
    }

    final confidence = (amount > 0 ? 0.95 : 0.60);

    return ParsedQuickLog(
      amount: amount,
      type: type,
      categoryId: categoryId,
      bankAccountId: bankId,
      title: title,
      date: date,
      confidence: confidence,
      detectedEntities: entities,
    );
  }

  static bool _hasAny(String text, List<String> words) {
    for (final w in words) {
      if (text.contains(w)) return true;
    }
    return false;
  }
}
