import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blupp/models/finance_state.dart';
import 'package:blupp/models/currency_model.dart';
import 'package:blupp/main.dart';

void main() {
  test('FinanceState calculates net worth, spending balance, banks and loans correctly', () {
    final state = FinanceState(initialAuthenticated: true);

    final initialBanks = state.totalBankBalance;
    final initialInvestments = state.totalInvestmentsAndSavings;
    final initialSpendingLeft = state.spendingBalanceLeft;
    final initialLoans = state.totalLoans;

    final expectedNetWorth = (initialBanks + initialInvestments + initialSpendingLeft) - initialLoans;
    expect(state.totalNetWorth, closeTo(expectedNetWorth, 0.01));

    final oldNetWorth = state.totalNetWorth;
    final oldSpending = state.spendingBalanceLeft;
    final expenseAmount = 200.0;

    state.addTransaction(TransactionItem(
      id: 'test_exp_1',
      title: 'Test Grocery',
      amount: expenseAmount,
      type: TransactionType.expense,
      categoryId: 'groceries',
      date: DateTime.now(),
      bankAccountId: state.bankAccounts.first.id,
    ));

    expect(state.spendingBalanceLeft, closeTo(oldSpending - expenseAmount, 0.01));
    expect(state.totalNetWorth < oldNetWorth, isTrue);

    final preIncomeNetWorth = state.totalNetWorth;
    final incomeAmount = 1000.0;

    state.addTransaction(TransactionItem(
      id: 'test_inc_1',
      title: 'Bonus Pay',
      amount: incomeAmount,
      type: TransactionType.income,
      categoryId: 'bonus',
      date: DateTime.now(),
      bankAccountId: state.bankAccounts.first.id,
    ));

    expect(state.totalNetWorth > preIncomeNetWorth, isTrue);

    expect(state.nextWeekPlannedSpending >= 0, isTrue);

    final today = DateTime.now();
    state.addPlannedExpense(PlannedExpense(
      id: 'plan_test_1',
      title: 'Dinner tonight',
      amount: 60.0,
      categoryId: 'food',
      date: today,
    ));

    expect(state.getPlannedTotalForDate(today) >= 60.0, isTrue);

    // --- TEST BANK ACCOUNT ACTIONS (ADD MONEY, MINUS MONEY & DELETE) ---
    final targetBank = state.bankAccounts.first;
    final initialBankBalance = targetBank.balance;
    final topUpAmount = 500.0;

    // Add money to bank account
    state.addMoneyToBank(targetBank.id, topUpAmount);
    expect(targetBank.balance, closeTo(initialBankBalance + topUpAmount, 0.01));

    // Minus money from bank account
    final withdrawAmount = 200.0;
    final preWithdrawNetWorth = state.totalNetWorth;
    state.minusMoneyFromBank(targetBank.id, withdrawAmount, note: 'ATM cash out');
    expect(targetBank.balance, closeTo(initialBankBalance + topUpAmount - withdrawAmount, 0.01));
    // Since minusMoneyFromBank logs an expense transaction, both bank balance and spending balance drop by withdrawAmount
    expect(state.totalNetWorth, closeTo(preWithdrawNetWorth - (withdrawAmount * 2), 0.01));

    // Delete bank account
    final initialBankCount = state.bankAccounts.length;
    state.deleteBankAccount(targetBank.id);
    expect(state.bankAccounts.length, equals(initialBankCount - 1));
    expect(state.bankAccounts.any((b) => b.id == targetBank.id), isFalse);
  });

  testWidgets('Authentication flow, 6 navigation tabs, Profile screen, and Sign Out', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Launch unauthenticated
    await tester.pumpWidget(const BluppApp(initialAuthenticated: false));
    await tester.pumpAndSettle();

    // Verify Sign In Screen is displayed
    expect(find.text('blupp'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to continue to Blupp.'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Instant Demo Access'), findsOneWidget);

    // 2. Perform Demo Sign In
    await tester.tap(find.text('Instant Demo Access'));
    await tester.pumpAndSettle();

    // 3. Verify Bottom Navigation with 6 Tabs (including new Profile tab)
    final navBar = find.byType(BottomNavigationBar);
    expect(find.descendant(of: navBar, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Expenses')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Analytics')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('FOMO AI')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Calendar')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Profile')), findsOneWidget);

    // 4. Verify Home Screen loaded and Bank Account Buttons
    expect(find.text('TOTAL NET WORTH'), findsOneWidget);
    expect(find.text('Bank Accounts'), findsOneWidget);
    expect(find.text('Add'), findsWidgets);

    // Test Add Money Dialog
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(find.text('Amount to Add (RM)'), findsOneWidget);

    // Tap quick chip +RM 100
    await tester.tap(find.text('+RM 100'));
    await tester.pumpAndSettle();

    // Tap Confirm Deposit
    await tester.tap(find.text('Confirm Deposit'));
    await tester.pumpAndSettle();

    // 5. Navigate to Profile Tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Profile')));
    await tester.pumpAndSettle();

    // Verify Profile content
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Airiel'), findsOneWidget);
    expect(find.text('airiel@blupp.ai'), findsOneWidget);
    expect(find.text('Verified Member'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('SECURITY & CLOUD BACKEND'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // 6. Test Sign Out Flow
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Are you sure you want to sign out of Blupp? You will need to enter your credentials to access your financial dashboard again.'), findsOneWidget);

    // Confirm Sign Out (tap the button in the dialog)
    final signOutButtons = find.widgetWithText(ElevatedButton, 'Sign Out');
    await tester.tap(signOutButtons);
    await tester.pumpAndSettle();

    // Verify redirected back to Sign In screen
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to continue to Blupp.'), findsOneWidget);
  });

  test('Multi-currency conversion, base currency change, and travel expense tracking', () {
    final state = FinanceState(initialAuthenticated: true);

    // 1. Currency conversion math: 3550 IDR = 1 MYR
    final idrAmount = 355000.0;
    final convertedMYR = CurrencyManager.convert(amount: idrAmount, fromCode: 'IDR', toCode: 'MYR');
    expect(convertedMYR, closeTo(100.0, 0.05));

    // 2. Currency formatting
    expect(CurrencyManager.format(100.0, 'MYR'), equals('RM 100.00'));
    expect(CurrencyManager.format(355000.0, 'IDR'), equals('Rp 355,000'));
    expect(CurrencyManager.format(50.0, 'USD'), equals('\$ 50.00'));

    // 3. Base currency switching in state
    expect(state.baseCurrency, equals('MYR'));
    state.setBaseCurrency('USD');
    expect(state.baseCurrency, equals('USD'));
    state.setBaseCurrency('MYR');
    expect(state.baseCurrency, equals('MYR'));

    // 4. Travel transaction recording (spending in IDR while base is MYR)
    final initialBalance = state.spendingBalanceLeft;
    final travelIDRAmount = 177500.0; // 50 MYR
    final convertedBase = CurrencyManager.convert(amount: travelIDRAmount, fromCode: 'IDR', toCode: state.baseCurrency);
    expect(convertedBase, closeTo(50.0, 0.05));

    state.addTransaction(TransactionItem(
      id: 'tx_travel_1',
      title: 'Bali Dinner',
      amount: convertedBase,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
      bankAccountId: state.bankAccounts.first.id,
      note: 'Paid Rp 177,500 IDR',
    ));

    expect(state.spendingBalanceLeft, closeTo(initialBalance - 50.0, 0.05));
    final recordedTx = state.transactions.firstWhere((tx) => tx.id == 'tx_travel_1');
    expect(recordedTx.note, contains('Paid Rp 177,500 IDR'));
    expect(recordedTx.amount, closeTo(50.0, 0.05));
  });

  test('Light Mode and Dark Mode theme toggling', () {
    final state = FinanceState(initialAuthenticated: true);

    expect(state.isDarkMode, isTrue);
    expect(state.themeMode, equals(ThemeMode.dark));

    state.setThemeMode(ThemeMode.light);
    expect(state.isDarkMode, isFalse);
    expect(state.themeMode, equals(ThemeMode.light));

    state.setThemeMode(ThemeMode.dark);
    expect(state.isDarkMode, isTrue);
    expect(state.themeMode, equals(ThemeMode.dark));
  });

  test('Password reset request verification code and email verification update', () async {
    final state = FinanceState(initialAuthenticated: true);

    // 1. Request verification code
    final code = await state.requestPasswordResetCode('airiel@blupp.ai');
    expect(code.length, equals(6));
    expect(int.tryParse(code) != null, isTrue);

    // 2. Reset password with verification
    final success = await state.resetPasswordWithVerification(newPassword: 'NewSecurePassword123!');
    expect(success, isTrue);
  });

  test('Investments & Savings: minus/withdraw amount, deposit, and delete account with Net Worth sync', () {
    final state = FinanceState(initialAuthenticated: true);

    // 1. Test direct minus / withdrawal
    final targetInv = state.investments.first;
    final initialInvBalance = targetInv.balance;
    final initialNetWorth = state.totalNetWorth;
    const withdrawAmount = 500.0;

    state.minusInvestmentBalance(targetInv.id, withdrawAmount);
    expect(targetInv.balance, closeTo(initialInvBalance - withdrawAmount, 0.01));
    expect(state.totalNetWorth, closeTo(initialNetWorth - withdrawAmount, 0.01));

    // 2. Test minus / withdrawal with deposit into a bank account (asset transfer)
    final targetBank = state.bankAccounts.first;
    final preTransferBankBalance = targetBank.balance;
    final preTransferInvBalance = targetInv.balance;
    final preTransferNetWorth = state.totalNetWorth;
    const transferAmount = 250.0;

    state.minusInvestmentBalance(targetInv.id, transferAmount, toBankId: targetBank.id);
    expect(targetInv.balance, closeTo(preTransferInvBalance - transferAmount, 0.01));
    expect(targetBank.balance, closeTo(preTransferBankBalance + transferAmount, 0.01));
    // Asset transfer leaves overall Net Worth unchanged
    expect(state.totalNetWorth, closeTo(preTransferNetWorth, 0.01));

    // 3. Test deposit / add money to investment
    final preDepositInvBalance = targetInv.balance;
    const depositAmount = 300.0;
    state.addMoneyToInvestment(targetInv.id, depositAmount);
    expect(targetInv.balance, closeTo(preDepositInvBalance + depositAmount, 0.01));

    // 4. Test delete investment
    final initialInvCount = state.investments.length;
    final invIdToDelete = targetInv.id;
    final balanceDeleted = targetInv.balance;
    final preDeleteNetWorth = state.totalNetWorth;

    state.deleteInvestment(invIdToDelete);
    expect(state.investments.length, equals(initialInvCount - 1));
    expect(state.getInvestmentById(invIdToDelete), isNull);
    expect(state.totalNetWorth, closeTo(preDeleteNetWorth - balanceDeleted, 0.01));
  });

  test('Loans & Liabilities: minus/pay down debt and delete liability with Net Worth increase', () {
    final state = FinanceState(initialAuthenticated: true);

    // 1. Test direct minus / repayment of loan
    final targetLoan = state.loans.first;
    final initialLoanBalance = targetLoan.remainingBalance;
    final initialNetWorth = state.totalNetWorth;
    const repaymentAmount = 200.0;

    state.minusLoanBalance(targetLoan.id, repaymentAmount);
    expect(targetLoan.remainingBalance, closeTo(initialLoanBalance - repaymentAmount, 0.01));
    // Reducing liabilities directly increases Net Worth!
    expect(state.totalNetWorth, closeTo(initialNetWorth + repaymentAmount, 0.01));

    // 2. Test minus loan with deduction from bank account
    final targetBank = state.bankAccounts.first;
    final preBankBalance = targetBank.balance;
    final preLoanBalance = targetLoan.remainingBalance;
    final preNetWorth = state.totalNetWorth;
    const bankRepaymentAmount = 150.0;

    state.minusLoanBalance(targetLoan.id, bankRepaymentAmount, fromBankId: targetBank.id);
    expect(targetLoan.remainingBalance, closeTo(preLoanBalance - bankRepaymentAmount, 0.01));
    expect(targetBank.balance, closeTo(preBankBalance - bankRepaymentAmount, 0.01));
    // Paying debt from bank records an expense transaction, which adjusts spending balance left
    expect(state.totalNetWorth, closeTo(preNetWorth - bankRepaymentAmount, 0.01));

    // 3. Test delete loan / liability
    final initialLoansCount = state.loans.length;
    final loanIdToDelete = targetLoan.id;
    final remainingDebt = targetLoan.remainingBalance;
    final preDeleteNetWorth = state.totalNetWorth;

    state.deleteLoan(loanIdToDelete);
    expect(state.loans.length, equals(initialLoansCount - 1));
    expect(state.getLoanById(loanIdToDelete), isNull);
    // Deleting a loan removes the debt obligation, which increases Net Worth by remaining debt!
    expect(state.totalNetWorth, closeTo(preDeleteNetWorth + remainingDebt, 0.01));
  });

  testWidgets('HomeScreen: minus/withdraw investment and pay down/minus loan UI interaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BluppApp(initialAuthenticated: true));
    await tester.pumpAndSettle();

    // 1. Verify Investments & Savings and Loans & Liabilities are displayed
    expect(find.text('Investments & Savings'), findsOneWidget);
    expect(find.text('Loans & Liabilities'), findsOneWidget);

    // 2. Test Bank Account Minus button (tap Minus on Maybank card)
    final maybankCard = find.ancestor(
      of: find.text('Maybank'),
      matching: find.byType(InkWell),
    ).first;
    final maybankMinus = find.descendant(of: maybankCard, matching: find.text('Minus'));
    await tester.tap(maybankMinus);
    await tester.pumpAndSettle();

    // Verify Bank Minus / Withdraw dialog opened
    expect(find.text('Minus / Withdraw'), findsOneWidget);
    expect(find.text('Amount to Deduct (RM)'), findsOneWidget);

    // Tap +RM 100 quick chip
    await tester.tap(find.text('+RM 100'));
    await tester.pumpAndSettle();

    // Confirm Bank Minus
    await tester.tap(find.text('Confirm Minus'));
    await tester.pumpAndSettle();

    // 3. Test Investment Minus button (tap Minus on ASNB card)
    final asnbCard = find.ancestor(
      of: find.text('ASNB (Amanah Saham Bumiputera)'),
      matching: find.byType(InkWell),
    ).first;
    final asnbMinus = find.descendant(of: asnbCard, matching: find.text('Minus'));
    await tester.tap(asnbMinus);
    await tester.pumpAndSettle();

    // Verify Investment Minus / Withdraw dialog opened
    expect(find.text('Minus / Withdraw'), findsOneWidget);
    expect(find.text('Deposit Withdrawn Funds Into:'), findsOneWidget);

    // Tap +RM 100 quick chip
    await tester.tap(find.text('+RM 100'));
    await tester.pumpAndSettle();

    // Confirm Minus
    await tester.tap(find.text('Confirm Minus'));
    await tester.pumpAndSettle();

    // 4. Test Loan Minus button (tap Minus on SPayLater card)
    final spayCard = find.ancestor(
      of: find.text('ShopeePay Later (SPayLater)'),
      matching: find.byType(InkWell),
    ).first;
    final spayMinus = find.descendant(of: spayCard, matching: find.text('Minus'));
    await tester.tap(spayMinus);
    await tester.pumpAndSettle();

    // Verify Minus / Pay Down Loan dialog opened
    expect(find.text('Minus / Pay Down Loan'), findsOneWidget);
    expect(find.text('Deduct Repayment From (Optional):'), findsOneWidget);

    // Tap +RM 50 quick chip
    await tester.tap(find.text('+RM 50'));
    await tester.pumpAndSettle();

    // Confirm Repayment
    await tester.tap(find.text('Confirm Repayment'));
    await tester.pumpAndSettle();
  });

  test('Delete operations for expense/income transactions, FOMO wishlist, and calendar commitments', () {
    final state = FinanceState(initialAuthenticated: true);

    // 1. Delete Expense Transaction
    final initialTxCount = state.transactions.length;
    final targetBank = state.bankAccounts.first;
    final initialBankBalance = targetBank.balance;
    final initialSpending = state.spendingBalanceLeft;
    final initialNetWorth = state.totalNetWorth;
    const testExpenseAmount = 120.0;

    final newExpense = TransactionItem(
      id: 'tx_delete_test_exp',
      title: 'Temporary Dinner',
      amount: testExpenseAmount,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
      bankAccountId: targetBank.id,
    );
    state.addTransaction(newExpense);
    expect(targetBank.balance, closeTo(initialBankBalance - testExpenseAmount, 0.01));
    expect(state.spendingBalanceLeft, closeTo(initialSpending - testExpenseAmount, 0.01));

    // Delete the expense transaction -> restores bank balance and spending balance!
    state.deleteTransaction(newExpense.id);
    expect(state.transactions.length, equals(initialTxCount));
    expect(targetBank.balance, closeTo(initialBankBalance, 0.01));
    expect(state.spendingBalanceLeft, closeTo(initialSpending, 0.01));
    expect(state.totalNetWorth, closeTo(initialNetWorth, 0.01));

    // 2. Delete Income Transaction
    final preIncomeBankBalance = targetBank.balance;
    const testIncomeAmount = 300.0;
    final newIncome = TransactionItem(
      id: 'tx_delete_test_inc',
      title: 'Temporary Bonus',
      amount: testIncomeAmount,
      type: TransactionType.income,
      categoryId: 'bonus',
      date: DateTime.now(),
      bankAccountId: targetBank.id,
    );
    state.addTransaction(newIncome);
    expect(targetBank.balance, closeTo(preIncomeBankBalance + testIncomeAmount, 0.01));

    // Delete the income transaction -> reverses bank balance addition!
    state.deleteTransaction(newIncome.id);
    expect(targetBank.balance, closeTo(preIncomeBankBalance, 0.01));

    // 3. Delete FOMO Wishlist Item
    final initialWishlistCount = state.fomoWishlist.length;
    final initialFomoSaved = state.totalFomoSaved;
    final targetWishlist = state.fomoWishlist.first;
    final costOfTarget = targetWishlist.cost;

    state.deleteWishlistItem(targetWishlist.id);
    expect(state.fomoWishlist.length, equals(initialWishlistCount - 1));
    expect(state.fomoWishlist.any((w) => w.id == targetWishlist.id), isFalse);
    if (targetWishlist.avoided) {
      expect(state.totalFomoSaved, closeTo(initialFomoSaved - costOfTarget, 0.01));
    }

    // 4. Delete Calendar Commitment (Planned Expense)
    final initialPlansCount = state.plannedExpenses.length;
    final targetPlan = state.plannedExpenses.first;

    state.deletePlannedExpense(targetPlan.id);
    expect(state.plannedExpenses.length, equals(initialPlansCount - 1));
    expect(state.plannedExpenses.any((p) => p.id == targetPlan.id), isFalse);
  });

  testWidgets('Delete buttons and dialogs for Expenses, FOMO Wishlist, and Calendar Commitments', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BluppApp(initialAuthenticated: true));
    await tester.pumpAndSettle();

    final navBar = find.byType(BottomNavigationBar);

    // 1. Test Delete on Expenses tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Expenses')));
    await tester.pumpAndSettle();

    // Verify Expenses Tab is open
    expect(find.text('TOTAL EXPENSE THIS MONTH'), findsOneWidget);

    // Find delete icon buttons on transaction cards
    final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
    expect(deleteButtons, findsWidgets);

    // Tap first delete button
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verify confirmation dialog appeared
    expect(find.text('Delete Expense'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Delete'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    // 2. Test Delete on FOMO Wishlist tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('FOMO AI')));
    await tester.pumpAndSettle();

    expect(find.text('30-Day Cooldown Wishlist'), findsOneWidget);
    final fomoDeleteButtons = find.byIcon(Icons.delete_outline_rounded);
    expect(fomoDeleteButtons, findsWidgets);

    // Tap delete on wishlist item
    await tester.tap(fomoDeleteButtons.first);
    await tester.pumpAndSettle();

    // Verify dialog appeared
    expect(find.text('Delete Wishlist Item'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    // 3. Test Delete on Calendar tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Commitments This Month'), findsOneWidget);
    final calendarDeleteButtons = find.byIcon(Icons.delete_outline_rounded);
    expect(calendarDeleteButtons, findsWidgets);

    // Tap delete on calendar commitment item
    await tester.tap(calendarDeleteButtons.first);
    await tester.pumpAndSettle();

    // Verify dialog appeared
    expect(find.text('Delete Commitment'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
  });
}
