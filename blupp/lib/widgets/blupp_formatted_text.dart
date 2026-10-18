import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Formats and renders Markdown-styled text (headings, bold, italics, bullets)
/// cleanly using native Flutter TextSpans without displaying raw Markdown
/// symbols like `###`, `**`, `*`, or `__`.
class BluppFormattedText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final bool isUser;
  final Color? accentColor;

  const BluppFormattedText({
    super.key,
    required this.text,
    this.baseStyle,
    this.isUser = false,
    this.accentColor,
  });

  /// Utility to strip markdown symbols for plain-text contexts (e.g. notifications)
  static String stripMarkdown(String input) {
    var cleaned = input;
    // Remove headers
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    // Remove bold/italics
    cleaned = cleaned.replaceAll('***', '');
    cleaned = cleaned.replaceAll('**', '');
    cleaned = cleaned.replaceAll('___', '');
    cleaned = cleaned.replaceAll('__', '');
    // Remove standalone bullets
    cleaned = cleaned.replaceAll(RegExp(r'^[\*\-]\s+', multiLine: true), '• ');
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBase = baseStyle ??
        TextStyle(
          color: isUser ? Colors.white : AppTheme.textPrimary,
          fontSize: 13.5,
          height: 1.45,
        );

    final effectiveAccent = accentColor ?? (isUser ? Colors.white : const Color(0xFFA78BFA));

    final lines = text.split('\n');
    final widgets = <Widget>[];
    bool lastWasSpacer = false;

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final trimmed = rawLine.trim();

      if (trimmed.isEmpty) {
        if (!lastWasSpacer && widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 8));
          lastWasSpacer = true;
        }
        continue;
      }
      lastWasSpacer = false;

      // 1. Heading check: ###, ##, #
      final headingMatch = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(trimmed);
      if (headingMatch != null) {
        final headingText = headingMatch.group(1) ?? '';
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: widgets.isEmpty ? 0 : 8,
              bottom: 4,
            ),
            child: Text.rich(
              TextSpan(
                children: _parseInline(
                  headingText,
                  effectiveBase.copyWith(
                    fontSize: (effectiveBase.fontSize ?? 13.5) + 1.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isUser ? Colors.white : const Color(0xFFF1F5F9),
                  ),
                  effectiveAccent,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      // 2. Bullet list check: * item, - item, • item
      final bulletMatch = RegExp(r'^(\*|-|•)\s+(.*)$').firstMatch(trimmed);
      if (bulletMatch != null) {
        final bulletContent = bulletMatch.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2.5, bottom: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: 6),
                  child: Text(
                    "•",
                    style: TextStyle(
                      color: effectiveAccent,
                      fontSize: (effectiveBase.fontSize ?? 13.5) + 1,
                      fontWeight: FontWeight.w800,
                      height: effectiveBase.height ?? 1.45,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInline(
                        bulletContent,
                        effectiveBase,
                        effectiveAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 3. Numbered list check: 1. item, 2) item
      final numMatch = RegExp(r'^(\d+[\.\)])\s+(.*)$').firstMatch(trimmed);
      if (numMatch != null) {
        final numPrefix = numMatch.group(1) ?? '1.';
        final numContent = numMatch.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2.5, bottom: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    numPrefix,
                    style: TextStyle(
                      color: effectiveAccent,
                      fontSize: effectiveBase.fontSize ?? 13.5,
                      fontWeight: FontWeight.w700,
                      height: effectiveBase.height ?? 1.45,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseInline(
                        numContent,
                        effectiveBase,
                        effectiveAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 4. Regular paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(
            TextSpan(
              children: _parseInline(
                rawLine,
                effectiveBase,
                effectiveAccent,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Parses inline styling: bold (**text**, __text__), italics (*text*, _text_), bold italics (***text***)
  List<InlineSpan> _parseInline(String input, TextStyle base, Color accent) {
    final spans = <InlineSpan>[];
    final boldStyle = base.copyWith(
      fontWeight: FontWeight.w700,
      color: isUser ? Colors.white : AppTheme.textPrimary,
    );
    final italicStyle = base.copyWith(
      fontStyle: FontStyle.italic,
    );
    final boldItalicStyle = base.copyWith(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: isUser ? Colors.white : AppTheme.textPrimary,
    );

    // Regex for inline patterns
    final pattern = RegExp(
      r'(\*\*\*(.+?)\*\*\*|\*\*(.+?)\*\*|\*(.+?)\*|___(.+?)___|__(.+?)__|_([^_]+?)_)',
      dotAll: true,
    );

    int lastIndex = 0;
    for (final match in pattern.allMatches(input)) {
      if (match.start > lastIndex) {
        final textSlice = input.substring(lastIndex, match.start);
        final cleanText = _cleanRawMarkdownSymbols(textSlice);
        if (cleanText.isNotEmpty) {
          spans.add(TextSpan(text: cleanText, style: base));
        }
      }

      final boldItalic1 = match.group(2);
      final bold1 = match.group(3);
      final italic1 = match.group(4);
      final boldItalic2 = match.group(5);
      final bold2 = match.group(6);
      final italic2 = match.group(7);

      if (boldItalic1 != null && boldItalic1.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(boldItalic1), style: boldItalicStyle));
      } else if (bold1 != null && bold1.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(bold1), style: boldStyle));
      } else if (italic1 != null && italic1.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(italic1), style: italicStyle));
      } else if (boldItalic2 != null && boldItalic2.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(boldItalic2), style: boldItalicStyle));
      } else if (bold2 != null && bold2.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(bold2), style: boldStyle));
      } else if (italic2 != null && italic2.isNotEmpty) {
        spans.add(TextSpan(text: _cleanRawMarkdownSymbols(italic2), style: italicStyle));
      }

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      final textSlice = input.substring(lastIndex);
      final cleanText = _cleanRawMarkdownSymbols(textSlice);
      if (cleanText.isNotEmpty) {
        spans.add(TextSpan(text: cleanText, style: base));
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: _cleanRawMarkdownSymbols(input), style: base));
    }

    return spans;
  }

  /// Strips any leftover unclosed markdown syntax like `###`, `**`, `*`, `__`
  String _cleanRawMarkdownSymbols(String s) {
    return s
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('*', '');
  }
}
