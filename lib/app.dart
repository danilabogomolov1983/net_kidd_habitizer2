import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/shell/presentation/pages/main_shell.dart';
import 'shared/theme/app_theme.dart';

/// Composition root: wires the theme system (light/dark + user preference)
/// and the app shell. All screens come from `features/shell`.
final class HabitizerApp extends StatelessWidget {
  const HabitizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _HabitizerMaterialApp());
  }
}

final class _HabitizerMaterialApp extends ConsumerWidget {
  const _HabitizerMaterialApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Habitizer',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      builder: (context, child) {
        // Scale text relative to screen width (capped) so layouts stay
        // balanced on small phones and tablets alike.
        final width = MediaQuery.of(context).size.width;
        final scaler = TextScaler.linear((width / 375).clamp(0.85, 1.4));
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child!,
        );
      },
      home: const MainShell(),
    );
  }
}
