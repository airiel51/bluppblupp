import 'dart:async';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import '../models/finance_state.dart';
import 'ai_nlp_service.dart';

class IosShortcutService {
  static final IosShortcutService instance = IosShortcutService._();
  IosShortcutService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastCopiedText;

  /// Initializes deep link listening for `blupp://log?text=...`
  void init({
    required Function(ParsedQuickLog parsed, String rawText) onTransactionDetected,
    required FinanceState financeState,
  }) {
    // 1. Handle incoming link while app is running in background or foreground
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingUri(uri, onTransactionDetected, financeState);
      },
      onError: (err) {
        // Silently catch link errors
      },
    );

    // 2. Handle initial link if app was launched via URL scheme
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleIncomingUri(uri, onTransactionDetected, financeState);
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  void _handleIncomingUri(
    Uri uri,
    Function(ParsedQuickLog parsed, String rawText) onTransactionDetected,
    FinanceState financeState,
  ) {
    if (uri.scheme == 'blupp') {
      // e.g. blupp://log?text=Paid+RM+35+at+Starbucks
      // or blupp://quick-log?text=...
      final text = uri.queryParameters['text'] ??
          uri.queryParameters['content'] ??
          uri.queryParameters['msg'] ??
          uri.path.replaceFirst('/', '');

      if (text.trim().isNotEmpty) {
        final decoded = Uri.decodeComponent(text.trim());
        final parsed = AiNlpService.parse(decoded, financeState);
        if (parsed != null && parsed.amount > 0) {
          onTransactionDetected(parsed, decoded);
        }
      }
    }
  }

  /// Checks the system clipboard for a copied bank notification or SMS receipt
  Future<ParsedQuickLog?> checkClipboardForTransaction(FinanceState financeState) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty || text == _lastCopiedText) {
        return null;
      }

      // Check if text looks like a Malaysian or global financial transaction
      final hasAmount = RegExp(r'(?:rm|\$|myr)?\s*\d+(?:[\.,]\d{1,2})?', caseSensitive: false).hasMatch(text);
      final hasBankKeyword = RegExp(
        r'(duitnow|transfer|paid|maybank|cimb|tng|touch\s*n\s*go|shopeepay|grabpay|debit|credit|purchase|bayaran|transaksi)',
        caseSensitive: false,
      ).hasMatch(text);

      if (hasAmount && (hasBankKeyword || text.length < 80)) {
        final parsed = AiNlpService.parse(text, financeState);
        if (parsed != null && parsed.amount > 0) {
          _lastCopiedText = text;
          return parsed;
        }
      }
    } catch (_) {
      // Ignore clipboard read permission denials
    }
    return null;
  }
}
