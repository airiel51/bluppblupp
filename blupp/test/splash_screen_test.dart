import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blupp/models/finance_state.dart';
import 'package:blupp/screens/splash_screen.dart';
import 'package:blupp/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'blupp_cookie_consent_accepted': true});
  });

  testWidgets('SplashScreen displays brand elements, radar aura, and status ticker', (WidgetTester tester) async {
    final state = FinanceState(initialAuthenticated: false);
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          state: state,
          duration: const Duration(milliseconds: 1000),
          autoNavigate: false,
          onFinish: () => finished = true,
        ),
      ),
    );

    // Initial frame
    await tester.pump(const Duration(milliseconds: 200));

    // Verify brand typography & badges are rendered
    expect(find.text('blupp'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('INTELLIGENT WEALTH OS'), findsOneWidget);
    expect(find.text('256-Bit Encrypted • Privacy Shield Active'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('Tap anywhere to skip'), findsOneWidget);

    // Initial status ticker
    expect(find.text('Securing encrypted vault...'), findsOneWidget);
    expect(finished, isFalse);
  });

  testWidgets('SplashScreen tap-to-skip immediately calls onFinish', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = FinanceState(initialAuthenticated: false);
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          state: state,
          duration: const Duration(seconds: 10), // long duration
          autoNavigate: false,
          onFinish: () => finished = true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(finished, isFalse);

    // Tap screen to trigger instant skip
    await tester.tap(find.byType(SplashScreen));
    await tester.pump(); // Resolve tap gesture arena
    await tester.pump(const Duration(milliseconds: 350)); // Advance exit animation
    await tester.pump(); // Execute completion callback

    expect(finished, isTrue);
  });

  testWidgets('SplashScreen auto-navigates when duration elapses', (WidgetTester tester) async {
    final state = FinanceState(initialAuthenticated: false);
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          state: state,
          duration: const Duration(milliseconds: 500),
          autoNavigate: true,
          onFinish: () => finished = true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(finished, isFalse);

    // Advance past duration + exit transition
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 350));

    expect(finished, isTrue);
  });

  testWidgets('BluppApp with showSplash: true launches splash screen then transitions to SignInScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const BluppApp(
        initialAuthenticated: false,
        showSplash: true,
      ),
    );

    // Frame 1: splash screen is visible
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('splash_screen')), findsOneWidget);
    expect(find.text('blupp'), findsOneWidget);
    expect(find.text('INTELLIGENT WEALTH OS'), findsOneWidget);

    // Tap to skip splash screen
    await tester.tap(find.byKey(const ValueKey('splash_screen')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Transition completed to SignInScreen
    expect(find.byKey(const ValueKey('sign_in_screen')), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
