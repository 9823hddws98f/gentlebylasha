import 'package:flutter/material.dart';

class AppTheme {
  // Constants
  static const fontFamily = 'Poppins';
  static const smallBorderRadius = BorderRadius.all(Radius.circular(8));
  static const largeBorderRadius = BorderRadius.all(Radius.circular(30));

  static ThemeData get lightTheme => ThemeData(
        fontFamily: fontFamily,
        inputDecorationTheme: _buildInputDecorationTheme(),
        textButtonTheme: textButtonTheme,
        filledButtonTheme: filledButtonTheme,
      );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xff52B788),
          onPrimary: Colors.white,
          secondary: Color(0xff52B788),
          onSecondary: Colors.white,
          error: Color(0xff52B788),
          onError: Colors.white,
          surface: Color(0xff1A2034),
          onSurface: Colors.white,
          surfaceContainerHighest: Color(0xff1A2034),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: largeBorderRadius,
          ),
          backgroundColor: Color(0xff0E1529),
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: fontFamily),
        scaffoldBackgroundColor: const Color(0xff0E1529),
        iconTheme: IconThemeData(color: Color(0xffC5C5C5)),
        inputDecorationTheme: _buildInputDecorationTheme(true),
        textButtonTheme: textButtonTheme,
        filledButtonTheme: filledButtonTheme,
      );

  static InputDecorationTheme _buildInputDecorationTheme([bool isDark = false]) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Color(0xff1A2034) : Colors.red,
      iconColor: Color(0xffC5C5C5),
      suffixIconColor: Color(0xffC5C5C5),
      border: OutlineInputBorder(
        borderRadius: smallBorderRadius,
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: smallBorderRadius,
        borderSide: BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: smallBorderRadius,
        borderSide: BorderSide(color: Colors.red),
      ),
      errorStyle: TextStyle(color: Colors.red),
    );
  }

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      );

  static FilledButtonThemeData get filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Color(0xff52B788),
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: smallBorderRadius,
          ),
        ),
      );
}
