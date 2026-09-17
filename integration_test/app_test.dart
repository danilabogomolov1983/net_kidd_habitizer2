import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:net_kidd_habitizer2/app.dart';
import 'package:net_kidd_habitizer2/shared/widgets/app_logo.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders home tab with logo empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // No habits stored → home tab shows the brand logo empty state.
    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('Create habit workflow', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Tap FAB to open the auto-saving habit form.
    await tester.tap(find.byTooltip('New habit'));
    await tester.pumpAndSettle();

    // Fill description (auto-save fires on change).
    await tester.enterText(find.byType(TextFormField).first, 'Integration test habit');
    await tester.pumpAndSettle();

    // Back to the home tab — the new habit card should be visible.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Integration test habit'), findsOneWidget);
  });
}
