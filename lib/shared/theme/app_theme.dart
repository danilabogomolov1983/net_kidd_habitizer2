import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Habitizer design system — theme tokens and `ThemeData` builders.
///
/// The visual language follows the LinkedIn Mobile app structure: a warm
/// off-white canvas, white cards with hairline borders, a single brand blue,
/// pill-shaped controls and a dedicated dark mode. Semantic colours that
/// change per brightness live in [HabitizerPalette] (a `ThemeExtension`),
/// so widgets read `context.habitizer.card` instead of hard-coded hex values.

// ── Brand constants (mode-independent) ───────────────────────
abstract final class Brand {
  /// LinkedIn-style brand blue.
  static const blue = Color(0xFF0A66C2);

  /// Accent used for links/emphasis in dark mode.
  static const blueLight = Color(0xFF70B5F9);
}

/// Semantic palette that adapts to brightness.
@immutable
final class HabitizerPalette extends ThemeExtension<HabitizerPalette> {
  /// Feed / scaffold canvas.
  final Color canvas;

  /// Card and bottom-bar surface.
  final Color surface;

  /// Hairline borders around cards and dividers.
  final Color border;

  /// Fill for pill-shaped search fields.
  final Color searchFill;

  /// Secondary text (meta lines, labels).
  final Color mutedText;

  /// Translucent primary used for tinted circles/chips.
  final Color primaryTint;

  /// Urgent / destructive (due-soon habits, delete actions).
  final Color danger;

  /// Success (completed habits).
  final Color success;

  /// Gradient stops for hero cards (statistics, profile cover).
  final Color gradientStart;
  final Color gradientEnd;

  const HabitizerPalette({
    required this.canvas,
    required this.surface,
    required this.border,
    required this.searchFill,
    required this.mutedText,
    required this.primaryTint,
    required this.danger,
    required this.success,
    required this.gradientStart,
    required this.gradientEnd,
  });

  static const light = HabitizerPalette(
    canvas: Color(0xFFF3F2EF), // LinkedIn feed background
    surface: Colors.white,
    border: Color(0xFFE3E0DB),
    searchFill: Color(0xFFEDF3F8),
    mutedText: Color(0xFF66666E),
    primaryTint: Color(0xFFDCEBF7),
    danger: Color(0xFFC73E4B),
    success: Color(0xFF057642),
    gradientStart: Color(0xFF0A66C2),
    gradientEnd: Color(0xFF0B3D6B),
  );

  static const dark = HabitizerPalette(
    canvas: Color(0xFF1B1B1F), // LinkedIn dark background
    surface: Color(0xFF232326),
    border: Color(0xFF3A3A3D),
    searchFill: Color(0xFF2E2E33),
    mutedText: Color(0xFF9C9CA3),
    primaryTint: Color(0xFF133A5C),
    danger: Color(0xFFFF7A85),
    success: Color(0xFF6CC08A),
    gradientStart: Color(0xFF0E4E86),
    gradientEnd: Color(0xFF0B3D6B),
  );

  @override
  HabitizerPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? border,
    Color? searchFill,
    Color? mutedText,
    Color? primaryTint,
    Color? danger,
    Color? success,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return HabitizerPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      searchFill: searchFill ?? this.searchFill,
      mutedText: mutedText ?? this.mutedText,
      primaryTint: primaryTint ?? this.primaryTint,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  HabitizerPalette lerp(ThemeExtension<HabitizerPalette>? other, double t) {
    if (other is! HabitizerPalette) return this;
    return HabitizerPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}

/// Convenience accessor: `context.habitizer.card`.
extension HabitizerThemeX on BuildContext {
  HabitizerPalette get habitizer =>
      Theme.of(this).extension<HabitizerPalette>()!;
}

/// User-selected theme mode. App-wide glue, hence living in shared rather
/// than in a slice; `app.dart` watches it, the profile slice offers the toggle.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ── ThemeData builders ───────────────────────────────────────
ThemeData buildLightTheme() =>
    _buildTheme(Brightness.light, HabitizerPalette.light);

ThemeData buildDarkTheme() =>
    _buildTheme(Brightness.dark, HabitizerPalette.dark);

ThemeData _buildTheme(Brightness brightness, HabitizerPalette palette) {
  final isLight = brightness == Brightness.light;
  final primary = isLight ? Brand.blue : Brand.blueLight;
  final onSurface = isLight ? const Color(0xFF1F1F23) : const Color(0xFFE7E9EA);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: Brand.blue,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: isLight ? Colors.white : const Color(0xFF0B2B4A),
        surface: palette.surface,
        onSurface: onSurface,
        onSurfaceVariant: palette.mutedText,
        outline: palette.border,
        outlineVariant: palette.border,
        error: palette.danger,
      );

  final radius10 = BorderRadius.circular(10);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.canvas,
    extensions: [palette],
    dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius10,
        side: BorderSide(color: palette.border),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.canvas,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      hintStyle: TextStyle(color: palette.mutedText, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: radius10,
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius10,
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius10,
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Brand.blue,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: onSurface,
      contentTextStyle: TextStyle(
        color: palette.surface,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: onSurface),
      bodySmall: TextStyle(fontSize: 12.5, color: palette.mutedText),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: palette.mutedText,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.mutedText,
      ),
    ),
  );
}
