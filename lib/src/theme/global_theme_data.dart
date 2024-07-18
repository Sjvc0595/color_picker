import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalThemeData {
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = themeData(
    lightColorScheme,
    _lightFocusColor,
    textTheme,
  );

  static ThemeData darkThemeData = themeData(
    darkColorScheme,
    _darkFocusColor,
    textTheme,
  );

  static ThemeData themeData(
      ColorScheme colorScheme, Color focusColor, TextTheme textTheme) {
    return ThemeData(
      colorScheme: colorScheme,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      textTheme: textTheme,
    );
  }

  // Light Color scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFF06152A),
    onPrimary: Color(0xFFEDF2F8),
    secondary: Color(0x165E6064),
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: Color(0xFFEDF2F8),
    onSurface: Color(0xFF06152A),
    background: Color(0xFFEDF2F8),
    onBackground: Color(0xFF06152A),
    brightness: Brightness.light,
  );

  // Dark Color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFFEDF2F8),
    onPrimary: Color(0xFF06152A),
    secondary: Color(0x165E6064),
    onSecondary: Color(0xFFEDF2F8),
    error: Colors.redAccent,
    onError: Colors.white,
    surface: Color(0xFF06152A),
    onSurface: Color(0xFFEDF2F8),
    background: Color(0xFF06152A),
    onBackground: Color(0xFFEDF2F8),
    brightness: Brightness.dark,
  );

  // Text theme
  static TextTheme textTheme = GoogleFonts.leagueGothicTextTheme().copyWith(
    displaySmall: GoogleFonts.leagueGothic(
      textStyle: const TextStyle(fontSize: 36.0),
    ),
    headlineSmall: GoogleFonts.leagueGothic(
      textStyle: const TextStyle(fontSize: 24.0),
    ),
    labelLarge: GoogleFonts.robotoCondensed(
      textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
    ),
    bodyMedium: GoogleFonts.robotoCondensed(
      textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
    ),
    bodySmall: GoogleFonts.robotoCondensed(
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    ),
  );
}
