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
  String? _lastProcessedQuery;
  String? _lastProcessedAction;

  /// Initializes deep link and Web URL parameter listening (for both native app and Web PWA on iPhone)
  void init({
    required Function(ParsedQuickLog parsed, String rawText) onTransactionDetected,
    VoidCallback? onOpenQuickLog,
    required FinanceState financeState,
  }) {
    // 1. Web PWA on iPhone: Check current browser URL for `?log=...` or `?text=...` or `?action=add`
    _handleIncomingUri(Uri.base, onTransactionDetected, onOpenQuickLog, financeState);

    // 2. Handle incoming links while app is running
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingUri(uri, onTransactionDetected, onOpenQuickLog, financeState);
      },
      onError: (_) {},
    );

    // 3. Handle initial app link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleIncomingUri(uri, onTransactionDetected, onOpenQuickLog, financeState);
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
    VoidCallback? onOpenQuickLog,
    FinanceState financeState,
  ) {
    String? text;
    bool shouldOpenQuickLog = false;

    if (uri.scheme == 'blupp') {
      // Native URL scheme: blupp://log?text=... or blupp://add
      if (uri.host == 'add' || uri.path == '/add' || uri.queryParameters['action'] == 'add' || uri.queryParameters.containsKey('add')) {
        shouldOpenQuickLog = true;
      }
      text = uri.queryParameters['text'] ??
          uri.queryParameters['log'] ??
          uri.queryParameters['content'] ??
          uri.queryParameters['msg'] ??
          (uri.path != '/add' && uri.host != 'add' ? uri.path.replaceFirst('/', '') : null);
    } else if (uri.scheme == 'http' || uri.scheme == 'https') {
      // Web PWA URL: https://your-blupp-url.com/?log=... or /?action=add
      final action = uri.queryParameters['action'] ?? uri.queryParameters['open'];
      if (action == 'add' || action == 'quick' || uri.queryParameters.containsKey('add') || uri.queryParameters.containsKey('quick')) {
        shouldOpenQuickLog = true;
      }
      text = uri.queryParameters['log'] ??
          uri.queryParameters['text'] ??
          uri.queryParameters['content'] ??
          uri.queryParameters['msg'];

      // Also support Flutter hash routes: /#/?action=add or /#/?log=...
      if (uri.hasFragment) {
        final frag = uri.fragment;
        final qIndex = frag.indexOf('?');
        if (qIndex != -1) {
          final queryStr = frag.substring(qIndex + 1);
          final params = Uri.splitQueryString(queryStr);
          if (params['action'] == 'add' || params['open'] == 'add' || params.containsKey('add') || params.containsKey('quick')) {
            shouldOpenQuickLog = true;
          }
          text ??= params['log'] ?? params['text'] ?? params['content'] ?? params['msg'];
        }
      }
    }

    if (shouldOpenQuickLog) {
      final actionKey = "${uri.path}_${uri.query}_${uri.fragment}";
      if (actionKey != _lastProcessedAction) {
        _lastProcessedAction = actionKey;
        Future.microtask(() => onOpenQuickLog?.call());
      }
    }

    if (text != null && text.trim().isNotEmpty && text != _lastProcessedQuery) {
      _lastProcessedQuery = text;
      final decoded = Uri.decodeComponent(text.trim());
      final parsed = AiNlpService.parse(decoded, financeState);
      if (parsed != null && parsed.amount > 0) {
        onTransactionDetected(parsed, decoded);
      }
    }
  }

  /// Explicit user-tap paste action (100% reliable on iOS Safari & Web PWAs)
  Future<ParsedQuickLog?> pasteFromClipboard(FinanceState financeState) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty) return null;

      final parsed = AiNlpService.parse(text, financeState);
      if (parsed != null && parsed.amount > 0) {
        _lastCopiedText = text;
        return parsed;
      }
    } catch (_) {}
    return null;
  }

  /// Checks the system clipboard for a copied bank notification or SMS receipt
  Future<ParsedQuickLog?> checkClipboardForTransaction(FinanceState financeState) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty || text == _lastCopiedText) {
        return null;
      }

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
    } catch (_) {}
    return null;
  }
}
