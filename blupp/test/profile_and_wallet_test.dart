import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blupp/models/finance_state.dart';
import 'package:blupp/screens/sign_in_screen.dart';
import 'package:blupp/widgets/blupp_bank_wallet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FinanceState retains profile picture in SharedPreferences across reload and logins', () async {
    final state = FinanceState(initialAuthenticated: true);
    expect(state.hasCustomProfileImage, isFalse);

    // 1-pixel transparent PNG in base64
    const sampleImageBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

    // Set profile picture
    state.setProfileImage(sampleImageBase64);
    expect(state.hasCustomProfileImage, isTrue);
    expect(state.profileImageBase64, equals(sampleImageBase64));
    expect(state.profileImageBytes, isNotNull);

    // Verify it was written to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('blupp_active_profile_image'), equals(sampleImageBase64));
    expect(prefs.getString('blupp_last_profile_image'), equals(sampleImageBase64));

    // Clear memory data like an app reload
    state.clearAllData(preserveProfileImage: false);
    expect(state.hasCustomProfileImage, isFalse);

    // Reloading a new session / FinanceState restores the saved profile image
    final newState = FinanceState(initialAuthenticated: false);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(newState.hasCustomProfileImage, isTrue);
    expect(newState.profileImageBase64, equals(sampleImageBase64));

    // Demo sign in also retains custom profile image
    newState.signInDemo();
    expect(newState.hasCustomProfileImage, isTrue);
    expect(newState.profileImageBase64, equals(sampleImageBase64));
  });

  testWidgets('BluppBankWallet renders stacked card deck with balance, actions, and docked Add Card', (WidgetTester tester) async {
    final state = FinanceState(initialAuthenticated: true);
    bool addCardTapped = false;
    BankAccount? addedBank;
    BankAccount? minusedBank;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BluppBankWallet(
              state: state,
              onManageBank: (bank) {},
              onAddMoney: (bank) => addedBank = bank,
              onMinusMoney: (bank) => minusedBank = bank,
              onAddNewCard: () => addCardTapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify VISA logo and stacked card elements
    expect(find.text('VISA'), findsWidgets);
    expect(find.text('Add Card'), findsOneWidget);
    expect(find.text('Add'), findsWidgets);
    expect(find.text('Minus'), findsWidgets);

    // Tap Add Card button in the docked notch
    await tester.tap(find.text('Add Card'));
    await tester.pumpAndSettle();
    expect(addCardTapped, isTrue);

    // Tap Add on active card
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(addedBank, isNotNull);

    // Tap Minus on active card
    await tester.tap(find.text('Minus').first);
    await tester.pumpAndSettle();
    expect(minusedBank, isNotNull);
  });

  testWidgets('SignInScreen displays TikTok-inspired curved swooping banner and Blupp logo', (WidgetTester tester) async {
    final state = FinanceState(initialAuthenticated: false);

    await tester.pumpWidget(
      MaterialApp(
        home: SignInScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();

    // Wordmark & Subtitle
    expect(find.text('blupp'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login to continue'), findsOneWidget);

    // Form inputs and buttons
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Try Instant Demo Mode'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
