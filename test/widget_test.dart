// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:town_pass/main.dart';

/// Helper function to verify the counter's displayed text in the widget tree.
/// This function specifically checks for the presence of [expectedCount]
/// and the absence of the *other* number (assuming a simple 0-1 counter based on the test).
void _verifyCounterValue(WidgetTester tester, int expectedCount) {
  expect(find.text('$expectedCount'), findsOneWidget);
  // Also verify that the *other* possible counter value (0 or 1) is not present.
  expect(find.text('${expectedCount == 0 ? 1 : 0}'), findsNothing);
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    _verifyCounterValue(tester, 0);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    _verifyCounterValue(tester, 1);
  });
}