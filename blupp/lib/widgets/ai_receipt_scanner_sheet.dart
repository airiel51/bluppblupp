import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../models/finance_state.dart';
import '../services/ai_receipt_scanner_service.dart';
import '../theme/app_theme.dart';

class AiReceiptScannerSheet extends StatefulWidget {
  final FinanceState state;

  const AiReceiptScannerSheet({super.key, required this.state});

  @override
  State<AiReceiptScannerSheet> createState() => _AiReceiptScannerSheetState();
}

class _AiReceiptScannerSheetState extends State<AiReceiptScannerSheet> {
  bool _isScanning = false;
  ScannedReceiptResult? _scannedResult;

  // Editable Controllers
  final TextEditingController _merchantCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  String _selectedCategoryId = 'food';
  String _selectedBankId = '';

  @override
  void initState() {
    super.initState();
    if (widget.state.bankAccounts.isNotEmpty) {
      _selectedBankId = widget.state.bankAccounts.first.id;
    }
  }

  void _applyResult(ScannedReceiptResult result) {
    setState(() {
      _scannedResult = result;
      _merchantCtrl.text = result.merchantName;
      _amountCtrl.text = result.totalAmount.toStringAsFixed(2);
      _selectedCategoryId = result.suggestedCategoryId;
      _selectedBankId = result.suggestedBankId;
      _isScanning = false;
    });
  }

  Future<void> _startScan(ImageSource source) async {
    // Call scanReceipt directly within the user gesture without prior setState
    // to prevent Safari on iOS from blocking the file/camera dialog
    final res = await AiReceiptScannerService.scanReceipt(
      source: source,
      state: widget.state,
      onImagePicked: () {
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      },
    );

    if (res != null) {
      _applyResult(res);
    } else {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _saveExpense() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final newTx = TransactionItem(
      id: "scan_${DateTime.now().millisecondsSinceEpoch}",
      title: _merchantCtrl.text.trim().isNotEmpty ? _merchantCtrl.text.trim() : "Scanned Receipt",
      amount: amount,
      type: TransactionType.expense,
      categoryId: _selectedCategoryId,
      date: _scannedResult?.date ?? DateTime.now(),
      bankAccountId: _selectedBankId.isNotEmpty ? _selectedBankId : (widget.state.bankAccounts.isNotEmpty ? widget.state.bankAccounts.first.id : ''),
      note: "AI Vision Scan: ${_scannedResult?.receiptType ?? 'Receipt'}",
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
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Logged ${newTx.title} (${AppTheme.formatCurrency(amount)}) via AI Vision!",
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Color(0xFF00E5FF), size: 22),
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
                              "AI Receipt & QR Scanner",
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
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "VISION AI",
                              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Scan invoices, paper receipts & DuitNow QR screenshots",
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
            child: _isScanning
                ? _buildScanningLoader()
                : _scannedResult == null
                    ? _buildCaptureChoiceScreen()
                    : _buildResultFormScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureChoiceScreen() {
    final demos = AiReceiptScannerService.getDemoPresets(widget.state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Capture Dock
          Row(
            children: [
              Expanded(
                child: _buildSourceCard(
                  title: "Camera",
                  subtitle: "Snap physical receipt",
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFF38BDF8),
                  onTap: () => _startScan(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSourceCard(
                  title: "Photos / Gallery",
                  subtitle: "Upload DuitNow QR screenshot",
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _startScan(ImageSource.gallery),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text(
                "Instant Malaysian Presets (Try with 1-Tap)",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...demos.map((d) => _buildDemoCard(d)),
        ],
      ),
    );
  }

  Widget _buildSourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(ScannedReceiptResult demo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 20),
        ),
        title: Text(
          demo.merchantName,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${demo.receiptType} • ${demo.lineItems.length} items parsed",
          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppTheme.formatCurrency(demo.totalAmount),
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
        onTap: () => _applyResult(demo),
      ),
    );
  }

  Widget _buildScanningLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFF00E5FF), width: 2),
            ),
            child: const Icon(Icons.document_scanner_rounded, size: 54, color: Color(0xFF00E5FF)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 800.ms),
          const SizedBox(height: 24),
          Text(
            "Analyzing Receipt Neural Vectors...",
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Extracting merchant, SST tax, items, and total amount",
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultFormScreen() {
    final res = _scannedResult!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  "AI Extraction: ${(res.confidence * 100).toStringAsFixed(1)}% Confidence (${res.receiptType})",
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Merchant Field
          Text("Merchant / Payee Name", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _merchantCtrl,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.surfaceBorder)),
            ),
          ),

          const SizedBox(height: 14),

          // Amount Field
          Text("Extracted Grand Total (RM)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 22, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              prefixText: "RM ",
              prefixStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 20),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.surfaceBorder)),
            ),
          ),

          const SizedBox(height: 14),

          // Category Selector
          Text("Category", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.state.categories
                  .where((c) => c.type == TransactionType.expense)
                  .map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? cat.color : AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 14, color: isSelected ? cat.color : AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Bank Account Selector
          Text("Deducted From Account", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.state.bankAccounts.map((b) {
                final isSelected = _selectedBankId == b.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBankId = b.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? b.color.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? b.color : AppTheme.surfaceBorder),
                    ),
                    child: Text(
                      b.name,
                      style: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Itemized Lines List
          if (res.lineItems.isNotEmpty) ...[
            Text("Extracted Line Items", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                children: res.lineItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 5, color: Color(0xFF00E5FF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(item, style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text("Log This Expense Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              onPressed: _saveExpense,
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _scannedResult = null),
              child: Text("Scan Another Receipt", style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
