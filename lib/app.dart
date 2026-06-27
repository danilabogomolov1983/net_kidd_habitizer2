import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/habit/presentation/pages/habit_list_page.dart';

/// Root widget of the Habitizer application.
///
/// Wraps the widget tree in a [ProviderScope] to enable Riverpod
/// dependency injection. Contains a single tab: Habits.
final class HabitizerApp extends StatelessWidget {
  const HabitizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Habitizer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HabitListPage(),
      ),
    );
  }
}
