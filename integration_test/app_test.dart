import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:net_kidd_habitizer2/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders task and tag tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Should see two navigation destinations
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);

    // Default tab is Tasks — should show empty state
    expect(find.text('No tasks yet'), findsOneWidget);

    // Navigate to Tags tab
    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();
    expect(find.text('No tags yet'), findsOneWidget);

    // Navigate back to Tasks
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('Create task workflow', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Tap FAB to open form
    await tester.tap(find.byTooltip('New Task'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).first, 'Integration test task');
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();
  });

  testWidgets('Create tag workflow', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Navigate to Tags
    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();

    // Tap FAB to open form
    await tester.tap(find.byTooltip('New Tag'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).first, 'Integration Tag');
    await tester.tap(find.text('Create Tag'));
    await tester.pumpAndSettle();
  });
}
