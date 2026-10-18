import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blupp/widgets/blupp_forms.dart';
import 'package:blupp/widgets/blupp_formatted_text.dart';
import 'package:blupp/models/finance_state.dart';

void main() {
  testWidgets('BluppBoxedSegment does not crash when options lack explicit value key', (tester) async {
    String selected = 'Vehicle';
    final options = [
      {'label': 'Vehicle', 'icon': Icons.directions_car_rounded},
      {'label': 'Housing', 'icon': Icons.home_rounded},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BluppBoxedSegment<String>(
                selectedValue: selected,
                options: options,
                onChanged: (val) => setState(() => selected = val),
              );
            },
          ),
        ),
      ),
    );

    // Verify both items rendered
    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.text('Housing'), findsOneWidget);

    // Tap Housing
    await tester.tap(find.text('Housing'));
    await tester.pumpAndSettle();
    expect(selected, 'Housing');
  });

  testWidgets('BluppFormattedText strips ### and ** symbols and renders bold spans', (tester) async {
    const rawInput = '''
### 🚨 The Cold, Hard Crime Scene

* **Your Discretionary Balance:** **RM 0.00**. *Kosong.* Zero.
''';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BluppFormattedText(text: rawInput),
        ),
      ),
    );

    // Should NOT find raw ### or raw ** on screen
    expect(find.textContaining('###'), findsNothing);
    expect(find.textContaining('**'), findsNothing);

    // Clean text should be visible
    expect(find.textContaining('The Cold, Hard Crime Scene'), findsOneWidget);
    expect(find.textContaining('Your Discretionary Balance:'), findsOneWidget);
    expect(find.textContaining('RM 0.00'), findsOneWidget);
  });

  test('FinanceState.addLoan supports icon and color options', () {
    final state = FinanceState(initialAuthenticated: true);
    final initialCount = state.loans.length;

    state.addLoan(
      'Car Loan',
      'Maybank',
      25000.0,
      600.0,
      15,
      icon: Icons.directions_car_rounded,
    );

    expect(state.loans.length, initialCount + 1);
    final added = state.loans.last;
    expect(added.name, 'Car Loan');
    expect(added.provider, 'Maybank');
    expect(added.totalLoan, 25000.0);
    expect(added.icon, Icons.directions_car_rounded);
  });
}
