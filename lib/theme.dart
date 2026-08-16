import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta de la app. El acento sale del sol del logo.
class RumbaColors {
  static const Color bg = Color(0xFF0D1220);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceHigh = Color(0xFF1B2438);
  static const Color line = Color(0xFF232C42);
  static const Color track = Color(0xFF2A344C);

  static const Color accent = Color(0xFFF0A02A);
  static const Color onAccent = Color(0xFF412402);

  static const Color text = Color(0xFFF5F7FB);
  static const Color text2 = Color(0xFFC7CEDC);
  static const Color dim = Color(0xFF8A93A8);
  static const Color faint = Color(0xFF5D6683);

  static const Color live = Color(0xFF4ADE80);
  static const Color danger = Color(0xFFE24B4A);
}

ThemeData buildRumbaTheme() {
  const scheme = ColorScheme.dark(
    primary: RumbaColors.accent,
    onPrimary: RumbaColors.onAccent,
    secondary: RumbaColors.accent,
    onSecondary: RumbaColors.onAccent,
    surface: RumbaColors.surface,
    onSurface: RumbaColors.text,
    error: RumbaColors.danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: RumbaColors.bg,
    canvasColor: RumbaColors.bg,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: RumbaColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: RumbaColors.text),
      titleTextStyle: TextStyle(
        color: RumbaColors.text,
        fontSize: 19,
        fontWeight: FontWeight.w500,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: RumbaColors.line,
      thickness: 0.5,
      space: 0.5,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: RumbaColors.dim,
      textColor: RumbaColors.text,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: RumbaColors.bg,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: RumbaColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: RumbaColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: RumbaColors.surfaceHigh,
      contentTextStyle: TextStyle(color: RumbaColors.text),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Colors.white
            : RumbaColors.dim,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? RumbaColors.accent
            : RumbaColors.track,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: RumbaColors.accent,
      inactiveTrackColor: RumbaColors.track,
      thumbColor: RumbaColors.accent,
      trackHeight: 3,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: RumbaColors.text, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: RumbaColors.text, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: RumbaColors.text),
      bodyMedium: TextStyle(color: RumbaColors.text2),
      bodySmall: TextStyle(color: RumbaColors.dim),
      labelSmall: TextStyle(color: RumbaColors.faint),
    ),
  );
}
