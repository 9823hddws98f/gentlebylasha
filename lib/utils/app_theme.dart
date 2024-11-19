import 'package:flutter/material.dart';

import 'tx_color_extensions.dart';

class AppTheme {
  static const fontFamily = 'Matter'; //'Poppins';
  static const titleFont = 'Matter'; //'Poppins';

  static const smallBorderRadius = BorderRadius.all(Radius.circular(10));
  static const largeBorderRadius = BorderRadius.all(Radius.circular(30));

  static const smallImageBorderRadius = BorderRadius.all(Radius.circular(8));
  static const largeImageBorderRadius = BorderRadius.all(Radius.circular(10));

  static const sidePadding = 16.0;

  static const lightColors = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF365DCB),
    onPrimary: Colors.white,
    secondary: Color(0xFFA483DB),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8D9FF),
    onSecondaryContainer: Color(0xFF142249),
    tertiary: Color(0xFFF6C000),
    error: Color(0xFFFF4242),
    onError: Colors.white,
    onErrorContainer: Color(0xFFFF0000),
    surface: Colors.white,
    onSurface: Color(0xFF000000),
    surfaceContainerHighest: Color(0xffF8F8F8),
    surfaceContainerLowest: Color(0xffF8F8F8),
    onSurfaceVariant: Color(0xFF6C7A8B),
    outline: Color(0xFFDBDFE9),
  );

  static const darkColors = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff52B788),
    onPrimary: Colors.white,
    secondary: Color(0xff52B788),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xff142249),
    onSecondaryContainer: Color(0xFFF5F5F5),
    tertiary: Color(0xFFC59A00),
    error: Color(0xFFFF4242),
    onError: Colors.white,
    onErrorContainer: Colors.red,
    surface: Color(0xff1A2034),
    onSurface: Color(0xFFF5F5F5),
    surfaceContainerHighest: Color.fromARGB(255, 39, 55, 96),
    surfaceContainerLowest: Color(0xff0E1529),
    onSurfaceVariant: Color(0xFF99A1B7),
    outline: Color(0xFF323849),
  );

  static ThemeData buildTheme({required bool dark}) {
    final colors = dark ? darkColors : lightColors;
    const borderShape = RoundedRectangleBorder(borderRadius: smallBorderRadius);
    final appBarBackground = colors.surfaceContainerLowest;
    final buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all(borderShape),
      minimumSize: WidgetStateProperty.all(Size(0, 48)),
      textStyle: WidgetStateProperty.all(TextStyle(
        fontSize: 16,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      )),
    );
    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: appBarBackground,
      fontFamily: fontFamily,
      extensions: dark ? {TxColorExtensions.dark()} : {TxColorExtensions.light()},
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      textButtonTheme: TextButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 48, fontFamily: titleFont),
      ),
      iconTheme: IconThemeData(color: colors.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: smallBorderRadius,
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: smallBorderRadius,
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        scrolledUnderElevation: 0.8,
        centerTitle: false,
        titleSpacing: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          fontFamily: titleFont,
          color: colors.onSurface,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: appBarBackground,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalElevation: 0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: largeBorderRadius.topLeft,
            topRight: largeBorderRadius.topRight,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontFamily: titleFont,
          color: colors.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: largeBorderRadius),
        elevation: 0,
      ),
      datePickerTheme: DatePickerThemeData(
        rangePickerBackgroundColor: colors.surface,
      ),
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(
          fontSize: 20,
          fontFamily: titleFont,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 20,
          fontFamily: titleFont,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurface,
        tileColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: smallBorderRadius),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        minTileHeight: 48,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colors.onPrimary,
        unselectedItemColor: colors.onPrimary.withValues(alpha: 0.5),
        selectedLabelStyle: TextStyle(fontSize: 12, fontFamily: fontFamily),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontFamily: fontFamily),
        backgroundColor: colors.surfaceContainerLowest,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
      ),
    );
  }
}
