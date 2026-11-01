import 'package:flutter/material.dart';
import '../models/finance_state.dart';
import '../models/currency_model.dart';
import '../theme/app_theme.dart';
import 'blupp_forms.dart';

/// Interactive modal sheet to create new transactions, backfill forgotten past transactions,
/// or edit existing transactions with full date/time control and bank reconciliation toggle.
class AddTransactionModal extends StatefulWidget {
  final FinanceState state;
  final DateTime? preselectedDate;
  final TransactionItem? existingTx;
  final TransactionType? initialType;

  const AddTransactionModal({
    super.key,
    required this.state,
    this.preselectedDate,
    this.existingTx,
    this.initialType,
  });

  static Future<void> show(
    BuildContext context, {
    required FinanceState state,
    DateTime? preselectedDate,
    TransactionItem? existingTx,
    TransactionType? initialType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTransactionModal(
        state: state,
        preselectedDate: preselectedDate,
        existingTx: existingTx,
        initialType: initialType,
      ),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _activeType;
  late String _selectedCatId;
  late String _selectedBankId;
  late String _selectedCurrency;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _updateBankBalance = true;

  String? _errorWhere;
  String? _errorWhy;

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTx;
    final now = DateTime.now();

    if (tx != null) {
      _titleController = TextEditingController(text: tx.title);
      _amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));
      _noteController = TextEditingController(text: tx.note ?? '');
      _activeType = tx.type;
      _selectedCatId = tx.categoryId;
      _selectedBankId = tx.bankAccountId;
      _selectedCurrency = widget.state.baseCurrency;
      _selectedDate = tx.date;
      _selectedTime = TimeOfDay.fromDateTime(tx.date);
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _activeType = widget.initialType ?? TransactionType.expense;
      _selectedCatId = _activeType == TransactionType.expense ? 'food' : 'salary';
      _selectedBankId = widget.state.bankAccounts.isNotEmpty ? widget.state.bankAccounts.first.id : '';
      _selectedCurrency = widget.state.baseCurrency;
      _selectedDate = widget.preselectedDate ?? now;
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isPastDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return target.isBefore(today);
  }

  String _formatFriendlyDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;

    final hour = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final ampm = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = "$hour:$minute $ampm";

    if (diff == 0) return "Today at $timeStr";
    if (diff == 1) return "Yesterday at $timeStr";
    if (diff == 2) return "2 days ago at $timeStr";

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return "${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year} ($timeStr)";
  }

  Future<void> _pickCustomDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.black,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppTheme.primaryTeal,
                onPrimary: Colors.black,
                surface: AppTheme.surface,
                onSurface: AppTheme.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      setState(() {
        _selectedDate = pickedDate;
        if (pickedTime != null) {
          _selectedTime = pickedTime;
        }
      });
    }
  }

  void _setDatePreset(int daysAgo) {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now.subtract(Duration(days: daysAgo));
      if (daysAgo == 0) {
        _selectedTime = TimeOfDay.fromDateTime(now);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = widget.state.categories
        .where((c) => c.type == _activeType)
        .toList();
    final isEditing = widget.existingTx != null;
    final selectedBank = widget.state.getBankById(_selectedBankId);
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isPastDate
                            ? AppTheme.warningAmber.withValues(alpha: 0.15)
                            : AppTheme.primaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isPastDate ? Icons.history_rounded : (isEditing ? Icons.edit_note_rounded : Icons.add_card_rounded),
                        color: _isPastDate ? AppTheme.warningAmber : AppTheme.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? "Edit Transaction"
                              : (_isPastDate ? "Log Forgotten Entry" : "New Transaction"),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          _isPastDate
                              ? "Backdated to ${_formatFriendlyDate(_selectedDate)}"
                              : "Record financial activity",
                          style: TextStyle(
                            color: _isPastDate ? AppTheme.warningAmber : AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_errorWhere != null && _errorWhy != null) ...[
              BluppFieldError(where: _errorWhere!, why: _errorWhy!),
              const SizedBox(height: 12),
            ],

            // 1. Transaction Type (Expense / Income)
            BluppBoxedSegment<TransactionType>(
              selectedValue: _activeType,
              options: const [
                {'label': 'Expense (-)', 'value': TransactionType.expense, 'icon': Icons.arrow_downward_rounded},
                {'label': 'Income (+)', 'value': TransactionType.income, 'icon': Icons.arrow_upward_rounded},
              ],
              onChanged: (val) {
                setState(() {
                  _activeType = val;
                  _selectedCatId = _activeType == TransactionType.expense ? 'food' : 'salary';
                });
              },
              activeColor: _activeType == TransactionType.expense ? AppTheme.expenseCoral : AppTheme.incomeMint,
            ),
            const SizedBox(height: 16),

            // 2. Date Selection (Today, Yesterday, 2 Days Ago, Custom Date)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isPastDate ? Icons.history_toggle_off_rounded : Icons.event_rounded,
                      color: _isPastDate ? AppTheme.warningAmber : AppTheme.textSecondary,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Transaction Date",
                      style: TextStyle(
                        color: _isPastDate ? AppTheme.warningAmber : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_isPastDate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "Past / Forgotten",
                      style: TextStyle(color: AppTheme.warningAmber, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Date Preset Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDateChip("Today", 0),
                  const SizedBox(width: 8),
                  _buildDateChip("Yesterday", 1),
                  const SizedBox(width: 8),
                  _buildDateChip("2 Days Ago", 2),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _pickCustomDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isCustomDateSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.surfaceBorder,
                          width: _isCustomDateSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: _isCustomDateSelected ? AppTheme.primaryTeal : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isCustomDateSelected ? _formatFriendlyDate(_selectedDate) : "Pick Date 📅",
                            style: TextStyle(
                              color: _isCustomDateSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: _isCustomDateSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Title / Description
            TextField(
              controller: _titleController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: "Description / Title",
                hintText: _activeType == TransactionType.expense
                    ? "e.g. Dinner, Fuel, Grocery run, ASNB deposit"
                    : "e.g. Monthly Salary, Freelance project, Bonus",
                hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 13),
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Currency Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.travel_explore_rounded, color: AppTheme.secondaryCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Currency",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: _selectedCurrency != widget.state.baseCurrency
                        ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedCurrency != widget.state.baseCurrency
                          ? AppTheme.primaryTeal
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      dropdownColor: AppTheme.surface,
                      isDense: true,
                      icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal),
                      style: TextStyle(
                        color: _selectedCurrency != widget.state.baseCurrency
                            ? AppTheme.primaryTeal
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      items: CurrencyManager.supportedCurrencies.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.code,
                          child: Text("${c.flag} ${c.code} (${c.symbol})"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 5. Amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "${CurrencyManager.getCurrency(_selectedCurrency).symbol} ",
                prefixStyle: TextStyle(color: AppTheme.primaryTeal, fontSize: 16, fontWeight: FontWeight.bold),
                labelText: _selectedCurrency != widget.state.baseCurrency
                    ? "Amount in $_selectedCurrency (Travel Currency)"
                    : "Amount (${widget.state.baseCurrency})",
                hintText: "e.g. 45.00",
                hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 14),
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_selectedCurrency != widget.state.baseCurrency && enteredAmount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_exchange_rounded, color: AppTheme.primaryTeal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Auto-Converted to Base (${widget.state.baseCurrency}):",
                            style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${CurrencyManager.format(enteredAmount, _selectedCurrency)} ≈ ${AppTheme.formatCurrency(CurrencyManager.convert(amount: enteredAmount, fromCode: _selectedCurrency, toCode: widget.state.baseCurrency))}",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 6. Category Picker
            Text(
              "Select Category",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableCategories.map((cat) {
                final isSelected = _selectedCatId == cat.id;
                return InkWell(
                  onTap: () => setState(() => _selectedCatId = cat.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? cat.color : AppTheme.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 14, color: cat.color),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 7. Source Bank Account Picker
            Text(
              _activeType == TransactionType.expense ? "Paid From Account / Bank" : "Deposited To Account / Bank",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.state.bankAccounts.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Text(
                  "No bank accounts found. Please add a bank account first.",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              )
            else
              BluppHorizontalBoxPicker<String>(
                selectedValue: _selectedBankId,
                options: widget.state.bankAccounts.map((b) => {
                  'label': "${b.name} (${AppTheme.formatCurrency(b.balance)})",
                  'value': b.id,
                  'icon': b.icon,
                }).toList(),
                onChanged: (val) => setState(() => _selectedBankId = val),
                activeColor: AppTheme.primaryTeal,
              ),
            const SizedBox(height: 14),

            // 8. Bank Reconciliation Switch (Crucial for forgotten past transactions)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _updateBankBalance ? AppTheme.primaryTeal.withValues(alpha: 0.3) : AppTheme.surfaceBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _updateBankBalance ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                    color: _updateBankBalance ? AppTheme.primaryTeal : AppTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _updateBankBalance ? "Update Bank Balance" : "Record Only (Keep Bank Balance)",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _updateBankBalance
                              ? (selectedBank != null
                                  ? "${_activeType == TransactionType.expense ? 'Deducts' : 'Adds'} ${AppTheme.formatCurrency(enteredAmount)} ${_activeType == TransactionType.expense ? 'from' : 'to'} ${selectedBank.name}"
                                  : "Adjusts bank account balance automatically.")
                              : "Bank balance won't change. Useful if your bank statement is already reconciled.",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _updateBankBalance,
                    activeThumbColor: AppTheme.primaryTeal,
                    activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    onChanged: (val) => setState(() => _updateBankBalance = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 9. Optional Note
            TextField(
              controller: _noteController,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Note / Description (Optional)",
                hintText: _isPastDate ? "e.g. Forgotten receipt from last weekend" : "e.g. Notes, order #, memo",
                hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.5), fontSize: 12),
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 22),

            // 10. Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeType == TransactionType.expense
                      ? AppTheme.expenseCoral
                      : AppTheme.incomeMint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveTransaction,
                child: Text(
                  isEditing
                      ? "Update Transaction"
                      : (_isPastDate ? "Save Forgotten Entry" : "Save Transaction"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isCustomDateSelected {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final diff = today.difference(target).inDays;
    return diff > 2 || diff < 0;
  }

  Widget _buildDateChip(String label, int daysAgo) {
    final now = DateTime.now();
    final target = now.subtract(Duration(days: daysAgo));
    final isSelected = _selectedDate.year == target.year &&
        _selectedDate.month == target.month &&
        _selectedDate.day == target.day;

    return InkWell(
      onTap: () => _setDatePreset(daysAgo),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (daysAgo > 0
                  ? AppTheme.warningAmber.withValues(alpha: 0.18)
                  : AppTheme.primaryTeal.withValues(alpha: 0.18))
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (daysAgo > 0 ? AppTheme.warningAmber : AppTheme.primaryTeal)
                : AppTheme.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (daysAgo > 0 ? AppTheme.warningAmber : AppTheme.primaryTeal)
                : AppTheme.textMuted,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isEmpty) {
      setState(() {
        _errorWhere = "Description / Title";
        _errorWhy = "Please describe what this transaction was for.";
      });
      return;
    }
    if (enteredAmount <= 0) {
      setState(() {
        _errorWhere = "Amount";
        _errorWhy = "Transaction amount must be greater than 0.00.";
      });
      return;
    }
    if (_selectedBankId.isEmpty && widget.state.bankAccounts.isNotEmpty) {
      setState(() {
        _errorWhere = "Source Account / Bank";
        _errorWhy = "Please select which bank or wallet was used.";
      });
      return;
    }

    final baseAmount = CurrencyManager.convert(
      amount: enteredAmount,
      fromCode: _selectedCurrency,
      toCode: widget.state.baseCurrency,
    );
    final isForeign = _selectedCurrency != widget.state.baseCurrency;
    final customNote = _noteController.text.trim();
    final travelNote = isForeign
        ? "Paid ${CurrencyManager.format(enteredAmount, _selectedCurrency)}"
        : null;
    final combinedNote = customNote.isNotEmpty
        ? (travelNote != null ? "$customNote ($travelNote)" : customNote)
        : travelNote;

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final isTransferCategory = _selectedCatId == 'bank_transfer' ||
        _selectedCatId == 'investment_deposit' ||
        _selectedCatId == 'investment' ||
        _selectedCatId == 'savings';

    if (widget.existingTx != null) {
      final oldTx = widget.existingTx!;
      final updatedTx = TransactionItem(
        id: oldTx.id,
        title: title,
        amount: baseAmount,
        type: _activeType,
        categoryId: _selectedCatId,
        date: combinedDateTime,
        bankAccountId: _selectedBankId,
        note: combinedNote,
        isTransfer: oldTx.isTransfer || isTransferCategory,
      );

      widget.state.updateTransaction(
        oldTx,
        updatedTx,
        updateBankBalance: _updateBankBalance,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Updated '$title' (${_formatFriendlyDate(combinedDateTime)})"),
          backgroundColor: AppTheme.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final newTx = TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        amount: baseAmount,
        type: _activeType,
        categoryId: _selectedCatId,
        date: combinedDateTime,
        bankAccountId: _selectedBankId,
        note: combinedNote,
        isTransfer: isTransferCategory,
      );

      widget.state.addTransaction(
        newTx,
        updateBankBalance: _updateBankBalance,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _isPastDate ? Icons.history_rounded : Icons.check_circle_rounded,
                color: _isPastDate ? AppTheme.warningAmber : AppTheme.primaryTeal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isPastDate
                      ? "Recorded forgotten entry '$title' for ${_formatFriendlyDate(combinedDateTime)}"
                      : "Added '$title' (${AppTheme.formatCurrency(baseAmount)})",
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
