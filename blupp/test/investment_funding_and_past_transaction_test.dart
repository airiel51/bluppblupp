import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blupp/models/finance_state.dart';
import 'package:blupp/widgets/add_transaction_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'blupp_cookie_consent_accepted': true});
  });

  group('Investment funding from existing bank account', () {
    test('Adding new investment deducts money from selected bank account and logs deposit', () {
      final state = FinanceState(initialAuthenticated: true);
      final bank = state.bankAccounts.first;
      final initialBankBal = bank.balance;
      final initialInvCount = state.investments.length;
      final initialTxCount = state.transactions.length;

      // Add new investment of RM 500 funded from the bank account
      final invItem = InvestmentItem(
        id: 'test_inv_funded',
        name: 'ASNB Amanah Saham',
        institution: 'Permodalan Nasional Berhad',
        balance: 500.0,
        returnRateAnnual: 5.25,
        notes: 'Funded from account',
        icon: Icons.savings_rounded,
        color: const Color(0xFF00E5FF),
      );

      state.addInvestment(invItem, fromBankId: bank.id);

      // 1. Investment added to state
      expect(state.investments.length, initialInvCount + 1);
      expect(state.getInvestmentById('test_inv_funded')?.balance, 500.0);

      // 2. Bank balance deducted
      expect(bank.balance, closeTo(initialBankBal - 500.0, 0.01));

      // 3. Corresponding expense transaction recorded
      expect(state.transactions.length, initialTxCount + 1);
      final tx = state.transactions.first;
      expect(tx.title, 'ASNB Amanah Saham Initial Deposit');
      expect(tx.amount, 500.0);
      expect(tx.type, TransactionType.expense);
      expect(tx.categoryId, 'investment_deposit');
      expect(tx.bankAccountId, bank.id);
    });

    test('Adding investment with no bank selected does not deduct bank balance', () {
      final state = FinanceState(initialAuthenticated: true);
      final bank = state.bankAccounts.first;
      final initialBankBal = bank.balance;
      final initialInvCount = state.investments.length;
      final initialTxCount = state.transactions.length;

      final invItem = InvestmentItem(
        id: 'test_inv_external',
        name: 'Versa Cash',
        institution: 'Versa Asia',
        balance: 1000.0,
        returnRateAnnual: 4.0,
        notes: 'External funds',
        icon: Icons.savings_rounded,
        color: const Color(0xFF00E5FF),
      );

      // No bank selected (external funds)
      state.addInvestment(invItem, fromBankId: null);

      expect(state.investments.length, initialInvCount + 1);
      expect(bank.balance, initialBankBal); // unchanged
      expect(state.transactions.length, initialTxCount); // no deduction transaction
    });
  });

  group('Forgotten past transaction logging & reconciliation', () {
    test('Backdated transactions are sorted chronologically newest-to-oldest', () {
      final state = FinanceState(initialAuthenticated: true);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 0);
      final yesterday = today.subtract(const Duration(days: 1));
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final lastWeek = today.subtract(const Duration(days: 7));

      final initialYestTotal = state.getTransactionsTotalForDate(yesterday);

      // Add transactions out of order
      state.addTransaction(TransactionItem(
        id: 'tx_today_test',
        title: 'Today Lunch',
        amount: 25.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: today,
        bankAccountId: state.bankAccounts.first.id,
      ));

      state.addTransaction(TransactionItem(
        id: 'tx_last_week_test',
        title: 'Forgotten Last Week Dinner',
        amount: 80.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: lastWeek,
        bankAccountId: state.bankAccounts.first.id,
      ));

      state.addTransaction(TransactionItem(
        id: 'tx_yesterday_test',
        title: 'Forgotten Yesterday Fuel',
        amount: 50.0,
        type: TransactionType.expense,
        categoryId: 'transport',
        date: yesterday,
        bankAccountId: state.bankAccounts.first.id,
      ));

      state.addTransaction(TransactionItem(
        id: 'tx_3_days_ago_test',
        title: 'Forgotten Groceries',
        amount: 120.0,
        type: TransactionType.expense,
        categoryId: 'groceries',
        date: threeDaysAgo,
        bankAccountId: state.bankAccounts.first.id,
      ));

      // Verify date query helpers
      final yestTxs = state.getTransactionsForDate(yesterday);
      expect(yestTxs.any((t) => t.id == 'tx_yesterday_test'), isTrue);
      expect(state.getTransactionsTotalForDate(yesterday), closeTo(initialYestTotal + 50.0, 0.01));

      // Verify overall transactions are sorted by date descending
      for (int i = 0; i < state.transactions.length - 1; i++) {
        expect(
          state.transactions[i].date.isAfter(state.transactions[i + 1].date) ||
              state.transactions[i].date.isAtSameMomentAs(state.transactions[i + 1].date),
          isTrue,
        );
      }
    });

    test('addTransaction supports updateBankBalance toggle for past entries', () {
      final state = FinanceState(initialAuthenticated: true);
      final bank = state.bankAccounts.first;
      final startBal = bank.balance;

      // 1. Forgotten expense with bank deduction ON
      state.addTransaction(
        TransactionItem(
          id: 'tx_past_deduct',
          title: 'Past Bill',
          amount: 200.0,
          type: TransactionType.expense,
          categoryId: 'bills',
          date: DateTime.now().subtract(const Duration(days: 2)),
          bankAccountId: bank.id,
        ),
        updateBankBalance: true,
      );
      expect(bank.balance, closeTo(startBal - 200.0, 0.01));

      final balAfterFirst = bank.balance;

      // 2. Forgotten expense where user already adjusted bank statement (bank deduction OFF)
      state.addTransaction(
        TransactionItem(
          id: 'tx_past_reconciled',
          title: 'Already Reconciled Coffee',
          amount: 15.0,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime.now().subtract(const Duration(days: 5)),
          bankAccountId: bank.id,
        ),
        updateBankBalance: false,
      );
      // Bank balance stays untouched!
      expect(bank.balance, balAfterFirst);
      expect(state.transactions.any((t) => t.id == 'tx_past_reconciled'), isTrue);
    });

    test('updateTransaction modifies existing transaction and reconciles bank balance', () {
      final state = FinanceState(initialAuthenticated: true);
      final bank = state.bankAccounts.first;
      final startBal = bank.balance;

      final originalDate = DateTime.now();
      final pastDate = originalDate.subtract(const Duration(days: 4));

      final originalTx = TransactionItem(
        id: 'tx_edit_me_test',
        title: 'Lunch',
        amount: 30.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: originalDate,
        bankAccountId: bank.id,
      );

      state.addTransaction(originalTx);
      expect(bank.balance, closeTo(startBal - 30.0, 0.01));

      // User realizes: actually it was RM 50.00 and happened 4 days ago!
      final updatedTx = TransactionItem(
        id: 'tx_edit_me_test',
        title: 'Team Dinner',
        amount: 50.0,
        type: TransactionType.expense,
        categoryId: 'food',
        date: pastDate,
        bankAccountId: bank.id,
        note: 'Backdated entry',
      );

      state.updateTransaction(originalTx, updatedTx, updateBankBalance: true);

      // Reconciled: startBal - 50.0
      expect(bank.balance, closeTo(startBal - 50.0, 0.01));
      final savedTx = state.transactions.firstWhere((t) => t.id == 'tx_edit_me_test');
      expect(savedTx.title, 'Team Dinner');
      expect(savedTx.amount, 50.0);
      expect(savedTx.date, pastDate);
      expect(savedTx.note, 'Backdated entry');
    });
  });

  testWidgets('AddTransactionModal renders date selector with Past / Forgotten badge', (tester) async {
    final state = FinanceState(initialAuthenticated: true);
    final pastDate = DateTime.now().subtract(const Duration(days: 3));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddTransactionModal(
            state: state,
            preselectedDate: pastDate,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Log Forgotten Entry" title and "Past / Forgotten" badge render
    expect(find.text('Log Forgotten Entry'), findsOneWidget);
    expect(find.text('Past / Forgotten'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('2 Days Ago'), findsOneWidget);
    expect(find.text('Update Bank Balance'), findsOneWidget);
    expect(find.text('Save Forgotten Entry'), findsOneWidget);
  });
}
