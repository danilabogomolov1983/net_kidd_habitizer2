import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:net_kidd_habitizer2/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders habits tab', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Should see empty state for habits
    expect(find.text('No habits yet'), findsOneWidget);
  });

  testWidgets('Create habit workflow', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Tap FAB to open form
    await tester.tap(find.byTooltip('New Habit'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).first, 'Integration test habit');
    await tester.enterText(find.byType(TextFormField).last, 'daily');
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();
  });
}
