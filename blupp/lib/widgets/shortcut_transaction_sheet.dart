import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_state.dart';
import '../services/ai_nlp_service.dart';
import '../theme/app_theme.dart';

class ShortcutTransactionSheet extends StatefulWidget {
  final ParsedQuickLog parsed;
  final String rawText;
  final String sourceLabel;
  final FinanceState state;

  const ShortcutTransactionSheet({
    super.key,
    required this.parsed,
    required this.rawText,
    required this.state,
    this.sourceLabel = 'Apple Shortcut Automation',
  });

  static Future<void> show({
    required BuildContext context,
    required ParsedQuickLog parsed,
    required String rawText,
    required FinanceState state,
    String sourceLabel = 'Apple Shortcut Automation',
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ShortcutTransactionSheet(
        parsed: parsed,
        rawText: rawText,
        state: state,
        sourceLabel: sourceLabel,
      ),
    );
  }

  @override
  State<ShortcutTransactionSheet> createState() => _ShortcutTransactionSheetState();
}

class _ShortcutTransactionSheetState extends State<ShortcutTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategoryId;
  late TransactionType _type;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.parsed.title);
    _amountController = TextEditingController(text: widget.parsed.amount.toStringAsFixed(2));
    _selectedCategoryId = widget.parsed.categoryId;
    _type = widget.parsed.type;

    if (widget.state.bankAccounts.isNotEmpty) {
      _selectedAccountId = widget.state.bankAccounts.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = _type == TransactionType.expense;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Badge & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text(
                      widget.sourceLabel,
                      style: const TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            "Transaction Detected",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Parsed automatically from your bank SMS or notification:",
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Raw Detected Snippet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryTeal, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.rawText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Title & Amount Inputs
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Merchant / Title",
                    labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: isExpense ? AppTheme.expenseCoral : AppTheme.incomeMint,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount (RM)",
                    labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            dropdownColor: AppTheme.surface,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: "Category",
              labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: widget.state.categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat.id,
                child: Row(
                  children: [
                    Icon(cat.icon, size: 16, color: cat.color),
                    const SizedBox(width: 8),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategoryId = val);
            },
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Dismiss", style: TextStyle(color: AppTheme.textMuted)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text("Save Transaction", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (amount <= 0 || title.isEmpty) return;

    final bankId = _selectedAccountId ??
        (widget.state.bankAccounts.isNotEmpty
            ? widget.state.bankAccounts.first.id
            : 'default_account');

    widget.state.addTransaction(
      TransactionItem(
        id: 'tx_shortcut_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId,
        bankAccountId: bankId,
        date: DateTime.now(),
        note: 'Auto-detected via ${widget.sourceLabel}',
      ),
    );

    HapticFeedback.lightImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ Logged RM ${amount.toStringAsFixed(2)} for $title!"),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
