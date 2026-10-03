import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../services/ai_nlp_service.dart';
import '../services/universal_speech/universal_speech.dart';
import '../theme/app_theme.dart';
import 'ai_receipt_scanner_sheet.dart';

class AiQuickLogSheet extends StatefulWidget {
  final FinanceState state;

  const AiQuickLogSheet({super.key, required this.state});

  @override
  State<AiQuickLogSheet> createState() => _AiQuickLogSheetState();
}

class _AiQuickLogSheetState extends State<AiQuickLogSheet> {
  final TextEditingController _promptController = TextEditingController();
  ParsedQuickLog? _parsed;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _promptController.addListener(() {
      final res = AiNlpService.parse(_promptController.text, widget.state);
      setState(() {
        _parsed = res;
      });
    });
  }

  @override
  void dispose() {
    if (_isListening) {
      UniversalSpeech.stopListening();
    }
    _promptController.dispose();
    super.dispose();
  }

  void _toggleVoiceRecognition() {
    if (_isListening) {
      UniversalSpeech.stopListening();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
    });

    UniversalSpeech.startListening(
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _promptController.text = transcript;
          _promptController.selection = TextSelection.fromPosition(TextPosition(offset: transcript.length));
          if (isFinal) {
            _isListening = false;
          }
        });
      },
      onStatus: (listening, error) {
        if (!mounted) return;
        setState(() {
          _isListening = listening;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Microphone Notice: $error")),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      },
    );
  }

  void _applyPrompt(String text) {
    _promptController.text = text;
    _promptController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  void _confirmAndLog() {
    if (_parsed == null || _parsed!.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify an amount to log (e.g. RM 25)')),
      );
      return;
    }

    final newTx = TransactionItem(
      id: "nlp_${DateTime.now().millisecondsSinceEpoch}",
      title: _parsed!.title,
      amount: _parsed!.amount,
      type: _parsed!.type,
      categoryId: _parsed!.categoryId,
      date: _parsed!.date,
      bankAccountId: _parsed!.bankAccountId ?? (widget.state.bankAccounts.isNotEmpty ? widget.state.bankAccounts.first.id : ''),
      note: "AI Natural Language Log",
    );

    widget.state.addTransaction(newTx);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Logged ${_parsed!.type == TransactionType.income ? 'Income' : 'Expense'}: ${newTx.title} (${AppTheme.formatCurrency(newTx.amount)})",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = _parsed != null ? widget.state.getCategoryById(_parsed!.categoryId) : null;
    final bank = _parsed?.bankAccountId != null ? widget.state.getBankById(_parsed!.bankAccountId!) : null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "AI Natural Language Logger",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "NLP ENGINE",
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Type or speak in plain English or Malay slang",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Main Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Natural Language Input Box with Voice Mic
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isListening
                            ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                            : const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: _isListening ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promptController,
                                autofocus: true,
                                maxLines: 2,
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.4),
                                decoration: InputDecoration(
                                  hintText: _isListening
                                      ? "🎙️ Listening... Speak transaction in English/BM..."
                                      : "e.g. 'Lunch RM 18 with Maybank' or 'Grab 28 semalam'",
                                  hintStyle: TextStyle(
                                    color: _isListening ? const Color(0xFF10B981) : AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Microphone Toggle Action
                            InkWell(
                              onTap: _toggleVoiceRecognition,
                              borderRadius: BorderRadius.circular(22),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                      : const Color(0xFF10B981).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isListening
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF10B981).withValues(alpha: 0.4),
                                    width: _isListening ? 1.8 : 1.0,
                                  ),
                                  boxShadow: _isListening
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                                  color: _isListening ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Active Listening Status Ribbon
                        if (_isListening) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 400.ms),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Listening... Speak clearly into microphone",
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                InkWell(
                                  onTap: _toggleVoiceRecognition,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Done",
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isListening ? "Say amount, category & bank" : "AI parses category, amount, bank & date",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                            if (_promptController.text.isNotEmpty)
                              InkWell(
                                onTap: () => _promptController.clear(),
                                child: Text(
                                  "Clear",
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Real-Time NLP Extraction Preview Card
                  if (_parsed != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Live AI Extraction",
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _parsed!.type == TransactionType.income
                                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                      : const Color(0xFFFF5252).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _parsed!.type == TransactionType.income ? "+ INCOME" : "- EXPENSE",
                                  style: TextStyle(
                                    color: _parsed!.type == TransactionType.income ? const Color(0xFF10B981) : const Color(0xFFFF5252),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Extracted Fields Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildPreviewTile(
                                  "Amount",
                                  _parsed!.amount > 0 ? AppTheme.formatCurrency(_parsed!.amount) : "Detecting...",
                                  Icons.payments_rounded,
                                  const Color(0xFF00E5FF),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPreviewTile(
                                  "Category",
                                  cat?.name ?? "General",
                                  cat?.icon ?? Icons.category_rounded,
                                  cat?.color ?? Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPreviewTile(
                                  "Bank Account",
                                  bank?.name ?? "Auto (Primary)",
                                  Icons.account_balance_rounded,
                                  bank?.color ?? Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPreviewTile(
                                  "Title",
                                  _parsed!.title,
                                  Icons.edit_note_rounded,
                                  Colors.white70,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Log button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_rounded, size: 18),
                              label: Text("Confirm & Log ${_parsed!.amount > 0 ? AppTheme.formatCurrency(_parsed!.amount) : ''}"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              onPressed: _confirmAndLog,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 20),
                  ],

                  // Quick Inspiration Presets
                  Text(
                    "Try One-Tap Prompts",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip("🍜 Ramen RM 32 with Maybank"),
                      _buildPresetChip("⛽ Shell Petrol RM 50 CIMB"),
                      _buildPresetChip("💼 Freelance UI project RM 800 Bank Islam"),
                      _buildPresetChip("🍿 Cinema ticket RM 22"),
                      _buildPresetChip("🛒 Lotus groceries RM 115 CIMB"),
                      _buildPresetChip("💊 Panadol pharmacy RM 14"),
                      _buildPresetChip("⚡ TNB electric bill RM 135"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Alternative: Scan Receipt Instead
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.document_scanner_rounded, color: Color(0xFF00E5FF), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Prefer scanning paper or QR?",
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "Use AI Vision to extract items directly from photo",
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AiReceiptScannerSheet(state: widget.state),
                            );
                          },
                          child: const Text("Scan QR", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String prompt) {
    return InkWell(
      onTap: () => _applyPrompt(prompt),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Text(
          prompt,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
