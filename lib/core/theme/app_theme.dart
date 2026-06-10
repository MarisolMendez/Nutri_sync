import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores oficiales de NutriSync extraídos del diseño en Figma.
abstract class NutriColors {
  // ── Primarios ──────────────────────────────────────────────────────────────
  /// Verde acción — botones principales, FAB, toggles activos
  static const primary = Color(0xFF24B38A);

  /// Verde oscuro — headers, AppBar, elementos de navegación activos
  static const primaryDark = Color(0xFF16805F);

  /// Fondo crema — fondo general de todas las pantallas
  static const background = Color(0xFFF4F1EC);

  // ── Texto ──────────────────────────────────────────────────────────────────
  /// Texto principal — títulos, labels, contenido importante
  static const textPrimary = Color(0xFF3D4943);

  /// Texto secundario — subtítulos, hints, metadata
  static const textSecondary = Color(0xFF7A8C84);

  /// Texto sobre fondo verde — botones, headers
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Superficies ────────────────────────────────────────────────────────────
  /// Fondo de cards y contenedores
  static const surface = Color(0xFFFFFFFF);

  /// Borde suave de cards
  static const border = Color(0xFFE2DDD7);

  /// Fondo de inputs y campos de texto
  static const inputFill = Color(0xFFF0EDE8);

  // ── Semánticos ─────────────────────────────────────────────────────────────
  /// Éxito — comida consumida, meta alcanzada
  static const success = Color(0xFF24B38A);

  /// Error — validaciones, fallos de red
  static const error = Color(0xFFE05C5C);

  /// Advertencia — recordatorios, alertas suaves
  static const warning = Color(0xFFF5A623);

  /// Hidratación — círculo de progreso de agua
  static const hydration = Color(0xFF4A90D9);

  // ── Mood colors ────────────────────────────────────────────────────────────
  static const moodExcellent = Color(0xFF24B38A);
  static const moodGood = Color(0xFF7BC67E);
  static const moodNeutral = Color(0xFFF5C842);
  static const moodBad = Color(0xFFE05C5C);
}

abstract class NutriTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: NutriColors.primary,
          onPrimary: NutriColors.textOnPrimary,
          secondary: NutriColors.primaryDark,
          onSecondary: NutriColors.textOnPrimary,
          surface: NutriColors.surface,
          onSurface: NutriColors.textPrimary,
          error: NutriColors.error,
          outline: NutriColors.border,
        ),
        scaffoldBackgroundColor: NutriColors.background,
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        cardTheme: _cardTheme,
        bottomNavigationBarTheme: _bottomNavTheme,
        checkboxTheme: _checkboxTheme,
        switchTheme: _switchTheme,
        dividerTheme: const DividerThemeData(
          color: NutriColors.border,
          thickness: 1,
        ),
      );

  // ── AppBar ─────────────────────────────────────────────────────────────────
  static const _appBarTheme = AppBarTheme(
    backgroundColor: NutriColors.primaryDark,
    foregroundColor: NutriColors.textOnPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: NutriColors.textOnPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: NutriColors.textOnPrimary),
  );

  // ── Tipografía ─────────────────────────────────────────────────────────────
  static TextTheme get _textTheme => GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: NutriColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: NutriColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: NutriColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NutriColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: NutriColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: NutriColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: NutriColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: NutriColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NutriColors.textOnPrimary,
        ),
      );

  // ── Botón principal ────────────────────────────────────────────────────────
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: NutriColors.primary,
      foregroundColor: NutriColors.textOnPrimary,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── Botón outline ──────────────────────────────────────────────────────────
  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: NutriColors.primary,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      side: const BorderSide(color: NutriColors.primary, width: 1.5),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── Botón texto ────────────────────────────────────────────────────────────
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: NutriColors.primary,
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── Inputs ─────────────────────────────────────────────────────────────────
  static final _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: NutriColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: NutriColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: NutriColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: NutriColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: NutriColors.error),
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 14,
      color: NutriColors.textSecondary,
    ),
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      color: NutriColors.textSecondary,
    ),
  );

  // ── Cards ──────────────────────────────────────────────────────────────────
  static final _cardTheme = CardThemeData(
    color: NutriColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: NutriColors.border),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  );

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  static const _bottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: NutriColors.surface,
    selectedItemColor: NutriColors.primary,
    unselectedItemColor: NutriColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
  );

  // ── Checkbox ───────────────────────────────────────────────────────────────
  static final _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return NutriColors.primary;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(NutriColors.textOnPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: NutriColors.border, width: 1.5),
  );

  // ── Switch ─────────────────────────────────────────────────────────────────
  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return NutriColors.textOnPrimary;
      return NutriColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return NutriColors.primary;
      return NutriColors.border;
    }),
  );
}