import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:net_kidd_habitizer2/app.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/database/database_factory_initializer.dart';
import 'package:net_kidd_habitizer2/shared/widgets/app_logo.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // The integration test pumps HabitizerApp directly, so main()'s factory
    // setup never runs. Desktop platforms need the FFI SQLite factory.
    initializeDatabaseFactory();
    if (Platform.isLinux || Platform.isWindows) {
      // Reset the persisted DB so tests are idempotent across runs.
      final dir = await databaseFactoryFfi.getDatabasesPath();
      final dbFile = File(p.join(dir, 'habitizer.db'));
      if (await dbFile.exists()) await dbFile.delete();
    }
  });

  testWidgets('App renders home tab with logo empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // No habits stored → home tab shows the brand logo empty state.
    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('Create habit workflow', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitizerApp());
    await tester.pumpAndSettle();

    // Tap the bottom-bar add button to open the auto-saving habit form.
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
